#!/usr/bin/env node
// Issue and revoke download keys for the `jeeva-downloads` Worker (distribution/worker.mjs).
//
// The Worker keeps only each key's SHA-256, as a JSON list in its DOWNLOAD_KEY_HASHES secret,
// and a Cloudflare secret cannot be read back. So the list lives in a file you keep (in the
// vault, never in this repository), and this script edits that file and sets the secret from
// it. A sidecar file beside it (`<file>.labels.json`) names who each hash was issued to, so a
// key can be revoked by its label.
//
//   node scripts/download-keys.mjs issue  <hashes.json> --label <who>   prints the new key once
//   node scripts/download-keys.mjs revoke <hashes.json> <label or hash>
//   node scripts/download-keys.mjs list   <hashes.json>
//   node scripts/download-keys.mjs put    <hashes.json>                  sets the Worker's secret
//
// The key is printed to standard output once and kept nowhere: hand it to the person
// privately. Only its hash is written.
import { createHash, randomBytes } from 'node:crypto';
import { existsSync, readFileSync, renameSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';

/** The shape the Worker accepts: `Bearer <key>` with 32 to 128 of these characters. */
export const KEY_PATTERN = /^[A-Za-z0-9_-]{32,128}$/;
const HASH_PATTERN = /^[a-f0-9]{64}$/;
const WORKER = 'jeeva-downloads';

/** A new key: 48 random bytes as base64url, 64 characters the Worker accepts. */
export function newKey() {
  return randomBytes(48).toString('base64url');
}

/** What the Worker compares a key against. */
export function hashOf(key) {
  return createHash('sha256').update(key, 'utf8').digest('hex');
}

function labelsPath(file) {
  return `${file}.labels.json`;
}

/** The hashes and their labels, from the files; none yet reads as empty. */
export function load(file) {
  const hashes = existsSync(file) ? JSON.parse(readFileSync(file, 'utf8')) : [];
  if (!Array.isArray(hashes) || !hashes.every((hash) => typeof hash === 'string' && HASH_PATTERN.test(hash))) {
    throw new Error(`${file} is not a JSON list of SHA-256 hashes`);
  }
  const labels = existsSync(labelsPath(file)) ? JSON.parse(readFileSync(labelsPath(file), 'utf8')) : {};
  return { hashes, labels };
}

/** Write both files whole, each through a temporary file renamed into place, owner-only. */
function save(file, { hashes, labels }) {
  if (hashes.length === 0) {
    throw new Error('the Worker answers 503 to every download with no key in its list: keep at least one');
  }
  for (const [path, value] of [[file, hashes], [labelsPath(file), labels]]) {
    const temporary = `${path}.new`;
    writeFileSync(temporary, `${JSON.stringify(value, null, 2)}\n`, { mode: 0o600 });
    renameSync(temporary, path);
  }
}

/** Add a new key for `label`: writes its hash, returns the key. */
export function issue(file, label, now = new Date()) {
  if (!label) throw new Error('name who the key is for: --label <who>');
  const state = load(file);
  if (Object.values(state.labels).some((entry) => entry.label === label)) {
    throw new Error(`a key is already issued to ${label}: revoke it first, or use another label`);
  }
  const key = newKey();
  const hash = hashOf(key);
  state.hashes.push(hash);
  state.labels[hash] = { label, issued: now.toISOString() };
  save(file, state);
  return { key, hash };
}

/** Remove the key issued to `which` (a label or a hash); returns its hash. */
export function revoke(file, which) {
  const state = load(file);
  const hash = HASH_PATTERN.test(which)
    ? which
    : Object.keys(state.labels).find((candidate) => state.labels[candidate].label === which);
  if (!hash || !state.hashes.includes(hash)) throw new Error(`no key in ${file} is ${which}`);
  state.hashes = state.hashes.filter((candidate) => candidate !== hash);
  delete state.labels[hash];
  save(file, state);
  return hash;
}

function main(argv) {
  const [command, file, ...rest] = argv;
  if (!command || !file) {
    console.error('usage: download-keys.mjs issue|revoke|list|put <hashes.json> [--label <who> | <label or hash>]');
    return 2;
  }
  switch (command) {
    case 'issue': {
      const at = rest.indexOf('--label');
      const { key, hash } = issue(file, at >= 0 ? rest[at + 1] : undefined);
      console.error(`Issued ${hash.slice(0, 12)}…; set the Worker's secret with: node scripts/download-keys.mjs put ${file}`);
      console.error('The key below is shown once and kept nowhere: hand it to the person privately.');
      console.log(key);
      return 0;
    }
    case 'revoke': {
      const hash = revoke(file, rest[0]);
      console.error(`Revoked ${hash.slice(0, 12)}…; set the Worker's secret with: node scripts/download-keys.mjs put ${file}`);
      return 0;
    }
    case 'list': {
      const { hashes, labels } = load(file);
      for (const hash of hashes) {
        const entry = labels[hash];
        console.log(`${hash.slice(0, 12)}…  ${entry ? `${entry.label}  ${entry.issued}` : '(no label)'}`);
      }
      return 0;
    }
    case 'put': {
      const { hashes } = load(file);
      if (hashes.length === 0) throw new Error('no key in the list: issue one first');
      const put = spawnSync('npx', ['--yes', 'wrangler', 'secret', 'put', 'DOWNLOAD_KEY_HASHES', '--name', WORKER], {
        input: JSON.stringify(hashes),
        stdio: ['pipe', 'inherit', 'inherit'],
      });
      return put.status ?? 1;
    }
    default:
      console.error(`unknown command ${command}`);
      return 2;
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  try {
    process.exitCode = main(process.argv.slice(2));
  } catch (error) {
    console.error(`error: ${error.message}`);
    process.exitCode = 1;
  }
}

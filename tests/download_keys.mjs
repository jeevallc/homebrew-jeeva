// An issued key opens the Worker and a revoked one no longer does: the script's files are
// read back as the Worker's DOWNLOAD_KEY_HASHES secret.
import assert from 'node:assert/strict';
import { webcrypto } from 'node:crypto';
import { mkdtempSync, readFileSync, statSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import worker from '../distribution/worker.mjs';
import { KEY_PATTERN, hashOf, issue, load, revoke } from '../scripts/download-keys.mjs';
globalThis.crypto ??= webcrypto;

const file = join(mkdtempSync(join(tmpdir(), 'jeeva-keys-')), 'hashes.json');
const releases = { async get() { return { body: 'pack', size: 4 }; }, async head() { return { size: 4 }; } };
async function status(key) {
  const env = { DOWNLOAD_KEY_HASHES: readFileSync(file, 'utf8'), RELEASES: releases };
  const response = await worker.fetch(new Request(
    'https://downloads.jeeva.io/releases/v1-dependencies/Jeeva-dependencies-80a6f2dcb5fcb8e5-arm64.dmg',
    { headers: { Authorization: `Bearer ${key}` } },
  ), env);
  return response.status;
}

const first = issue(file, 'sam', new Date('2026-11-16T00:00:00Z'));
assert.match(first.key, KEY_PATTERN, 'a key the Worker accepts');
assert.equal(first.hash, hashOf(first.key));
assert.ok(!readFileSync(file, 'utf8').includes(first.key), 'only the hash is written');
assert.equal(statSync(file).mode & 0o777, 0o600, 'the list is the owner\'s alone');
assert.equal(await status(first.key), 200);

const second = issue(file, 'alex');
assert.notEqual(second.key, first.key);
assert.throws(() => issue(file, 'alex'), /already issued to alex/);
assert.throws(() => issue(file, undefined), /--label/);
assert.deepEqual(Object.values(load(file).labels).map((entry) => entry.label), ['sam', 'alex']);

assert.equal(revoke(file, 'sam'), first.hash, 'revoked by label');
assert.equal(await status(first.key), 401, 'a revoked key opens nothing');
assert.equal(await status(second.key), 200, 'the others still do');
assert.throws(() => revoke(file, 'sam'), /no key/);
assert.throws(() => revoke(file, second.hash), /keep at least one/, 'the last key is never revoked');
assert.equal(await status(second.key), 200);
console.log('Download keys issue, open the Worker, and revoke.');

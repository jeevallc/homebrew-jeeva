import assert from 'node:assert/strict';
import { webcrypto } from 'node:crypto';
import worker from '../distribution/worker.mjs';
globalThis.crypto ??= webcrypto;
const key = 'test-key-'.padEnd(40, 'x');
const hash = Buffer.from(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(key))).toString('hex');
let reads = 0;
const env = { DOWNLOAD_KEY_HASHES: JSON.stringify([hash]), RELEASES: {
  async get() { reads++; return { body: 'test', size: 4 }; },
  async head() { reads++; return { size: 4 }; },
}};
const licence = `/releases/licences/${'a'.repeat(64)}.json`;
async function request(path, auth = key, method = 'GET', expected = 200) {
  const response = await worker.fetch(new Request(`https://downloads.jeeva.io${path}`, {
    method, headers: auth === null ? {} : { Authorization: `Bearer ${auth}` },
  }), env);
  assert.equal(response.status, expected);
  assert.equal(response.headers.get('Cache-Control'), 'private, no-store');
  return response;
}
await request(licence, null, 'GET', 401);
await request(licence, 'invalid'.padEnd(40, 'x'), 'GET', 401);
assert.equal(reads, 0);
await request(licence);
assert.equal(await (await request(licence, key, 'HEAD')).text(), '');
await request('/releases/v0.59.0-app/Jeeva-Studio-v0.59.0-app-arm64.dmg');
await request('/releases/v0.59.0-app/Jeeva-test.zip');
for (const path of ['/releases/licences/latest.json', '/releases/other.json', `${licence}?key=test`]) {
  await request(path, key, 'GET', 404);
}
await request(licence, key, 'POST', 405);
await request(licence, key, 'GET');
console.log('Download route, authentication, methods and private caching checks passed.');

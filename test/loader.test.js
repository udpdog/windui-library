import { after, before, test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { createApp } from '../dev/server.js';

let server;
let origin;
const roblox = { 'User-Agent': 'Roblox/WinInet', Accept: '*/*' };

before(async () => {
  server = createApp();
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  origin = `http://127.0.0.1:${server.address().port}`;
});
after(() => new Promise(resolve => server.close(resolve)));

test('browser navigation returns a real 404 without Lua', async () => {
  const res = await fetch(`${origin}/WindUI.lua`, {
    headers: { 'User-Agent': 'Mozilla/5.0', Accept: 'text/html' },
  });
  assert.equal(res.status, 404);
  assert.equal(await res.text(), '404: Not Found\n');
});

test('Roblox receives exactly the original Lua at both loader routes', async () => {
  const expected = await readFile(new URL('../scripts/WindUI.lua', import.meta.url));
  for (const route of ['/WindUI.lua', '/api/script', '/WindUI.lua/']) {
    const res = await fetch(`${origin}${route}`, { headers: roblox });
    assert.equal(res.status, 200);
    assert.deepEqual(Buffer.from(await res.arrayBuffer()), expected);
    assert.match(res.headers.get('content-type'), /^text\/plain/);
  }
});

test('browser HTML requests are denied even with a Roblox User-Agent', async () => {
  const res = await fetch(`${origin}/WindUI.lua`, {
    headers: { ...roblox, Accept: 'text/html' },
  });
  assert.equal(res.status, 404);
});

test('ordinary HTTP clients are denied', async () => {
  for (const userAgent of ['', 'curl/8.0', 'Mozilla/5.0 Roblox', 'RobloxFake']) {
    const res = await fetch(`${origin}/WindUI.lua`, { headers: { 'User-Agent': userAgent } });
    assert.equal(res.status, 404);
  }
});

test('source paths, homepage, config and unknown routes never serve files', async () => {
  for (const route of ['/', '/scripts/WindUI.lua', '/vercel.json', '/package.json', '/lib/response.js', '/unknown', '/api/not-found']) {
    const res = await fetch(`${origin}${route}`, { headers: roblox });
    assert.equal(res.status, 404, route);
    assert.equal(await res.text(), '404: Not Found\n');
  }
});

test('HEAD, POST and OPTIONS cannot retrieve Lua', async () => {
  for (const method of ['HEAD', 'POST', 'OPTIONS']) {
    const res = await fetch(`${origin}/WindUI.lua`, { method, headers: roblox });
    assert.equal(res.status, 404);
    assert.equal(await res.text(), method === 'HEAD' ? '' : '404: Not Found\n');
  }
});

test('neither Lua nor 404 responses may be cached', async () => {
  for (const headers of [roblox, { 'User-Agent': 'Mozilla/5.0' }]) {
    const res = await fetch(`${origin}/WindUI.lua`, { headers });
    for (const name of ['cache-control', 'cdn-cache-control', 'vercel-cdn-cache-control']) {
      assert.match(res.headers.get(name), /no-store/);
    }
    assert.equal(res.headers.get('x-content-type-options'), 'nosniff');
    await res.arrayBuffer();
  }
});

test('static deployment output contains only the 404 page', async () => {
  assert.deepEqual(await readdir(new URL('../public/', import.meta.url)), ['404.html']);
});

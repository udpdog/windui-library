import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import script from '../api/script.js';
import notFound from '../api/not-found.js';

const config = JSON.parse(readFileSync(new URL('../vercel.json', import.meta.url)));
const handlers = { '/api/script': script, '/api/not-found': notFound };

// Exercise the same route patterns locally, without serving the project files.
export function createApp() {
  return createServer((req, res) => {
    const pathname = new URL(req.url, 'http://localhost').pathname;
    const route = config.routes.find(({ src }) => new RegExp(src).test(pathname));
    const handler = handlers[route?.dest] || notFound;
    Promise.resolve(handler(req, res)).catch(() => {
      if (!res.headersSent) notFound(req, res);
      else res.destroy();
    });
  });
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const port = Number(process.env.PORT || 3000);
  createApp().listen(port, '127.0.0.1', () => {
    console.log(`Local: http://127.0.0.1:${port}/WindUI.lua`);
  });
}

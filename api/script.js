import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { notFound, privateHeaders } from '../lib/response.js';

// A User-Agent is forgeable. This is a visibility filter, not authentication.
function looksLikeRoblox(req) {
  const userAgent = req.headers['user-agent'] || '';
  const accept = req.headers.accept || '';
  return /^Roblox(?:\/|\s|$)/i.test(userAgent)
    && !/text\/html|application\/xhtml\+xml/i.test(accept)
    && req.headers['sec-fetch-mode'] !== 'navigate'
    && req.headers['sec-fetch-dest'] !== 'document';
}

export default async function handler(req, res) {
  if (req.method !== 'GET' || !looksLikeRoblox(req)) {
    return notFound(req, res);
  }

  try {
    // Fixed path: no request parameter can select another file.
    // scripts/ is bundled with this function, never copied to public/.
    const source = await readFile(path.join(process.cwd(), 'scripts', 'WindUI.lua'));
    privateHeaders(res);
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.end(source);
  } catch {
    console.error('WindUI script could not be read.');
    return notFound(req, res);
  }
}

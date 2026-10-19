var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// worker.mjs
var privateHeaders = {
  "Cache-Control": "private, no-store",
  "CDN-Cache-Control": "no-store",
  "Cloudflare-CDN-Cache-Control": "no-store",
  "Vary": "Authorization",
  "X-Content-Type-Options": "nosniff"
};
function reply(status, message, extra = {}) {
  return new Response(message, { status, headers: { ...privateHeaders, ...extra } });
}
__name(reply, "reply");
var worker_default = {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.protocol !== "https:") return reply(400, "HTTPS required");
    let hashes;
    try {
      hashes = JSON.parse(env.DOWNLOAD_KEY_HASHES);
    } catch {
      return reply(503, "Downloads unavailable");
    }
    if (!Array.isArray(hashes) || hashes.length === 0 || !hashes.every((hash) => typeof hash === "string" && /^[a-f0-9]{64}$/.test(hash))) {
      return reply(503, "Downloads unavailable");
    }
    const auth = request.headers.get("Authorization") || "";
    const token = /^Bearer ([A-Za-z0-9_-]{32,128})$/.exec(auth)?.[1];
    if (!token) return reply(401, "Download key required", { "WWW-Authenticate": "Bearer" });
    const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(token));
    const hex = Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
    let matched = 0;
    for (const hash of hashes) {
      let difference = 0;
      for (let index = 0; index < 64; index++) difference |= hex.charCodeAt(index) ^ hash.charCodeAt(index);
      matched |= Number(difference === 0);
    }
    if (!matched) return reply(401, "Invalid download key", { "WWW-Authenticate": "Bearer" });
    if (!["GET", "HEAD"].includes(request.method)) return reply(405, "Method not allowed", { Allow: "GET, HEAD" });
    const releasePath = /^\/releases\/v[0-9][A-Za-z0-9.-]*\/Jeeva-[A-Za-z0-9.-]+\.(dmg|zip)$/.test(url.pathname);
    const licencePath = /^\/releases\/licences\/[a-f0-9]{64}\.json$/.test(url.pathname);
    if (url.search || !(releasePath || licencePath)) {
      return reply(404, "Not found");
    }
    try {
      const name = url.pathname.slice(1);
      const object = request.method === "HEAD" ? await env.RELEASES.head(name) : await env.RELEASES.get(name);
      if (!object) return reply(404, "Not found");
      return new Response(request.method === "HEAD" ? null : object.body, {
        headers: {
          ...privateHeaders,
          "Content-Type": "application/octet-stream",
          "Content-Length": String(object.size),
          "Content-Disposition": `attachment; filename="${name.split("/").pop()}"`
        }
      });
    } catch {
      console.error("Release storage unavailable");
      return reply(503, "Downloads unavailable");
    }
  }
};
export {
  worker_default as default
};


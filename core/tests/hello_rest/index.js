const http = require('http'); // Added built-in http
const zlib = require('zlib'); // Added built-in zlib for gzip

module.exports = function (bodyMap) {

  /**
   * Adapted respond function for native http.
   * - 'next' parameter is removed.
   * - 'res.json' is replaced with 'res.writeHead' and 'res.end' with JSON.stringify.
   * - Handles Gzip compression.
   */
  function respond(req, res) {
    console.log('request received');

    // req.params and req.body are expected to be populated by the server logic
    var key = req.params.key;
    var value = bodyMap[key];
    var returnVal = {};
    returnVal[key] = value || "unknown";
    if (req.body) {
      returnVal.body = req.body;
    }

    const payload = JSON.stringify(returnVal);

    // Mimic restify.plugins.gzipResponse()
    const acceptEncoding = req.headers['accept-encoding'] || '';
    if (acceptEncoding.includes('gzip')) {
      zlib.gzip(payload, (err, buffer) => {
        if (err) {
          // Log error and fallback to uncompressed
          console.error('Gzip compression failed:', err);
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(payload);
          return;
        }
        res.writeHead(200, {
          'Content-Type': 'application/json',
          'Content-Encoding': 'gzip',
          'Content-Length': buffer.length
        });
        res.end(buffer);
      });
    } else {
      // No Gzip
      res.writeHead(200, {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload)
      });
      res.end(payload);
    }
  }

  // Replaced restify.createServer with http.createServer
  var server = http.createServer((req, res) => {

    // 1. Manually parse URL and route: /echo/:key
    const urlParts = req.url.split('/');
    // Expected format: ['', 'echo', 'some-key']
    const routeMatch = urlParts.length === 3 && urlParts[1] === 'echo' && urlParts[2];

    if (!routeMatch) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('Not Found');
      return;
    }

    // Add params to req object (mimicking restify)
    req.params = {
      key: urlParts[2]
    };

    // 2. Check for supported methods (restify.del maps to DELETE)
    const supportedMethods = ['GET', 'POST', 'PUT', 'DELETE'];
    if (supportedMethods.indexOf(req.method) === -1) {
      res.writeHead(405, { 'Content-Type': 'text/plain', 'Allow': supportedMethods.join(', ') });
      res.end('Method Not Allowed');
      return;
    }

    // 3. Manually parse body (mimicking restify.plugins.bodyParser())
    // Only for POST and PUT methods
    if (req.method === 'POST' || req.method === 'PUT') {
      let body = '';
      req.on('data', chunk => {
        body += chunk.toString();
      });
      req.on('end', () => {
        try {
          // bodyParser would parse JSON
          if (body) {
            req.body = JSON.parse(body);
          }
        } catch (e) {
          console.error("Failed to parse request body:", e.message);
          res.writeHead(400, { 'Content-Type': 'text/plain' });
          res.end('Bad Request: Invalid JSON body');
          return;
        }
        // Call respond function *after* body is parsed
        respond(req, res);
      });
    } else {
      // For GET and DELETE, no body is expected
      respond(req, res);
    }
  });

  // The original server.get/post/put/del calls are now
  // handled by the routing logic inside http.createServer.

  return server;
};

'use strict'

const _ = require('lodash')
const assert = require('assert')
const gatewayService = require('../index')
const request = require('postman-request')
const restify = require('restify')
const should = require('should')
const fs = require('fs');
const path = require('path')

const gatewayPort = 8800
const port = 3300
const baseConfig = {
  edgemicro: {
    port: gatewayPort,
    logging: { level: 'info', dir: './tests/log' },
    ssl: {
      key: path.join(__dirname, 'server.key'),
      cert: path.join(__dirname, 'server.crt')
    }
  },
  proxies: [
    { base_path: '/v1', secure: false, url: 'http://localhost:' + port }
  ]
}

var gateway
var server

const startGateway = (config, handler, done) => {
  server = restify.createServer({});

  server.use(restify.plugins.gzipResponse());
  server.use(restify.plugins.bodyParser());

  server.get('/', handler);

  server.listen(port, function () {
    console.log('%s listening at %s', server.name, server.url)

    gateway = gatewayService(config)

    done()
  })
}

describe('test ssl configuration handling', () => {
  afterEach((done) => {
    if (gateway) {
      gateway.stop(() => { })
    }

    if (server) {
      server.close()
    }

    done()
  })

  describe('config', () => {
    describe('ssl', () => {
      it('can request against an ssl endpoint', (done) => {
        startGateway(baseConfig, (req, res, next) => {
          assert.equal('localhost:' + port, req.headers.host)
          res.end('OK')
        }, () => {
          gateway.start((err) => {
            assert(!err, err)
            request({
              method: 'GET',
              key: fs.readFileSync(path.join(__dirname, 'server.key')),
              cert: fs.readFileSync(path.join(__dirname, 'server.crt')),
              rejectUnauthorized: false,
              url: 'https://localhost:' + gatewayPort + '/v1'
            }, (err, r, body) => {
              assert(!err, err)
              assert.equal('OK', body)
              done()
            })
          })
        })
      })
    })
  })
})

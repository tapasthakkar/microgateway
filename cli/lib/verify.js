'use strict';
const edgeconfig = require('../../config');
//const path = require('path');
const request = require('postman-request');
const async = require('async');
//const assert = require('assert');
const writeConsoleLog = require('../../core').Logging.writeConsoleLog;
edgeconfig.setConsoleLogger(writeConsoleLog);

const CONSOLE_LOG_TAG_COMP = 'microgateway verify';

const configLocations = require('../../config/locations');


const agentLib = require('../../lib/agent-config');
const util = require('util');

const Verify = function () { }
module.exports = function () {
  return new Verify();
}

Verify.prototype.verify = function verify(options) {


  const key = options.key;
  const secret = options.secret;
  const keys = { key: key, secret: secret };
  var downloadedConfig;
  const sourcePath = configLocations.getSourcePath(options.org, options.env);

  const agentConfig = edgeconfig.load({ source: sourcePath });

  const authUri = agentConfig['edge_config']['authUri']

  options.bootstrap = agentConfig['edge_config'].bootstrap;
  options['jwt_path'] = agentConfig['edge_config']['jwt_public_key'];

  const tasks = [
    function (cb) {
      // check analytics availability with 500 error
      request({
        method: 'POST',
        uri: downloadedConfig.analytics.uri,
        auth: {
          user: key,
          pass: secret
        }
      },
        function (err, res) {
          if (err) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying analytics negative case: FAIL');
            return cb(err);
          }

          if (res.statusCode === 401) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying analytics negative case: FAIL');
            return cb(new Error('analytics up - got 401 Unauthorized. Invalid key/secret credentials.'));
          } else if (res.statusCode !== 500) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying analytics negative case: FAIL');
            return cb(new Error('analytics up - got code: ' + res.statusCode));
          } else {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying analytics negative case: OK');
            cb();
          }
        });
    },
    function (cb) {
      // verify bootstrap url availability
      request({
        method: 'GET',
        uri: options.bootstrap,
        auth: {
          user: key,
          pass: secret
        }
      },
        function (err, res/*, body */) {
          if (err) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying bootstrap url availability:FAIL');
            return cb(err);
          }

          if (res.statusCode === 401) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying bootstrap url availability:FAIL');
            return cb(new Error('bootstrap - got 401 Unauthorized. Invalid key/secret credentials.'));
          } else if (res.statusCode !== 200) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying bootstrap url availability:FAIL');
            return cb(new Error('bootstrap - got code: ' + res.statusCode))
          } else {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying bootstrap url availability:OK');
            cb();
          }
        })
    },
    function (cb) {
      // verify jwt_public key availability
      request({
        method: 'GET',
        uri: options['jwt_path']
      },
        function (err, res/* , body */) {
          if (err) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying jwt_public_key availability: FAIL');
            return cb(err);
          }

          if (res.statusCode !== 200) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying jwt_public_key availability: FAIL');
            return cb(new Error('jwt - got code: ' + res.statusCode));
          } else {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying jwt_public_key availability: OK');
            cb();
          }
        });
    },
    function (cb) {
      // verify products endpoint availability
      const productsUrl = (authUri.indexOf("%s") === -1) ? authUri + '/products' : util.format(authUri + '/products', options.org, options.env);
      //const productsUrl = util.format(authUri + '/products', options.org, options.env);
      request({
        method: 'GET',
        auth: {
          user: key,
          pass: secret
        },        
        uri: productsUrl
      },
        function (err, res/* , body */) {
          if (err) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying products availability: FAIL');
            return cb(err);
          }

          if (res.statusCode !== 200) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying products availability: FAIL');
            return cb(new Error('products - got code: ' + res.statusCode));
          } else {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying products availability: OK');
            cb();
          }
        });
    },
    function (cb) {
      // verify quota availability for configured products
      const prods = Object.keys(downloadedConfig.quota);

      async.each(prods, function (prod, eachCb) {
        if ( !downloadedConfig.quota[prod] ||  !downloadedConfig.quota[prod].uri ) {
          return eachCb();
        }
        request({
          method: 'POST',
          uri: downloadedConfig.quota[prod].uri + '/v2/quotas/apply',
          auth: {
            user: key,
            pass: secret
          }
        },
          function (err, res/* , body */) {
            if (err) { return eachCb(err); }

            if (res.statusCode === 401) {
              return eachCb(new Error('Got 401 Unauthorized. Invalid key/secret credentials.'));
            } else if (res.statusCode !== 200) {
              return eachCb(new Error('quota - got code: ' + res.statusCode));
            } else {
              eachCb();
            }
          });
      }, function (err) {
        if (err) {
          writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying quota with configured products: FAIL');
          cb(err);
        }

        writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying quota with configured products: OK');
        cb();
      });
    },
    function (cb) {
      // verify analytics works with synthetic payload
      const payload = {
        "client_received_start_timestamp": Date.now(),
        "client_received_end_timestamp": Date.now(),
        "recordType": "APIAnalytics",
        "apiproxy": "edgemicro_127",
        "request_uri": "http://127.0.0.1:8000/hello",
        "request_path": "/hello",
        "request_verb": "GET",
        "client_ip": "127.0.0.1",
        "useragent": "curl/7.43.0",
        "apiproxy_revision": "1",
        "response_status_code": 200,
        "client_sent_start_timestamp": Date.now(),
        "client_sent_end_timestamp": Date.now(),
        "developer_app": "52ec80e1-06b7-4db6-ac36-9c5842072603",
        "client_id": "6gClRCKp0UCOZ8o9Q5S7X88nI5hgizGQ",
        "api_product": "travel-app"
      }

      request({
        method: 'POST',
        uri: downloadedConfig.analytics.uri,
        auth: {
          user: key,
          pass: secret
        }
      },
        function (err, res/* , body */) {
          if (err) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying analytics with payload: FAIL');
            return cb(err);
          }

          if (res.statusCode === 401) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying analytics with payload: FAIL');
            return cb(new Error('analytics synthetic - got 401 Unauthorized. Invalid key/secret credentials.'));
          } else if (res.statusCode !== 200) {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying analytics with payload: FAIL');
            return cb(new Error('analytics synthetic - got code: ' + res.statusCode));
          } else {
            writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verifying analytics with payload: OK');
            return cb();
          }
        })
        .write(JSON.stringify(payload));
    }
  ];

  const cachePath = configLocations.getCachePath(options.org, options.env);

  edgeconfig.get({ source: sourcePath, keys: keys, org: options.org, env: options.env}, function (err, config) {
    edgeconfig.save(config, cachePath);
    agentLib({ keys: keys, target: cachePath }, (err, agent, config) => {
      if (err) {
        return printError(err);
      }
      downloadedConfig = config;
      async.series(tasks, function ( /*asyncErr, res */ ) {
        writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'verification complete');
        agent.close(process.exit); // close and stop agent
      });
    })
  });


}
function printError(err) {
  if (err.response) {
    writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},err.response.error);
  } else {
    writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},err);
  }
}

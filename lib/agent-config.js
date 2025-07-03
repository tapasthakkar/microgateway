'use strict';
const edgeConfig = require('../config');
const agent = require('./server')();
const fs = require('fs');
const assert = require('assert');
const debug = require('debug')('gateway:init');

const writeConsoleLog = require('../core').Logging.writeConsoleLog;
edgeConfig.setConsoleLogger(writeConsoleLog);
const CONSOLE_LOG_TAG_COMP = 'microgateway agent-config';
//const path = require('path');
//const cluster = require('cluster');

/**
 * starts an configures agent
 * @param env {source,target,keys{key,secret}}
 * @param cb
 */
module.exports = function configureAndStart(options, cb) {
  assert(options.target, 'must have target');
  getConfigStart(options, cb);
};

const getConfigStart = function getConfigStart(options, cb) {
  fs.exists(options.target, (exists) => {
    if (exists) {
      let config = edgeConfig.load({ source: options.target });
      let keys = {};

      if((process.env.EDGEMICRO_KEY && process.env.EDGEMICRO_SECRET) && !options.keys){
          keys  = {
            key: process.env.EDGEMICRO_KEY,
            secret: process.env.EDGEMICRO_SECRET
          }
      }else{
          keys = {
            key: options.keys.key,
            secret: options.keys.secret
          } 
      }

      _mergeKeys(config,keys);
      
      if(options.metrics){
        config.edgemicro.useMetrics = true;
      }
      
      startServer(keys, options.pluginDir, config, cb);
    } else {
      return cb(options.target+" must exist")
    }
  });
};

const startServer = function startServer(keys, pluginDir,config, cb) {
  agent.start(keys, pluginDir, config, function (err) {
    cb(err, agent, config);
  });
}


/**
 * merge downloaded config with keys
 * @param mergedConfig
 * @param keys
 * @private
 */
function _mergeKeys(mergedConfig, keys) {
  assert(keys.key, 'key is missing');
  assert(keys.secret, 'secret is missing');
  // copy keys to analytics section
  if (!mergedConfig.analytics) {
      mergedConfig.analytics = {};
  }
  mergedConfig.analytics.key = keys.key;
  mergedConfig.analytics.secret = keys.secret;
  // copy keys to quota section
  if (mergedConfig.quota) {
      Object.keys(mergedConfig.quota).forEach(function(name) {
          const quota = mergedConfig.quota[name];
          quota.key = keys.key;
          quota.secret = keys.secret;
      });
  }
}
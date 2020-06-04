'use strict';
const edgeConfig = require('microgateway-config');
const agent = require('./server')();
const fs = require('fs');
const assert = require('assert');
const debug = require('debug')('gateway:init');

const writeConsoleLog = require('microgateway-core').Logging.writeConsoleLog;
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
      if(options.metrics){
        config.edgemicro.useMetrics = true;
      }
      // merge env values into the config
      try {
        let configStr = JSON.stringify(config);
        let envRegx = RegExp('<E>.+?<\/E>','g');   
        let envKeys = configStr.match(envRegx);
        if ( envKeys && envKeys.length > 0) {
          envKeys.forEach( key => {
            let envKey = key.replace('<E>','').replace("</E>",''); // remove env tags
            let value = process.env[envKey];
            if ( value ) {
              debug('Replacing: %s by en value: %s', key, `${value}`);
              configStr = configStr.replace(key,`${value}`)
            } else {
              let err = new Error('No env variable '+ envKey +' available to replace in config');
              writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP}, err);
            }
          })
          config = JSON.parse(configStr);
        }
      } catch(err) {
        writeConsoleLog('log',{component: CONSOLE_LOG_TAG_COMP},'Error in merging env values in the config', err)
      }
      
    
      const keys = {key: config.analytics.key, secret: config.analytics.secret};
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

'use strict';
var debug = require('debug')('gateway:index');
var gateway = require('./lib/gateway');
var assert = require('assert');
var logging = require('./lib/logging');
var adminServer = require('./lib/admin-server');

var pluginsLib = require('./lib/plugins');
const { v4: uuid } = require('uuid');
var configService = require('./lib/config');
var _ = require('lodash');

/**
 *
 * @param config must include {key:string,secret:string}
 * @param cb callback when started
 */
var Gateway = function (config) {
  assert(config, 'options must contain config')
  config.uid = uuid()
  configService.init(config);
  logging.init()
  this.plugins = [];
  this.pluginLoader = pluginsLib();

};


module.exports = function (config) {
  return new Gateway(config);
}

module.exports.Logging = logging;
module.exports.AdminServer = adminServer;
Gateway.prototype.start = function (cb) {
  const logger = logging.getLogger();
  //const config = configService.get();
  let plugins  = this.plugins;
  debug('starting edgemicro');
  //debug('loaded config ' + util.inspect(config, {colors: true}));
  gateway.start( plugins, function (err, server) {
    if (err) {
      logger.consoleLog('error','error starting edge micro', err);
    }
    return cb(err, server)
  });
};

Gateway.prototype.stop = function(cb){
  gateway.stop(cb);
}

Gateway.prototype.addPlugin = function (name,plugin,allPluginNames) {
  assert(name,"plugin must have a name")
  assert(_.isString(name),"name must be a string");
  assert(_.isFunction(plugin),"plugin must be a function(config,logger,stats){return {onresponse:function(req,res,data,next){}}}");
  const handler = this.pluginLoader.loadPlugin({plugin:plugin,pluginName:name,allPluginNames:allPluginNames});
  this.plugins.push(handler);
};


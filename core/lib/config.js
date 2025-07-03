'use strict'
var assert = require('assert');
var fs = require('fs');
var config = {};
var configService = module.exports = {}

configService.get = () => {
  assert(config, 'config not initialized')
  return config
};

configService.init = (newConfig) => {
  config = newConfig;
  config.edgemicro = config.edgemicro || { plugins: {} };
  config.targets = config.targets || [];

  //Iterate through each proxy variable. If it's present in the environment let's place 
  //it in the edgemicro configuration.
  // Use proxy from env variables if edgemicro.proxy.url is not set
  if ( config.edgemicro.proxy && config.edgemicro.proxy.enabled === true && !config.edgemicro.proxy.url ) { 
    var httpProxyEnvVariables = ['HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy'];
    httpProxyEnvVariables.forEach((v)=> {
      if(process.env[v]) {
        config.edgemicro.proxy.url = process.env[v];
      }
    });
  }
 

  config.targets.forEach(function(target) {
    if ( (typeof target.ssl !== 'object') || (typeof target.ssl.client !== 'object') ) {
      return;
    }

    // restrict the copied options to prevent target hijacking
    // via configuration
    target.ssl.client.httpsOptions = {
      pfx: target.ssl.client.pfx,
      key: target.ssl.client.key,
      passphrase: target.ssl.client.passphrase,
      cert: target.ssl.client.cert,
      ca: target.ssl.client.ca,
      ciphers: target.ssl.client.ciphers,
      rejectUnauthorized: target.ssl.client.rejectUnauthorized,
      secureProtocol: target.ssl.client.secureProtocol,
      servername: target.ssl.client.servername,
      crl: target.ssl.client.crl
    };

    var fileOptions = ['cert', 'key', 'ca', 'pfx', 'crl'];
    fileOptions.forEach(function(opt) {
      var filename = target.ssl.client.httpsOptions[opt];
      if (filename) {
        target.ssl.client.httpsOptions[opt] = fs.readFileSync(filename);
      }
    });

  });
}

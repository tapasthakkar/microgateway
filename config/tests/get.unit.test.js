'use strict'

const assert = require('assert');
const configlib = require('../index.js');
var proxyquire = require('proxyquire');
var mockRequestValid = require('./fixtures/mock-request-valid.js');
var mockRequestInvalidProducts = require('./fixtures/mock-request-invalid-products.js');
var mockRequestInvalidProxies = require('./fixtures/mock-request-invalid-proxies.js');
const keys = {
    key: 'mYt3sTk3Y',
    secret: 'mYt3sTs3Cr3T'
};

let configlibmockValid = proxyquire.load('../index.js', {
    './lib/network': proxyquire.load('../lib/network', {
        'postman-request': mockRequestValid
    })
});

let configlibmockInvalidProducts = proxyquire.load('../index.js', {
    './lib/network': proxyquire.load('../lib/network', {
        'postman-request': mockRequestInvalidProducts
    })
});


let configlibmockInvalidProxies = proxyquire.load('../index.js', {
    './lib/network': proxyquire.load('../lib/network', {
        'postman-request': mockRequestInvalidProxies
    })
});


describe('config - get ', () => {
    it('gets product updates from server', done => {
        configlibmockValid.get({ source: './tests/fixtures/load-dummy-eval-test-config.yaml', keys: keys }, (err, config) => {
            assert(config.product_to_proxy.productOne);
            assert(config.product_to_proxy.productTwo);
            assert(config.product_to_proxy.productThree);
            done();
        });
    });

    it('displays error when receiving invalid JSON product info', (done) => {
        var saveErr = console.error;
        console.error = () => {}
        configlibmockInvalidProducts.get({ source: './tests/fixtures/load-dummy-eval-test-config.yaml', keys: keys }, (err, config) => {
            console.error = saveErr;
            assert.equal(err instanceof Error, true);
            assert.equal(err.message.includes('CRITICAL ERROR: error parsing downloaded product list'), true);
            done();
        });
    });

    it('displays error when receiving invalid JSON proxy info', (done) => {
        var saveErr = console.error;
        console.error = () => {}
        configlibmockInvalidProxies.get({ source: './tests/fixtures/load-dummy-eval-test-config.yaml', keys: keys }, (err, config) => {
            console.error = saveErr;
            assert.equal(err instanceof Error, true);
            done();
        });
    });

    it('gets extauth public key updates from server', done => {
        configlibmockValid.get({ source: './tests/fixtures/load-dummy-eval-test-config.yaml', keys: keys }, (err, config) => {
            assert(config.extauth.public_keys);
            done();
        });
    });
});
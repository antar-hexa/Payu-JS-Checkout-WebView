'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var core = require('@capacitor/core');

const PayUCheckoutWebView = core.registerPlugin('PayUCheckoutWebView', {
    web: () => Promise.resolve().then(function () { return web; }).then(m => new m.PayUCheckoutWebViewWeb()),
});

class PayUCheckoutWebViewWeb extends core.WebPlugin {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    openWebView(_options) {
        throw new Error('Method not implemented.');
    }
    closeWebView() {
        throw new Error('Method not implemented.');
    }
}

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    PayUCheckoutWebViewWeb: PayUCheckoutWebViewWeb
});

exports.PayUCheckoutWebView = PayUCheckoutWebView;
//# sourceMappingURL=plugin.cjs.js.map

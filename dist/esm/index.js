import { registerPlugin } from '@capacitor/core';
const PayUCheckoutWebView = registerPlugin('PayUCheckoutWebView', {
    web: () => import('./web').then(m => new m.PayUCheckoutWebViewWeb()),
});
export * from './definitions';
export { PayUCheckoutWebView };
//# sourceMappingURL=index.js.map
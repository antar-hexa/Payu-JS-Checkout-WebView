import { registerPlugin } from '@capacitor/core';

import type { PayUCheckoutWebViewPlugin } from './definitions';

const PayUCheckoutWebView = registerPlugin<PayUCheckoutWebViewPlugin>('PayUCheckoutWebView', {
  web: () => import('./web').then(m => new m.PayUCheckoutWebViewWeb()),
});

export * from './definitions';
export { PayUCheckoutWebView };

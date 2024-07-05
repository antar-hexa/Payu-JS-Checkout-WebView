import { WebPlugin } from '@capacitor/core';

import type { PayUCheckoutWebViewPlugin } from './definitions';

export class PayUCheckoutWebViewWeb extends WebPlugin implements PayUCheckoutWebViewPlugin {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  openWebView(_options: { url: string; postData: string; }): Promise<void> {
    throw new Error('Method not implemented.');
  }
  closeWebView(): Promise<void> {
    throw new Error('Method not implemented.');
  }
}

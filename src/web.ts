import { WebPlugin } from '@capacitor/core';

import type { PayUCheckoutWebViewPlugin } from './definitions';

export class PayUCheckoutWebViewWeb extends WebPlugin implements PayUCheckoutWebViewPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

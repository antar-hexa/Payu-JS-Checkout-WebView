import { WebPlugin } from '@capacitor/core';
import type { PayUCheckoutWebViewPlugin } from './definitions';
export declare class PayUCheckoutWebViewWeb extends WebPlugin implements PayUCheckoutWebViewPlugin {
    openWebView(_options: {
        url: string;
        postData: string;
    }): Promise<void>;
    closeWebView(): Promise<void>;
}

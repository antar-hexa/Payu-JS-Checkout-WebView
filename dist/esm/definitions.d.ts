export interface PayUCheckoutWebViewPlugin {
    openWebView(options: {
        url: string;
        postData: string;
        callbackUrl: string;
    }): Promise<void>;
    closeWebView(): Promise<void>;
}

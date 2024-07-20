#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(PayUCheckoutWebViewPlugin, "PayUCheckoutWebView",
  CAP_PLUGIN_METHOD(openWebView, CAPPluginReturnPromise);
)
import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(PayUCheckoutWebViewPlugin)
public class PayUCheckoutWebViewPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "PayUCheckoutWebViewPlugin"
    public let jsName = "PayUCheckoutWebView"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = PayUCheckoutWebView()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }

    @objc func openWebView(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url"), let postData = call.getString("postData"), let callbackUrl = call.getString("callbackUrl") else {
            call.reject("Must provide a URL and postData")
            return
        }

        call.keepAlive = true

        DispatchQueue.main.async {
            let viewController = PayuWebViewController()
            viewController.urlString = urlString
            viewController.postData = postData
            viewController.callbackUrl = callbackUrl
            viewController.modalPresentationStyle = .fullScreen
            viewController.onCallbackUrlReached = { resolvedUrl in
                call.resolve(["url": resolvedUrl])
            }
            self.bridge?.viewController?.present(viewController, animated: true, completion: nil)
        }
    }
}

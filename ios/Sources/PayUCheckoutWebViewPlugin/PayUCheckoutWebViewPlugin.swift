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
}

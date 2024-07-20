import UIKit
import WebKit

class PayuWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    var progressBar: UIProgressView!
    var callbackUrl: String?
    var urlString: String?
    var postData: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        self.view.addSubview(webView)

        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.frame.width, height: 2)
        self.view.addSubview(progressBar)

        if let urlString = urlString, let url = URL(string: urlString), let postData = postData {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData.data(using: .utf8)
            webView.load(request)
        }

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.progress = Float(webView.estimatedProgress)
        }
    }

    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            showExitConfirmation()
        }
    }

    func showExitConfirmation() {
        let alertController = UIAlertController(title: "Confirm Exit", message: "Are you sure you want to exit?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.isHidden = true
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressBar.isHidden = false
        progressBar.progress = 0.1
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressBar.isHidden = true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("url.........\(navigationAction.request.url)") 

        if let url = navigationAction.request.url, 

              !url.absoluteString.hasPrefix("http://"), 

              !url.absoluteString.hasPrefix("https://"), 

              UIApplication.shared.canOpenURL(url) { 

  

              // have UIApplication handle the url (sms:, tel:, mailto:, ...) 

              UIApplication.shared.open(url, options: [:], completionHandler: nil) 

  

              // cancel the request (handled by UIApplication) 

              decisionHandler(.cancel) 

          } 

          else { 

              // allow the request 

              decisionHandler(.allow) 

        } 
    }

}

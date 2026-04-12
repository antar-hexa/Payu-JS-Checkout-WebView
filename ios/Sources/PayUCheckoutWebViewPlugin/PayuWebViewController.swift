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

        // Navigation bar with back button
        let navBar = UINavigationBar(frame: .zero)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let navItem = UINavigationItem()
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navBar.setItems([navItem], animated: false)

        webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

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

    @objc func backButtonTapped(_ sender: UIBarButtonItem) {
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

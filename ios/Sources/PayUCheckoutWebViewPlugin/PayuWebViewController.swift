import UIKit
import WebKit

class PayuWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    var progressBar: UIProgressView!
    var callbackUrl: String?
    var urlString: String?
    var postData: String?
    var onCallbackUrlReached: ((String) -> Void)?
    private weak var backButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let backButton = UIButton(type: .system)
        let chevron = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold))
        backButton.setImage(chevron, for: .normal)
        backButton.tintColor = .label
        backButton.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        backButton.layer.cornerRadius = 18
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.isHidden = true  // hidden until page load confirms no .back element
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        self.backButton = backButton

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

    @objc func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            let alert = UIAlertController(title: "Confirm Exit", message: "Are you sure you want to exit?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in self.dismiss(animated: true) })
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            present(alert, animated: true)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.isHidden = true
        updateBackButtonVisibility()
    }

    private func updateBackButtonVisibility() {
        // Small delay to allow JS-rendered content to appear in the DOM
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.webView.evaluateJavaScript("document.querySelector('.back') !== null") { [weak self] result, _ in
                let pageHasBackButton = (result as? Bool) == true
                DispatchQueue.main.async {
                    self?.backButton?.isHidden = pageHasBackButton
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressBar.isHidden = false
        progressBar.progress = 0.1
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressBar.isHidden = true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let urlAbsolute = url.absoluteString

            // Check if this is the callback URL
            if let callbackUrl = callbackUrl, urlAbsolute.hasPrefix(callbackUrl) {
                decisionHandler(.cancel)
                dismiss(animated: true) {
                    self.onCallbackUrlReached?(urlAbsolute)
                }
                return
            }

            // Open non-http(s) URLs (tel:, sms:, mailto:, etc.) in the system
            if !urlAbsolute.hasPrefix("http://"), !urlAbsolute.hasPrefix("https://"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
}

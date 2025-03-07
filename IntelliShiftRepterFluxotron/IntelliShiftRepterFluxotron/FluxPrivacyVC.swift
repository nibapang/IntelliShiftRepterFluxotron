//
//  FluxPrivacyVC.swift
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

import UIKit

@preconcurrency import WebKit

class FluxPrivacyVC: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var fluxWebView: WKWebView!
    @IBOutlet weak var closeBtn: UIButton!
    var backAction: (() -> Void)?
    var privacyData: [Any]?
    @objc var url: String?
    let axPrivacyUrl = "https://www.termsfeed.com/live/e6893c5e-6d13-49b8-af54-4ad9218755d6"
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var bottomCos: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.privacyData = UserDefaults.standard.array(forKey: UIViewController.fluxGetUserDefaultKey())
        fluxInitSubViews()
        fluxInitNavView()
        fluxInitWebView()
        axStartLoadWebView()
    }
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let confData = privacyData, confData.count > 4 {
            let top = (confData[3] as? Int) ?? 0
            let bottom = (confData[4] as? Int) ?? 0
            
            if top > 0 {
                topCos.constant = view.safeAreaInsets.top
            }
            if bottom > 0 {
                bottomCos.constant = view.safeAreaInsets.bottom
            }
        }
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    //MARK: - Functions
    @objc func backClick() {
        backAction?()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - INIT
    private func fluxInitSubViews() {
        fluxWebView.scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .black
        fluxWebView.backgroundColor = .black
        fluxWebView.isOpaque = false
        fluxWebView.scrollView.backgroundColor = .black
        indicatorView.hidesWhenStopped = true
    }

    private func fluxInitNavView() {
        guard let url = url, !url.isEmpty else {
            fluxWebView.scrollView.contentInsetAdjustmentBehavior = .automatic
            return
        }
        
        self.closeBtn.isHidden = true
        navigationController?.navigationBar.tintColor = .systemBlue
        let image = UIImage(systemName: "xmark")
        let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backClick))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    private func fluxInitWebView() {
        guard let confData = privacyData, confData.count > 17 else { return }
        let userContentC = fluxWebView.configuration.userContentController
        
        if let trackStr = confData[5] as? String {
            let trackScript = WKUserScript(source: trackStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            userContentC.addUserScript(trackScript)
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let bundleId = Bundle.main.bundleIdentifier,
           let wName = confData[7] as? String {
            let inPPStr = "window.\(wName) = {name: '\(bundleId)', version: '\(version)'}"
            let inPPScript = WKUserScript(source: inPPStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            userContentC.addUserScript(inPPScript)
        }
        
        if let messageHandlerName = confData[6] as? String {
            userContentC.add(self, name: messageHandlerName)
        }
        
        fluxWebView.navigationDelegate = self
        fluxWebView.uiDelegate = self
    }
    
    
    private func axStartLoadWebView() {
        let urlStr = url ?? axPrivacyUrl
        guard let url = URL(string: urlStr) else { return }
        indicatorView.startAnimating()
        let request = URLRequest(url: url)
        fluxWebView.load(request)
    }
    
    private func axReloadWebViewData(_ adurl: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let storyboard = self.storyboard,
               let adView = storyboard.instantiateViewController(withIdentifier: "FluxPrivacyVC") as? FluxPrivacyVC {
                adView.url = adurl
                adView.backAction = { [weak self] in
                    let close = "window.closeGame();"
                    self?.fluxWebView.evaluateJavaScript(close, completionHandler: nil)
                }
                let nav = UINavigationController(rootViewController: adView)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let confData = privacyData, confData.count > 9 else { return }
        
        let name = message.name
        if name == (confData[6] as? String),
           let trackMessage = message.body as? [String: Any] {
            let tName = trackMessage["name"] as? String ?? ""
            let tData = trackMessage["data"] as? String ?? ""
            
            if let data = tData.data(using: .utf8) {
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if tName != (confData[8] as? String) {
                            fluxSendEvent(tName, values: jsonObject)
                            return
                        }
                        if tName == (confData[9] as? String) {
                            return
                        }
                        if let adId = jsonObject["url"] as? String, !adId.isEmpty {
                            axReloadWebViewData(adId)
                        }
                    }
                } catch {
                    fluxSendEvent(tName, values: [tName: data])
                }
            } else {
                fluxSendEvent(tName, values: [tName: tData])
            }
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        DispatchQueue.main.async {
            let authenticationMethod = challenge.protectionSpace.authenticationMethod
            if authenticationMethod == NSURLAuthenticationMethodServerTrust,
               let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            }
        }
        
    }
}

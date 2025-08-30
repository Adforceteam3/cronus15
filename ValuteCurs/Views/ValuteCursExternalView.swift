import SwiftUI
import WebKit

struct ValuteCursExternalView: View {
    @State private var isLoading = true
    @State private var progress: Double = 0.0
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var tViewCoordinator: ValuteCursViewCoordinator?
    @State private var currentUrl = ""
    @EnvironmentObject var accessManager: ValuteCursAccessManager
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            

            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        // Back button
                        Button(action: {
                            print("Back button tapped, canGoBack: \(canGoBack), coordinator: \(tViewCoordinator != nil)")
                            tViewCoordinator?.valuteCursView?.goBack()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(canGoBack ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                                .cornerRadius(20)
                        }
                        .disabled(!canGoBack)
                        
                        // Progress Bar and URL
                        VStack(spacing: 4) {
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 4)
                                        .cornerRadius(2)
                                    
                                    Rectangle()
                                        .fill(Color.blue)
                                        .frame(width: geometry.size.width * progress, height: 4)
                                        .cornerRadius(2)
                                        .animation(.easeInOut(duration: 0.3), value: progress)
                                }
                            }
                            .frame(height: 4)
                            

                        }
                        
                        // Reload button
                        Button(action: {
                            print("Reload button tapped, coordinator: \(tViewCoordinator != nil)")
                            tViewCoordinator?.valuteCursView?.reload()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    .background(Color.black)
                }
                
               
                ValuteCursViewRepresentable(
                    isLoading: $isLoading,
                    progress: $progress,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    coordinator: $tViewCoordinator,
                    currentUrl: $currentUrl,
                    accessManager: accessManager
                )
                .background(Color.black)
            }
        }
        .navigationBarHidden(true)
    }
}

struct ValuteCursViewRepresentable: UIViewRepresentable {
    @Binding var isLoading: Bool
    @Binding var progress: Double
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var coordinator: ValuteCursViewCoordinator?
    @Binding var currentUrl: String
    let accessManager: ValuteCursAccessManager
    
    func makeUIView(context: Context) -> WKWebView {
        let valuteCursConfig = WKWebViewConfiguration()
        let valuteCursPreferences = WKWebpagePreferences()
        valuteCursPreferences.allowsContentJavaScript = true
        valuteCursConfig.defaultWebpagePreferences = valuteCursPreferences
        valuteCursConfig.allowsInlineMediaPlayback = true
        valuteCursConfig.mediaTypesRequiringUserActionForPlayback = []
        valuteCursConfig.allowsAirPlayForMediaPlayback = true
        valuteCursConfig.allowsPictureInPictureMediaPlayback = true
        
        
        let valuteCursDataStore = WKWebsiteDataStore.default()
        valuteCursConfig.websiteDataStore = valuteCursDataStore
        
            // Enable cookie persistence
        valuteCursDataStore.httpCookieStore.getAllCookies { _ in }
        
        // Set custom cookie handling
   
        
        let valuteCursView = WKWebView(frame: .zero, configuration: valuteCursConfig)
        valuteCursView.navigationDelegate = context.coordinator
        valuteCursView.uiDelegate = context.coordinator
        valuteCursView.allowsBackForwardNavigationGestures = true
        
        // Enable swipe navigation
        valuteCursView.allowsBackForwardNavigationGestures = true
        
        // Set custom user agent
        valuteCursView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        // Store reference in coordinator
        context.coordinator.valuteCursView = valuteCursView
        
        
        if let valuteCursUrl = mx_activeRedirect {
            let valuteCursRequest = URLRequest(url: valuteCursUrl)
            valuteCursView.load(valuteCursRequest)
            print("🌐 Loading URL in webView: \(valuteCursUrl)")
        }
        
        return valuteCursView
    }
    
    func updateUIView(_ valuteCursWebView: WKWebView, context: Context) {
       
        DispatchQueue.main.async {
            self.canGoBack = valuteCursWebView.canGoBack
            self.canGoForward = valuteCursWebView.canGoForward
            print("updateUIView - canGoBack: \(self.canGoBack), canGoForward: \(self.canGoForward)")
        }
    }
    
    func makeCoordinator() -> ValuteCursViewCoordinator {
        let valuteCursViewCoordinator = ValuteCursViewCoordinator(
            isLoading: $isLoading,
            progress: $progress,
            canGoBack: $canGoBack,
            canGoForward: $canGoForward,
            currentUrl: $currentUrl,
            accessManager: accessManager
        )
        DispatchQueue.main.async {
            self.coordinator = valuteCursViewCoordinator
            print("Coordinator set: \(self.coordinator != nil)")
        }
        return valuteCursViewCoordinator
    }
}

class ValuteCursViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    @Binding var isLoading: Bool
    @Binding var progress: Double
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var currentUrl: String
    weak var valuteCursView: WKWebView?
    let accessManager: ValuteCursAccessManager
    
    init(isLoading: Binding<Bool>, progress: Binding<Double>, canGoBack: Binding<Bool>, canGoForward: Binding<Bool>, currentUrl: Binding<String>, accessManager: ValuteCursAccessManager) {
        self._isLoading = isLoading
        self._progress = progress
        self._canGoBack = canGoBack
        self._canGoForward = canGoForward
        self._currentUrl = currentUrl
        self.accessManager = accessManager
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ valuteCursWebView: WKWebView, decidePolicyFor valuteCursNavigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let valuteCursUrl = valuteCursNavigationAction.request.url {
            let valuteCursScheme = valuteCursUrl.scheme?.lowercased()
            let valuteCursUrlString = valuteCursUrl.absoluteString.lowercased()

            if let valuteCursScheme = valuteCursScheme,
               valuteCursScheme != "http", valuteCursScheme != "https", valuteCursScheme != "about" {
                if valuteCursScheme == "itms-apps" || valuteCursUrlString.contains("apps.apple.com") {
                    UIApplication.shared.open(valuteCursUrl, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }

                UIApplication.shared.open(valuteCursUrl, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
    
    func webView(_ valuteCursWebView: WKWebView, createWebViewWith valuteCursConfiguration: WKWebViewConfiguration, for valuteCursNavigationAction: WKNavigationAction, windowFeatures valuteCursWindowFeatures: WKWindowFeatures) -> WKWebView? {
        if valuteCursNavigationAction.targetFrame == nil {
            if let valuteCursUrl = valuteCursNavigationAction.request.url {
                let valuteCursRequest = URLRequest(url: valuteCursUrl)
                valuteCursWebView.load(valuteCursRequest)
            }
        }
        return nil
    }
    
    // Handle popup windows
    func webView(_ valuteCursWebView: WKWebView, didReceiveServerRedirectForProvisionalNavigation valuteCursNavigation: WKNavigation!) {
        // Handle redirects
    }
    
    func webView(_ valuteCursWebView: WKWebView, didStartProvisionalNavigation valuteCursNavigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.progress = 0.0
        }
    }
    
    func webView(_ valuteCursWebView: WKWebView, didCommit valuteCursNavigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.progress = 0.3
        }
    }
    
    func webView(_ valuteCursWebView: WKWebView, didFinish valuteCursNavigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.progress = 1.0
            
            // Update navigation state
            self.canGoBack = valuteCursWebView.canGoBack
            self.canGoForward = valuteCursWebView.canGoForward
            
            // Update current URL
            if let valuteCursCurrentUrl = valuteCursWebView.url?.absoluteString {
                self.currentUrl = valuteCursCurrentUrl
            }
            
            print("Navigation finished - canGoBack: \(self.canGoBack), canGoForward: \(self.canGoForward)")
        }
    }
    
    func webView(_ valuteCursWebView: WKWebView, didFail valuteCursNavigation: WKNavigation!, withError valuteCursError: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.progress = 0.0
        }
    }
    
    func webView(_ valuteCursWebView: WKWebView, didReceive valuteCursChallenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    // MARK: - Navigation Methods
    
    func goBack() {
        print("Coordinator: goBack called")
        valuteCursView?.goBack()
        // Update navigation state after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let valuteCursWebView = self.valuteCursView {
                self.canGoBack = valuteCursWebView.canGoBack
                self.canGoForward = valuteCursWebView.canGoForward
                print("Coordinator: Updated canGoBack: \(self.canGoBack), canGoForward: \(self.canGoForward)")
            }
        }
    }
    
    func goForward() {
        valuteCursView?.goForward()
        // Update navigation state after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let valuteCursWebView = self.valuteCursView {
                self.canGoBack = valuteCursWebView.canGoBack
                self.canGoForward = valuteCursWebView.canGoForward
            }
        }
    }
    
    func reload() {
        print("Coordinator: reload called")
        valuteCursView?.reload()
    }
    
    func loadUrl(_ urlString: String) {
        guard let valuteCursUrl = URL(string: urlString) else { return }
        let valuteCursRequest = URLRequest(url: valuteCursUrl)
        valuteCursView?.load(valuteCursRequest)
        
        // Reset navigation state
        DispatchQueue.main.async {
            self.canGoBack = false
            self.canGoForward = false
        }
    }
    
    // MARK: - WKUIDelegate
    
    func webView(_ valuteCursWebView: WKWebView, runJavaScriptAlertPanelWithMessage valuteCursMessage: String, initiatedByFrame valuteCursFrame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let valuteCursAlert = UIAlertController(title: "Alert", message: valuteCursMessage, preferredStyle: .alert)
        valuteCursAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        
        if let valuteCursWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let valuteCursWindow = valuteCursWindowScene.windows.first {
            valuteCursWindow.rootViewController?.present(valuteCursAlert, animated: true)
        }
    }
    
    func webView(_ valuteCursWebView: WKWebView, runJavaScriptConfirmPanelWithMessage valuteCursMessage: String, initiatedByFrame valuteCursFrame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let valuteCursAlert = UIAlertController(title: "Confirm", message: valuteCursMessage, preferredStyle: .alert)
        valuteCursAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        valuteCursAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        
        if let valuteCursWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let valuteCursWindow = valuteCursWindowScene.windows.first {
            valuteCursWindow.rootViewController?.present(valuteCursAlert, animated: true)
        }
    }
    
    func webView(_ valuteCursWebView: WKWebView, runJavaScriptTextInputPanelWithPrompt valuteCursPrompt: String, defaultText valuteCursDefaultText: String?, initiatedByFrame valuteCursFrame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let valuteCursAlert = UIAlertController(title: "Input", message: valuteCursPrompt, preferredStyle: .alert)
        valuteCursAlert.addTextField { valuteCursTextField in
            valuteCursTextField.text = valuteCursDefaultText
        }
        valuteCursAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        valuteCursAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let valuteCursText = valuteCursAlert.textFields?.first?.text
            completionHandler(valuteCursText)
        })
        
        if let valuteCursWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let valuteCursWindow = valuteCursWindowScene.windows.first {
            valuteCursWindow.rootViewController?.present(valuteCursAlert, animated: true)
        }
    }
}

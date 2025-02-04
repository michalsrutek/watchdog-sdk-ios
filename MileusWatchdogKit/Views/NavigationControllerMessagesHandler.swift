
import Foundation
import WebKit


final class NavigationControllerMessagesHandler {
    
    weak var webView: WebView?
    private weak var delegate: NavigationBarWebDelegate?
    
    init(delegate: NavigationBarWebDelegate?) {
        self.delegate = delegate
    }
    
    func getMessages() -> [WebViewMessage] {
        [
            getInfoIconVisibilityMessage(),
            getIntoIconTitleMessage()
        ]
    }
    
    private func getInfoIconVisibilityMessage() -> WebViewMessage {
        InfoIconVisibilityMessage(action: { [weak self] isVisible in
            if isVisible {
                self?.delegate?.setInfoButton(viewModel: InfoButtonViewModel(action: { [weak self] in
                    self?.webView?.inject(InfoButtonClickInjection())
                }))
            } else {
                self?.delegate?.setInfoButton(viewModel: nil)
            }
        })
    }
    
    private func getIntoIconTitleMessage() -> WebViewMessage {
        InfoIconTitleMessage { [weak self] title in
            self?.delegate?.setTitle(title: title)
        }
    }
    
}

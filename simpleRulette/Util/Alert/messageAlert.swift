//
//  Message.swift
//  recordDiet
//
//  Created by Kazuki Omori on 2023/01/03.
//

import UIKit
import SwiftMessages

class messageAlert {
    static var shared = messageAlert()
    
    private let window: UIWindow = {
        let window = UIWindow()
        window.backgroundColor = .clear
        window.isUserInteractionEnabled = false
        return window
    }()
    
    func showSuccessMessage(title: String, body: String) {
        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureTheme(.success)
        success.configureDropShadow()
        success.configureContent(title: title, body: body)
        success.button?.isHidden = true
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .top
        successConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        
        SwiftMessages.show(config: successConfig,view: success)
    }
    
    func showErrorMessage(title: String, body: String) {
        let error = MessageView.viewFromNib(layout: .cardView)
        error.configureTheme(.error)
        error.configureDropShadow()
        error.configureContent(title: title, body: body)
        error.button?.isHidden = true
        var errorConfig = SwiftMessages.defaultConfig
        errorConfig.presentationStyle = .top
        errorConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        
        SwiftMessages.show(config: errorConfig,view: error)
    }
}

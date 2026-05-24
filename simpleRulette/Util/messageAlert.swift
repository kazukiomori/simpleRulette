//
//  Message.swift
//  recordDiet
//
//  Created by Kazuki Omori on 2023/01/03.
//

import UIKit

class messageAlert {
    static var shared = messageAlert()

    func showSuccessMessage(title: String, body: String) {
        presentAlert(title: title, body: body)
    }
    
    func showErrorMessage(title: String, body: String) {
        presentAlert(title: title, body: body)
    }

    private func presentAlert(title: String, body: String) {
        guard let topViewController = topViewController() else {
            return
        }

        if topViewController.presentedViewController is UIAlertController {
            return
        }

        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default))
        topViewController.present(alertController, animated: true)
    }

    private func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
        let keyWindow = scenes
            .flatMap(\.windows)
            .first(where: \ .isKeyWindow)

        var topViewController = keyWindow?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}

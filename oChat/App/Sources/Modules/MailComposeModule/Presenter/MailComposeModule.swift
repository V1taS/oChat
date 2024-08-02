//
//  MailComposeModule.swift
//  oChat
//
//  Created by Vitalii Sosin on 02.08.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import UIKit
import MessageUI
import SKAbstractions

final class MailComposeModule: NSObject {
  
  // MARK: - Private variables
  
  private let services: IApplicationServices
  private var mailComposeViewController: MFMailComposeViewController?
  private var finishFlow: (() -> Void)?
  
  // MARK: - Initialization
  
  /// - Parameters:
  ///  - services: Сервисы приложения
  init(_ services: IApplicationServices) {
    self.services = services
  }
  
  func canSendMail() -> Bool {
    MFMailComposeViewController.canSendMail()
  }
  
  func start(completion: (() -> Void)?) {
    finishFlow = completion
    let mailComposeViewController = MFMailComposeViewController()
    self.mailComposeViewController = mailComposeViewController
    let systemService = services.userInterfaceAndExperienceService.systemService
    let appVersion = systemService.getAppVersion()
    let systemVersion = systemService.getSystemVersion()
    let systemName = systemService.getSystemName()
    let identifierForVendorText = "\("Идентийфикатор поставщика"): \(systemService.getDeviceIdentifier())"
    let systemVersionText = "\("Версия системы"): \(systemName) \(systemVersion)"
    let appVersionText = "\("Версия приложения"): \(appVersion)"
    let messageBody = """


      \(identifierForVendorText)
      \(systemVersionText)
      \(appVersionText)
"""
    
    mailComposeViewController.mailComposeDelegate = self
    mailComposeViewController.setToRecipients([Secrets.supportOChatMail])
    mailComposeViewController.setSubject("Поддержка приложения oChat")
    mailComposeViewController.setMessageBody(messageBody, isHTML: false)
    UIViewController.topController?.present(mailComposeViewController, animated: true)
  }
}

// MARK: - MFMailComposeViewControllerDelegate

extension MailComposeModule: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult,
                             error: Error?) {
    mailComposeViewController?.dismiss(
      animated: true,
      completion: { [weak self] in
        self?.finishFlow?()
        self?.mailComposeViewController = nil
      }
    )
  }
}

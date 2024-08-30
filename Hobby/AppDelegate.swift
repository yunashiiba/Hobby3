//
//  AppDelegate.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/12.
//

import UIKit
import UserNotifications
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        }
        
        if let customFont = UIFont(name: "ZenMaruGothic-Regular", size: 17) {
            UILabel.appearance().font = customFont
            UITextField.appearance().font = customFont
            UITextView.appearance().font = customFont
        }
        
        return true
    }

    // MARK: UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            completionHandler()
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let noticeViewController = storyboard.instantiateViewController(withIdentifier: "NoticeViewController") as? NoticeViewController {
            noticeViewController.modalPresentationStyle = .fullScreen
            
            if let rootViewController = window.rootViewController as? UINavigationController {
                rootViewController.pushViewController(noticeViewController, animated: true)
            } else {
                window.rootViewController?.present(noticeViewController, animated: true, completion: nil)
            }
        }
        
        completionHandler()
    }
}

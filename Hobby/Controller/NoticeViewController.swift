//
//  NoticeViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/05.
//

import UIKit
import RealmSwift

class NoticeViewController: UIViewController {
    let realm = try! Realm()
    
    @IBOutlet var miniView: UIView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var miniview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView(from: miniView)
        shadowButton(from: nextButton)
        
        let user = realm.objects(UserData.self)
        if user.count == 0 {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            return
        }else{
            try! realm.write {
                user[0].screen = 0
                user[0].lastcheck = Date()
            }
        }
        
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let japanTime = calendar.date(byAdding: .second, value: 0, to: now)!
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: japanTime)!
        let encounts = realm.objects(Encount.self).filter("encountDay >= %@", twentyFourHoursAgo)
        
        if encounts.count > 0{
            for i in 0...encounts.count-1{
                let anim = Animation()
                anim.walking(view: miniView, repeatCount: Int.random(in: 3...8), color: encounts[i].color)
            }
        }
    }
    
}


func noticeSet() {
    let realm = try! Realm()
    let user = realm.objects(UserData.self)
    if user.count == 0 {
        return
    }
    
    let now = Date()
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    let japanTime = calendar.date(byAdding: .second, value: 0, to: now)!
    
    let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: japanTime)!
    let recentRecords = realm.objects(Encount.self).filter("encountDay >= %@", twentyFourHoursAgo)
    
    //　通知設定に必要なクラスをインスタンス化
    let trigger: UNNotificationTrigger
    let content = UNMutableNotificationContent()
    var notificationTime = DateComponents()
    
    // トリガー設定
    notificationTime.hour = 19
    notificationTime.minute = 00
    trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime, repeats: true)
    
    // 通知内容の設定
    content.title = "タップして〜"
    content.sound = UNNotificationSound.default
    if recentRecords.count > 0{
        content.body = "今日は" + String(recentRecords.count) + "人と遭遇したよ"
    }else{
        content.body = "今日は遭遇しなかったよ"
    }
    
    // 通知スタイルを指定
    let request = UNNotificationRequest(identifier: "uuid", content: content, trigger: trigger)
    // 通知をセット
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // 既存の通知を削除
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

//
//  Notice2ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/15.
//

import UIKit
import RealmSwift

class Notice2ViewController: UIViewController {
    
    let realm = try! Realm()
    var nowtap = 0
    @IBOutlet var letterLabel: UILabel!
    @IBOutlet var miniView: UIView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    var recentRecords: Results<Encount>?
    var topHobbies: [String] = []
    var hobbies: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView(from: miniView)
        shadowButton(from: nextButton)
        shadowButton(from: backButton)
        
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let japanTime = calendar.date(byAdding: .second, value: 0, to: now)!
        
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: japanTime)!
        recentRecords = realm.objects(Encount.self).filter("encountDay >= %@", twentyFourHoursAgo)
        
        let user = realm.objects(UserData.self)
        if user.count > 0 {
            hobbies = [user[0].hobby1,user[0].hobby2,user[0].hobby3]
        }
        
        let encountHobbies = realm.objects(EncountHobby.self)
        
        if encountHobbies.count != 0{
            let hobbyCount = encountHobbies
                .reduce(into: [String: Int]()) { counts, encountHobby in
                    counts[encountHobby.hobby, default: 0] += 1
                }
            let sortedHobbies = hobbyCount.sorted { $0.value > $1.value }
            topHobbies = sortedHobbies.enumerated().map { _, element in element.key }
        }

        labelset()
    }
    
    func labelset(){
        let hobbiescount = 3 - hobbies.filter { $0.isEmpty }.count
        
        if nowtap < hobbiescount {
            let count = recentRecords!.filter("hobby == %@", hobbies[nowtap]).count
            letterLabel.text = "今日\n" + hobbies[nowtap] + "が好きな人と\n" + String(count) + "人すれちがったよ"
        }else{
            let user = realm.objects(UserData.self).first
            let todayencount = user!.todayencount
            
            if topHobbies.count > 0{
                if nowtap == hobbiescount{
                    letterLabel.text = "今までにすれ違った\n共通な趣味を持つ人達の趣味は\n1位" + topHobbies[0]
                }else if nowtap == hobbiescount + 1{
                    if topHobbies.count > 3{
                        letterLabel.text = "2位" + topHobbies[1] + "\n3位" + topHobbies[2] + "\n4位" + topHobbies[3] + "\nだよ"
                    }else{
                        letterLabel.text = "2位以下は今後見つけよう!だよ"
                    }
                }else{
                    letterLabel.text = "ちなみに今日アプリ持ってる人と\n" + String(todayencount) + "回すれちがったよ"
                }
            }else{
                letterLabel.text = "ちなみに今日アプリ持ってる人と\n" + String(todayencount) + "回すれちがったよ"
            }
        }
    }
    
    @IBAction func next(){
        let hobbiescount = 3 - hobbies.filter { $0.isEmpty }.count
        if topHobbies.count > 0{
            if nowtap == hobbiescount + 2 {
                performSegue(withIdentifier: "toNotice3", sender: self)
                return
            }
        } else {
            if nowtap == hobbiescount {
                performSegue(withIdentifier: "toNotice3", sender: self)
                return
            }
        }
        nowtap += 1
        labelset()
    }
    
    @IBAction func back(){
        if nowtap == 0{
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            return
        }
        nowtap -= 1
        labelset()
    }

}


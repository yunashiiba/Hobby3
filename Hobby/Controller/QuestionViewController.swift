//
//  QuestionViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/16.
//

import UIKit
import RealmSwift

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let realm = try! Realm()
    let saveData: UserDefaults = UserDefaults.standard
    
    @IBOutlet var miniview: UIView!
    @IBOutlet var miniminiview: UIView!
    
    var option = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView(from: miniview)
        shadowView(from: miniminiview)
        
        let user = realm.objects(UserData.self)
        if user.count > 0 {
            try! realm.write {
                user[0].screen = 0
            }
        }
        
        if saveData.object(forKey: "connect") != nil {
            if saveData.object(forKey: "connect") as! Int == 1 {
                option = 1
        }}
        
        segmentedControl.selectedSegmentIndex = option
    }
    
    @IBAction func openweb() {
        guard let url = URL(string: urlset()) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        saveData.set(sender.selectedSegmentIndex ,forKey: "connect")
    }

    @IBAction func back(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

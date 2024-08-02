//
//  ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/12.
//

import UIKit

class ViewController: UIViewController {
    
    let saveData: UserDefaults = UserDefaults.standard
    
    @IBOutlet var testLabel : UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        testLabel.text = "未ログイン"
        if saveData.object(forKey: "user_id") != nil {
            let user_id = saveData.object(forKey: "user_id") as! Int
            if user_id != 0 {
                testLabel.text = String(user_id)
                print("a")
        }}
    }
    
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
    }


}


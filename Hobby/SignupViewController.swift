//
//  SignupViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/25.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var alartLabel: UILabel!
    var results = ["","","","0","0","0","","","","#eeeeee"]
    var password = ""
    var userids : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isEnabled = false
        for view in self.view.subviews {
            if let textField = view as? UITextField {
                textField.delegate = self
            }
        }
        fetch(url:"request_userid") { userIds, error in
            if let error = error {
                print("Failed to fetch user IDs: \(error)")
                return
            }
            if let userIds = userIds {
                self.userids = userIds as! [String]
                print("User IDs: \(userIds)")
            } else {
                print("No user IDs found")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to Signup2" {
            let View2 = segue.destination as! Signup2ViewController
            View2.results = results
        }
    }
    
    @IBAction func unwindToSignup1(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? Signup2ViewController {
            results = sourceVC.results
            
            for i in 1...3 {
                if let textField = self.view.viewWithTag(i) as? UITextField {
                    textField.text = results[i-1]
                }
            }
        }
    }

    
    @IBAction func back(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz1234567890")
        let unwantedStr = textField.text!.trimmingCharacters(in: allowedCharacters)
        if textField.tag == 1{
            results[0] = textField.text!
            filein()
        }else if textField.tag == 2{
            if unwantedStr.count == 1 && unwantedStr.prefix(1) == "@" && textField.text!.count > 1 && userids.firstIndex(of:textField.text!) == nil{
                alartLabel.text = "いいね"
                results[1] = textField.text!
            } else {
                alartLabel.text = "よくないuseridです"
                results[1] = ""
            }
        }else if textField.tag == 3{
            if unwantedStr.count == 0 && textField.text!.count > 0 {
                alartLabel.text = "いいね"
                password = textField.text!
            } else {
                alartLabel.text = "よくないpasswordです"
            }
        }else if textField.tag == 4{
            if textField.text == password {
                alartLabel.text = "いいね"
                results[2] = textField.text!
            }else{
                alartLabel.text = "passwordが異なります"
                results[2] = ""
            }
        }
        filein()
    }
    
    func filein() {
        var filein = true
        for i in 0...2 {
            if results[i] == ""{
                filein = false
            }
        }
        if !filein {
            nextButton.isEnabled = false
        }else{
            nextButton.isEnabled = true
        }
    }
}



import Foundation

func fetch(url: String, completion: @escaping (Any?, Error?) -> Void) {
    guard let url = URL(string: "https://6d64-54-238-240-47.ngrok-free.app/" + url) else {
        print("Invalid URL")
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching data: \(error)")
            completion(nil, error)
            return
        }
        guard let data = data else {
            print("No data received")
            completion(nil, nil)
            return
        }
        if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            completion(jsonData, nil)
        } catch {
            print("Error decoding JSON: \(error)")
            completion(nil, error)
        }
    }
    
    task.resume()
}

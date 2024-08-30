//
//  SignupViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/25.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pass1Label: UILabel!
    @IBOutlet weak var pass2Label: UILabel!
    @IBOutlet weak var miniview: UIView!
    var results = ["","","","0","0","0","","","","#eeeeee"]
    var password = ""
    var userids : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTextFields(from: miniview)
        getAllTextFields(from: miniview)
        shadowButton(from: nextButton)
        miniview.layer.cornerRadius = 5

        nextButton.isEnabled = false
        for view in self.view.subviews {
            if let textField = view as? UITextField {
                textField.delegate = self
            }
        }
        connect()
    }
    
    func connect(){
        waitingAnimation(Motherview: self.view)
        fetch(url:"request_userid") { [self] userIds, error in
            DispatchQueue.main.async { [self] in
                if let error = error {
                    print("Failed to fetch user IDs: \(error)")
                    self.neterror()
                    return
                }
                if let userIds = userIds as? [String] {
                    self.userids = userIds
                    for _ in 0...3{
                        let remove = self.view.viewWithTag(100)
                        remove?.removeFromSuperview()
                    }
                    print("User IDs: \(userIds)")
                } else {
                    print("No user IDs found")
                    self.neterror()
                }
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
    
    func getTextFields(from view: UIView) {
        for subview in view.subviews {
            if let textField = subview as? UITextField {
                textField.delegate = self
            } else if !subview.subviews.isEmpty {
                getTextFields(from: subview)
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz1234567890")
        let unwantedStr = textField.text!.trimmingCharacters(in: allowedCharacters)
        if textField.tag == 1{
            results[0] = textField.text!
            filein()
        }else if textField.tag == 2{
            if unwantedStr.count == 1 && unwantedStr.prefix(1) == "@" && textField.text!.count > 1 && userids.firstIndex(of:textField.text!) == nil{
                userLabel.text = "OK!"
                results[1] = textField.text!
            }else if userids.firstIndex(of:textField.text!) != nil{
                userLabel.text = "そのidはもう使われているよ"
                results[1] = ""
            } else if unwantedStr.count == 0 || unwantedStr.prefix(1) != "@" {
                userLabel.text = "@で初めてね"
                results[1] = ""
            } else if unwantedStr.count > 1{
                userLabel.text = "英、数しか使えないよ"
                results[1] = ""
            }
        }else if textField.tag == 3{
            if unwantedStr.count == 0 {
                if textField.text!.count > 3 {
                    pass1Label.text = "OK!"
                    password = textField.text!
                } else {
                    pass1Label.text = "password四文字以上でお願い"
                }
            }else {
                pass1Label.text = "英数しか使えないよ"
            }
        }else if textField.tag == 4{
            if textField.text == password {
                pass2Label.text = "OK!"
                results[2] = textField.text!
            }else{
                pass2Label.text = "passwordが違うよ"
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
    
    func neterror() {
        for _ in 0...3 {
            let remove = self.view.viewWithTag(100)
            remove?.removeFromSuperview()
        }
        
        let alertView = UIAlertController(
            title: "エラー",
            message: "ネットワークエラーです",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        let reaction = UIAlertAction(title: "再読み込み", style: .default) { [weak self] _ in
            self?.connect()
        }
        alertView.addAction(action)
        alertView.addAction(reaction)
        
        DispatchQueue.main.async {
            self.present(alertView, animated: true, completion: nil)
        }
    }
}

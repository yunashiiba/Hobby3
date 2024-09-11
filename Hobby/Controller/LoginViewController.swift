//
//  LoginViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/31.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var loginlabel : UILabel!
    @IBOutlet var miniview: UIView!
    @IBOutlet var button: UIButton!
    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    
    let saveData: UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllTextFields(from: miniview)
        shadowButton(from: button)
        miniview.layer.cornerRadius = 5
        
        textField1.delegate = self
        textField2.delegate = self
        
        if let customFont = UIFont(name: "ZenMaruGothic-Regular", size: 20) {
            loginlabel.font = customFont
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func login() {
        connect()
    }
    
    @IBAction func back(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func connect() {
        waitingAnimation(Motherview: self.view)
        var datas: [String] = []
        for i in 1...2 {
            if let textField = self.view.viewWithTag(i) as? UITextField {
                datas.append(textField.text ?? "")
            }
        }
        
        guard let url = URL(string: urlset() + "request_login") else {
            neterror(id: 1)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(datas)
            request.httpBody = jsonData
        } catch {
            neterror(id: 1)
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if error != nil {
                DispatchQueue.main.async {
                    self.neterror(id: 1)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.neterror(id: 1)
                }
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                if let userdata = jsonData as? [[String]] {
                    DispatchQueue.main.async {
                        if userdata.count == 2 {
                            resetRealm()
                            toRealm(data: userdata[0])
                            toRealmEncount(data: userdata[1])
                            noticeSet()
                            self.saveData.set(1 ,forKey: "start")
                            self.performSegue(withIdentifier: "unwindToMain", sender: self)
                        } else if userdata.count == 1 {
                            self.neterror(id: 0)
                        } else {
                            self.neterror(id: 1)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.neterror(id: 1)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.neterror(id: 1)
                }
            }
        }
        task.resume()
    }

    
    func neterror(id: Int) {
        for _ in 0...3 {
            let remove = self.view.viewWithTag(100)
            remove?.removeFromSuperview()
        }
        
        var message = "ネットワークエラーです"
        if id == 0{
            message = "idかpasswordが違います"
        }
        
        let alertView = UIAlertController(
            title: "エラー",
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) {_ in
            if id != 0{
                self.performSegue(withIdentifier: "unwindToStart", sender: self)
            }
        }
        let reaction = UIAlertAction(title: "再読み込み", style: .default) {_ in
            self.connect()
        }
        alertView.addAction(action)
        
        if id != 0{
            alertView.addAction(reaction)
        }
        
        self.present(alertView, animated: true, completion: nil)
    }

}

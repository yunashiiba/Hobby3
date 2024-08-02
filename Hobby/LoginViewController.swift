//
//  LoginViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/31.
//

import UIKit

class LoginViewController: UIViewController {
    
    var userId = 0
    
    let saveData: UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func login(){
        connect()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func connect(){
        var datas:[String] = []
        for i in 1...2 {
            if let textField = self.view.viewWithTag(i) as? UITextField {
                datas.append(textField.text!)
            }
        }
        
        guard let url = URL(string: "https://6d64-54-238-240-47.ngrok-free.app/request_login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(datas)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user: \(error)")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let responseDict = try JSONDecoder().decode([String: Int].self, from: data)
                if let userId = responseDict["id"] {
                    print("Created User: \(userId)")
                    
                    DispatchQueue.main.async { [self] in
                        saveData.set(userId, forKey: "user_id")
                    }
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }
        task.resume()
    }

}

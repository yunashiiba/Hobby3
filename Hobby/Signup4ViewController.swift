//
//  Signup4ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/31.
//

import UIKit

class Signup4ViewController: UIViewController, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var colorView: UIView!
    var colorPicker = UIColorPickerViewController()
    var results : [String] = []
    
    let saveData: UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        colorPicker.delegate = self
        colorView.backgroundColor = UIColor(hex: results[9])
        colorView.isUserInteractionEnabled = true
        colorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeColor)))
    }
    
    @objc func changeColor() {
        colorPicker.supportsAlpha = true
        colorPicker.selectedColor = UIColor(hex: results[9])
        present(colorPicker, animated: true)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        colorView.backgroundColor = selectedColor
        results[9] = selectedColor.toHex()!
    }
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {}
    

    @IBAction func create(){
        var userId = 0
        
        guard let url = URL(string: "https://6d64-54-238-240-47.ngrok-free.app/request_usercreate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONEncoder().encode(results)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user: \(error)")
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToSignup3" {
            if let destinationVC = segue.destination as? Signup3ViewController {
                destinationVC.results = results
            }
        }
    }
    
    @IBAction func back(_ sender: UIStoryboardSegue) {
            performSegue(withIdentifier: "unwindToSignup3", sender: self)
        }

}

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        assert(hexString.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        return String(format: "#%02X%02X%02X",
                      Int(red * 255.0),
                      Int(green * 255.0),
                      Int(blue * 255.0))
    }
}

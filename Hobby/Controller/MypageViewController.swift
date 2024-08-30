//
//  MypageViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/31.
//

import UIKit
import Foundation
import RealmSwift

class MypageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIColorPickerViewControllerDelegate {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    
    @IBOutlet var colorView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var alartLabel: UILabel!
    
    let realm = try! Realm()
    
    var colorPicker = UIColorPickerViewController()
    var datas: [String] = []
    
    let countries = ["日本","中国","韓国","アメリカ","アジア","中東","欧州","アフリカ","北米","中南米","大洋州"]
    
    var buttons : [UIButton] = []
    var labels : [UILabel] = []
    
    var pickerrow = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            let label = self.view.viewWithTag(i+3) as! UILabel
            button.addTarget(self, action: #selector(MypageViewController.tap), for: .touchUpInside)
            buttons.append(button)
            labels.append(label)
        }
        
        colorPicker.delegate = self
        colorView.isUserInteractionEnabled = true
        colorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeColor)))
        
        let user = realm.objects(UserData.self)
        if user.count > 0 {
            datas = toData()
            labelset()
            hobbyset()
        }
    }
    
    @objc func changeColor() {
        colorPicker.supportsAlpha = true
        colorPicker.selectedColor = UIColor(hex: datas[4])
        present(colorPicker, animated: true)
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        colorView.backgroundColor = selectedColor
        datas[4] = selectedColor.toHex()!
    }
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {}
    
    
    @objc func tap(_ sender:UIButton) {
        datas[sender.tag + 5] = ""
        hobbyset()
    }
    
    @IBAction func namechange() {
        let alertView = UIAlertController(
            title: "名前を変更",
            message: "",
            preferredStyle: .alert)
        var textField: UITextField?
        alertView.addTextField { alertTextField in
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "OK", style: .default) { [self] _ in
            if textField?.text != nil && textField?.text != ""{
                datas[0] = (textField?.text)!
                labelset()
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alertView.addAction(action)
        alertView.addAction(cancelAction)
        present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func agechange(){
        sawalart(int: 2)
    }
    @IBAction func countrychange(){
        sawalart(int: 3)
    }
    
    func sawalart(int: Int){
        let alertView = UIAlertController(
            title: "選んでね",
            message: "\n\n\n\n\n\n\n\n\n",
            preferredStyle: .alert)
     
        let pickerView = UIPickerView(frame:
            CGRect(x: 0, y: 50, width: 350, height: 162))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(Int(datas[int])!, inComponent: 0, animated: false)
        pickerrow = datas[int]
        pickerView.tag = 10 + int
        alertView.view.addSubview(pickerView)
     
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { [self] _ in
           if pickerrow != ""{
               datas[int] = pickerrow
               labelset()
           }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)

        alertView.addAction(action)
        alertView.addAction(cancelAction)

        present(alertView, animated: true, completion: {
            pickerView.frame.size.width = alertView.view.frame.size.width
        })
    }
    
    func labelset(){
        nameLabel.text = datas[0]
        idLabel.text = datas[1]
        ageLabel.text = "年齢：" + String(datas[2]) + "0代"
        countryLabel.text = "住んでる国：" + countries[Int(datas[3])!]
        colorView.backgroundColor = UIColor(hex: datas[4])
    }
    
    func hobbyset(){
        let subArray = Array(datas[6...])
        let nonEmptyStrings = subArray.filter { !$0.isEmpty }
        let emptyStrings = subArray.filter { $0.isEmpty }
        let sortedSubArray = nonEmptyStrings + emptyStrings
        
        if nonEmptyStrings.count > 0{
            backButton.isEnabled = true
        }else{
            backButton.isEnabled = false
        }
        datas.replaceSubrange(6..., with: sortedSubArray)
        
        for i in 0...2{
            labels[i].text = datas[i+6]
            if labels[i].text != "" {
                buttons[i].isHidden = false
            }else{
                buttons[i].isHidden = true
            }
        }
    }
    
    @IBAction func back() {
        if toData() != datas{
            connect()
        }else{
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    
    func connect() {
        waitingAnimation(Motherview: self.view)
        guard let url = URL(string: urlset() + "request_userchange") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(datas)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user: \(error)")
            neterror()
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.neterror()
                }
                return
            }
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.neterror()
                }
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                if let userdata = jsonData as? [String] {
                    if userdata.count == 9 {
                        print("Received data: \(userdata)")
                        DispatchQueue.main.async {
                            toRealm(data: userdata)
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        print("Unexpected response count: \(userdata.count)")
                        DispatchQueue.main.async {
                            self.neterror()
                        }
                    }
                } else {
                    print("Failed to parse JSON")
                    DispatchQueue.main.async {
                        self.neterror()
                    }
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.neterror()
                }
            }
        }
        task.resume()
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
        
        let action = UIAlertAction(title: "OK", style: .default) {_ in
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        let reaction = UIAlertAction(title: "再読み込み", style: .default) {_ in
            self.connect()
        }
        alertView.addAction(action)
        alertView.addAction(reaction)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "to Mypage2" {
            let View2 = segue.destination as! Mypage2ViewController
            View2.datas = datas
        }
    }
    
    @IBAction func unwindToMypage(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? Mypage2ViewController {
            datas = sourceVC.datas
            labelset()
            hobbyset()
        }
    }
    
    @IBAction func logout(){
        resetRealm()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 12 {
            return 11
        } else{
            return countries.count
        }
    }
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        if pickerView.tag == 12 {
            return "\(row)0代"
        } else{
            return countries[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        pickerrow = "\(row)"
    }

}

//
//  ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/07/12.
//
//
//

import UIKit
import RealmSwift
import CoreBluetooth

class ViewController: UIViewController {
    
    var bluetoothManager: BluetoothManager!
    let realm = try! Realm()
    var userId = 0
    
    @IBOutlet var explanationLabel : UILabel!
    @IBOutlet var countLabel : UILabel!
    @IBOutlet var graphButton : UIButton!
    @IBOutlet var mapButton : UIButton!
    @IBOutlet var screenView : UIView!
    @IBOutlet var miniView: UIView!
    
    var nowhobby = 0
    var nowdisplay = 0
    var hobbies: [String] = []
    var hobbybuttons : [UIButton] = []
    var displaybuttons : [UIButton] = []
    
    var sortedHobbies: [(key: String, value: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        shadowView(from: miniView)
        shadowView(from: screenView)
        
        let user = realm.objects(UserData.self)
        if user.count == 0{
            performSegue(withIdentifier: "toStart", sender: self)
        }else{
            start()
        }
    }
    
    func start(){
        bluetoothManager = BluetoothManager()
        bluetoothManager.startScanning()
        
        NotificationCenter.default.addObserver(self, selector: #selector(encounting), name: NSNotification.Name(rawValue: "BluetoothMessageReceived"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let saveData: UserDefaults = UserDefaults.standard
        if saveData.object(forKey: "start") != nil {
            if saveData.object(forKey: "start") as! Int == 1 {
                start()
                saveData.set(0 ,forKey: "start")
        }}
        
        let user = realm.objects(UserData.self)
        if user.count == 0 {
            performSegue(withIdentifier: "toStart", sender: self)
        }else{
            userId = user[0].id
            hobbies = [user[0].hobby1,user[0].hobby2,user[0].hobby3]
            noticeSet()
            buttonset()
            labelset()
            ifnotice()
        }
    }
    
    @IBAction func tograph(){
        if nowdisplay == 0{
            performSegue(withIdentifier: "toGraphP", sender: self)
        }else{
            performSegue(withIdentifier: "toGraphH", sender: self)
        }
    }
    
    func labelset(){
        let explanationtext = ["すれ違った人達","すれ違った人達の趣味"]
        let graphText = ["グラフ","一覧"]
        let countText = ["人","個"]
        var count = 0
        explanationLabel.text = explanationtext[nowdisplay]
        graphButton.setTitle(graphText[nowdisplay], for: .normal)
        
        if nowdisplay == 0{
            mapButton.isHidden = false
            let encount = realm.objects(Encount.self).filter("hobby == %@", hobbies[nowhobby])
            count = encount.count
            bubbleset(encount: [("",0)])
        }else{
            mapButton.isHidden = true
            let encountHobbies = realm.objects(EncountHobby.self).filter("motherhobby == %@", hobbies[nowhobby])
            if encountHobbies.count != 0{
                let hobbyCount = encountHobbies
                    .reduce(into: [String: Int]()) { counts, encountHobby in
                        counts[encountHobby.hobby, default: 0] += 1
                    }
                sortedHobbies = hobbyCount.sorted { $0.value > $1.value }
            }else{
                sortedHobbies = []
            }
            count = sortedHobbies.count
            bubbleset(encount: sortedHobbies)
        }
        countLabel.text = "計" + String(count) + countText[nowdisplay]
    }
    
    
    func buttonset(){
        
        let hobbybutton = self.view.viewWithTag(nowhobby+1) as! UIButton
        hobbybutton.isSelected = true
        hobbybutton.backgroundColor = UIColor(hex: "#CBECFF")
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            if hobbies[i-1] == ""{
                button.isHidden = true
            }else{
                button.addTarget(self, action: #selector(ViewController.hobbytap), for: .touchUpInside)
                button.setTitle(hobbies[i-1], for: .normal)
                hobbybuttons.append(button)
            }
            shadowButton(from: button)
        }
        
        let displaybutton = self.view.viewWithTag(nowdisplay+4) as! UIButton
        displaybutton.isSelected = true
        displaybutton.backgroundColor = UIColor(hex: "#CBECFF")
        
        for i in 4...5 {
            let button = self.view.viewWithTag(i) as! UIButton
            button.addTarget(self, action: #selector(ViewController.displaytap), for: .touchUpInside)
            displaybuttons.append(button)
            shadowButton(from: button)
        }
    }
    
    func ifnotice(){
        let user = realm.objects(UserData.self)
        let currentDate = Date()
        if Calendar.current.component(.hour, from: currentDate) >= 19 {
            let fourHoursInSeconds: TimeInterval = 4 * 60 * 60
            let timeDifference = currentDate.timeIntervalSince(user[0].lastcheck)
            if timeDifference >= fourHoursInSeconds {
                try! realm.write{
                    user[0].screen = 2
                }
            }
        }else if Calendar.current.component(.hour, from: user[0].lastcheck) >= 19{
            let dayHoursInSeconds: TimeInterval = 24 * 60 * 60
            let timeDifference = currentDate.timeIntervalSince(user[0].lastcheck)
            if timeDifference >= dayHoursInSeconds {
                try! realm.write{
                    user[0].screen = 2
                }
            }
        }else if Calendar.current.component(.day, from: currentDate) != Calendar.current.component(.day, from: user[0].lastcheck){
            try! realm.write{
                user[0].screen = 2
            }
        }
        if user[0].screen == 2{
            performSegue(withIdentifier: "toNotice", sender: self)
        }
    }
    
    @objc func hobbytap(_ sender:UIButton) {
        if !sender.isSelected {
            hobbybuttons.forEach({element in
                element.isSelected = false
                element.backgroundColor = UIColor(hex: "#EDEFEE")
            })
            nowhobby = sender.tag - 1
        }
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? UIColor(hex: "#CBECFF") : UIColor(hex: "#EDEFEE")
        
        labelset()
    }
    
    @objc func displaytap(_ sender:UIButton) {
        if !sender.isSelected {
            displaybuttons.forEach({element in
                element.isSelected = false
                element.backgroundColor = UIColor(hex: "#EDEFEE")
            })
            nowdisplay = sender.tag - 4
        }
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? UIColor(hex: "#CBECFF") : UIColor(hex: "#EDEFEE")
        
        labelset()
    }
    
    func bubbleset(encount: [(key: String, value: Int)]){
        let maxCount = 30
        screenView.subviews.filter { $0.tag < 0 }.forEach { $0.removeFromSuperview() }
        
        if encount.count > 0{
            if encount[0].key == ""{
                let encounters = realm.objects(Encount.self).filter("hobby == %@", hobbies[nowhobby])
                let resultsArray = Array(encounters)
                let shuffledArray = resultsArray.shuffled()
                let selectedObjects = Array(shuffledArray.prefix(maxCount))
                for encounter in selectedObjects {
                    bubblecreate(type:0, color:encounter.color, id:encounter.id)
                }
            }else{
                let count = min(sortedHobbies.count, maxCount)
                for i in 0..<count {
                    bubblecreate(type: 1, color: "", id: i)
                }
            }
        }
    }
    
    func bubblecreate(type: Int, color: String, id: Int) {
        let bubbleView = UIView()
        var bubbleSize: CGFloat = 30.0
        if type == 1 && id < 10{
            bubbleSize = CGFloat(60 - (id * 3))
        }
        
        let bubbleX = CGFloat.random(in: 0...(screenView.bounds.width - bubbleSize))
        let bubbleY = CGFloat.random(in: 0...(screenView.bounds.height - bubbleSize))
        bubbleView.frame = CGRect(x: bubbleX, y: bubbleY, width: bubbleSize, height: bubbleSize)
        
        bubbleView.layer.cornerRadius = bubbleSize / 2
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth =  bubbleSize/30
        bubbleView.layer.borderColor = UIColor(hex: "#ffffff").cgColor
        bubbleView.tag = -1
        bubbleView.bubbleType = type
        bubbleView.bubbleColor = color
        bubbleView.bubbleId = id
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bubbleView.bounds
        var topColor = UIColor(red: 0.5, green: 0.5, blue: 0.8, alpha: 1).cgColor
        if type == 0 {
            if color != "" && color != "#ffffff"{
                topColor = UIColor(hex: color).cgColor
            }else{
                topColor = UIColor(hex: "#ffffff").cgColor
            }
        }
        let bottomColor = UIColor(hex: "#ffffff").cgColor
        let gradientColors: [CGColor] = [topColor, bottomColor]
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        bubbleView.layer.insertSublayer(gradientLayer, at: 0)
        
        let shineLayer = CAShapeLayer()
        let shinePath = UIBezierPath()
        shinePath.move(to: CGPoint(x: bubbleSize * 0.9, y: bubbleSize * 0.5))
        shinePath.addLine(to: CGPoint(x: bubbleSize * 0.8, y: bubbleSize * 0.7))
        shineLayer.path = shinePath.cgPath
        shineLayer.strokeColor = UIColor.white.cgColor
        shineLayer.lineWidth = bubbleSize/30
        
        bubbleView.layer.addSublayer(shineLayer)
        
        shinePath.move(to: CGPoint(x: bubbleSize * 0.72, y: bubbleSize * 0.77))
        shinePath.addLine(to: CGPoint(x: bubbleSize * 0.75, y: bubbleSize * 0.8))
        shineLayer.path = shinePath.cgPath
        
        bubbleView.layer.addSublayer(shineLayer)
        
        screenView.addSubview(bubbleView)
        
        animateBubble(bubbleView)
        
        addtapView()
        
    }
    
    func addtapView(){
        screenView.subviews.filter { $0.tag == -3 }.forEach { $0.removeFromSuperview() }
        let tapView = UIView()
        tapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        tapView.layer.borderColor = UIColor.white.withAlphaComponent(0).cgColor
        tapView.tag = -3
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bubbleTapped(_:)))
        tapView.addGestureRecognizer(tapGesture)
        tapView.isUserInteractionEnabled = true
        screenView.addSubview(tapView)
        
        view.bringSubviewToFront(graphButton)
        view.bringSubviewToFront(mapButton)
    }
    
    func animateBubble(_ bubbleView: UIView) {
        
        var newX: CGFloat = bubbleView.frame.origin.x
        var newY: CGFloat = bubbleView.frame.origin.y
        repeat {
            let randomX = CGFloat.random(in: -30...60)
            let randomY = CGFloat.random(in: -30...60)
            
            newX = bubbleView.frame.origin.x + randomX
            newY = bubbleView.frame.origin.y + randomY
        } while !self.isWithinBounds(x: newX, y: newY, bubbleView: bubbleView)
        let newPosition = CGPoint(x: newX, y: newY)
        
        
        
        UIView.animate(withDuration: TimeInterval(Float.random(in: 2...3)), delay: 0, options: [.curveEaseInOut], animations: {
            bubbleView.center = newPosition
        }, completion: { _ in
            self.animateBubble(bubbleView)
        })
    }
    
    func isWithinBounds(x: CGFloat, y: CGFloat, bubbleView: UIView) -> Bool {
        let maxX = self.screenView.bounds.width - bubbleView.bounds.width
        let maxY = self.screenView.bounds.height - bubbleView.bounds.height
        
        if x > maxX || x < 0 {
            return false
        }
        if y > maxY || y < 0 {
            return false
        }
        return true
    }
    
    @objc func bubbleTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: screenView)
        for bubble in screenView.subviews where bubble.tag == -1 {
            if let presentation = bubble.layer.presentation(),
               let _ = presentation.hitTest(point) {
                bubble.removeFromSuperview()
                animatecreate(width: presentation.frame.width, x: presentation.position.x-presentation.frame.width/2, y: presentation.position.y-presentation.frame.width/2,type: bubble.bubbleType!,id: bubble.bubbleId! ,color: bubble.bubbleColor!)
            }
        }
    }
    
    func animatecreate(width: CGFloat, x: CGFloat, y: CGFloat, type: Int, id: Int, color: String) {
        let nowhobby1 = nowhobby
        let nowdisplay1 = nowdisplay
        
        let bubbleView = UIView()
        bubbleView.frame = CGRect(x: x, y: y, width: width, height: width)
        bubbleView.layer.cornerRadius = width / 2
        bubbleView.tag = -1
        
        // CAShapeLayerを作成
        let shapeLayer = CAShapeLayer()
        let circlePath = UIBezierPath(ovalIn: bubbleView.bounds)
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = width/30
        
        // 点線のパターンを設定（[線の長さ, 間の長さ]）
        shapeLayer.lineDashPattern = [10, 5]
        bubbleView.layer.addSublayer(shapeLayer)
        
        screenView.addSubview(bubbleView)
        
        let animationGroup1 = CAAnimationGroup()
        animationGroup1.duration = 0.2
        animationGroup1.isRemovedOnCompletion = false
        animationGroup1.fillMode = CAMediaTimingFillMode.forwards
        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.toValue = 3
        animationGroup1.animations = [animation1]
        bubbleView.layer.add(animationGroup1, forKey: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){ [self] in
            bubbleView.removeFromSuperview()
            if nowdisplay1 == nowdisplay && nowhobby1 == nowhobby {
                
                let imageView = UIImageView()
                if type == 0{
                    imageView.image = UIImage(named: "people")
                }else{
                    imageView.image = UIImage(named: "heart")
                }
                imageView.frame = CGRect(x: x - width*CGFloat(2-type), y: y - width*CGFloat(2-type), width: width*CGFloat(5-type*2), height: width*CGFloat(5-type*2))
                imageView.tag = -(id + 2)
                screenView.addSubview(imageView)
                
                let label = UILabel()
                label.numberOfLines = 0
                label.textAlignment = .center
                if type == 0{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd"
                    let encounter = realm.objects(Encount.self).filter("id == %@", id).first
                    let dateKey = dateFormatter.string(from: encounter!.encountDay)
                    label.text = dateKey + "\nに会ったね"
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(usertap(_:)))
                    label.addGestureRecognizer(tapGesture)
                    label.isUserInteractionEnabled = true
                }else{
                    label.text = sortedHobbies[id].key + "\n\(sortedHobbies[id].value)人"
                }
                label.frame = CGRect(x: x - width*CGFloat(2-type), y: y - width*CGFloat(2-type), width: width*CGFloat(5-type*2), height: width*CGFloat(5-type*2))
                label.tag = -(id + 2)
                screenView.addSubview(label)
                
                let animationGroup1 = CAAnimationGroup()
                animationGroup1.duration = 0
                animationGroup1.isRemovedOnCompletion = false
                animationGroup1.fillMode = CAMediaTimingFillMode.forwards
                let animation1 = CABasicAnimation(keyPath: "transform.scale")
                animation1.toValue = 1/3
                animationGroup1.animations = [animation1]
                bubbleView.layer.add(animationGroup1, forKey: nil)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){ [self] in
            screenView.subviews.filter { $0.tag == -(id + 2) }.forEach { $0.removeFromSuperview() }
            if nowdisplay1 == nowdisplay && nowhobby1 == nowhobby {
                bubblecreate(type: type, color: color, id: id)
            }
        }
    }
    
    @objc func usertap(_ sender: UITapGestureRecognizer){
        let countries = ["日本","中国","韓国","アメリカ","アジア","中東","欧州","アフリカ","北米","中南米","大洋州"]
        
        if let label = sender.view as? UILabel{
            let id = -(label.tag + 2)
            if let encounter = realm.objects(Encount.self).filter("id == %@", id).first {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let dateKey = dateFormatter.string(from: encounter.encountDay)
                
                let hobbies = realm.objects(EncountHobby.self).filter("encount == %@", encounter.id)
                var hobbylabel = ""
                if hobbies.count == 0{
                    hobbylabel = "他にはないん"
                }else{
                    for hobby in hobbies{
                        hobbylabel += "、\(hobby.hobby)"
                    }
                }
                
                let alertView = UIAlertController(
                    title: dateKey,
                    message: "私の趣味は" + hobbylabel + "だよ\n私は" + countries[encounter.country] + "に住んでるよ",
                    preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "へえ", style: .cancel, handler: nil)
                
                alertView.addAction(cancelAction)
                present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGraphP"{
            let View2 = segue.destination as! GraphPViewController
            View2.hobbyst = hobbies[nowhobby]
        } else if segue.identifier == "toGraphH" {
            let View2 = segue.destination as! GraphHViewController
            View2.hobbyst = hobbies[nowhobby]
        } else if segue.identifier == "toMap" {
            let View2 = segue.destination as! MapViewController
            View2.hobbyst = hobbies[nowhobby]
        }else if segue.identifier == "toStart" {
            let View2 = segue.destination as! StartViewController
            View2.toQuestion = 1
        }
    }
    
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
    }
    
    @objc func encounting() {
        //会った時
    }
    
}


import ObjectiveC

private var typeKey: UInt8 = 0
private var idKey: UInt8 = 0
private var colorKey: UInt8 = 0
extension UIView {
    var bubbleType: Int? {
        get {return objc_getAssociatedObject(self, &typeKey) as? Int}
        set {objc_setAssociatedObject(self, &typeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var bubbleId: Int? {
        get {return objc_getAssociatedObject(self, &idKey) as? Int}
        set {objc_setAssociatedObject(self, &idKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    var bubbleColor: String? {
        get {return objc_getAssociatedObject(self, &colorKey) as? String}
        set {objc_setAssociatedObject(self, &colorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
}

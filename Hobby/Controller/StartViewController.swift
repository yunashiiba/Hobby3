//
//  StartViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/04.
//

import UIKit

class StartViewController: UIViewController {
    
    var toQuestion = 0
    @IBOutlet var signin: UIButton!
    @IBOutlet var login: UIButton!
    @IBOutlet var question: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.subviews.filter { $0.tag == -1 }.forEach { $0.removeFromSuperview() }
        for _ in 0...10{
            let randomColor = UIColor.randomYellowToBlue()
            bubblecreate(color: randomColor)
        }
        
        if let customFont = UIFont(name: "Savoye LET", size: 35) {
            signin.titleLabel?.font = customFont
            login.titleLabel?.font = customFont
            question.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        }
        
        if toQuestion == 1{
            performSegue(withIdentifier: "toQuestion", sender: self)
            toQuestion = 0
        }
    }
    
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {
    }
    
    func bubblecreate(color: UIColor) {
        let bubbleView = UIView()
        let bubbleSize: CGFloat = 30.0
        
        let bubbleX = CGFloat.random(in: 0...(self.view.bounds.width - bubbleSize))
        let bubbleY = CGFloat.random(in: 0...(self.view.bounds.height - bubbleSize))
        bubbleView.frame = CGRect(x: bubbleX, y: bubbleY, width: bubbleSize, height: bubbleSize)
        
        bubbleView.layer.cornerRadius = bubbleSize / 2
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth = bubbleSize / 30
        bubbleView.layer.borderColor = UIColor(hex: "#ffffff").withAlphaComponent(0.5).cgColor
        bubbleView.tag = -1
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bubbleView.bounds
        let topColor = color.withAlphaComponent(0.2).cgColor
        let bottomColor = UIColor.white.withAlphaComponent(0.5).cgColor
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
        shineLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
        shineLayer.lineWidth = bubbleSize / 30
        
        bubbleView.layer.addSublayer(shineLayer)
        
        shinePath.move(to: CGPoint(x: bubbleSize * 0.72, y: bubbleSize * 0.77))
        shinePath.addLine(to: CGPoint(x: bubbleSize * 0.75, y: bubbleSize * 0.8))
        shineLayer.path = shinePath.cgPath
        
        bubbleView.layer.addSublayer(shineLayer)
        
        self.view.addSubview(bubbleView)
    }

}

//
//  Animate.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/09/05.
//

import UIKit

class Animation {
    var nowposition = -1.0
    
    let walkposition1 = [[0,0,1,1],[0.5,1,0.5,2],[0.5,1,0,2],[0.5,1,1,2],[0.5,2,0,3],[0.5,2,1,2.5],[1,2.5,1,3]]
    let walkposition2 = [[0.5,0,1.5,1],[1,1,1,2],[1,1,1,2],[1,1,1,2],[1,2,1,3],[1,2,1,2.5],[1,2.5,1,3]]
    let walkposition3 = [[1,0,2,1],[1.5,1,1,2],[1.5,1,1.5,2],[1.5,1,1.5,2],[1,2,0.5,3],[1,2,1,2.5],[1,2.5,1,3]]
    let walkposition4 = [[2.5,1.5,3.5,2.5],[2.5,2,1.5,2],[2.5,2,1.5,2],[2.5,2,1.5,2],[1.5,2,1,3],[1.5,2,1,3],[1.5,2,1,3]]
    let walkposition5 = [[2.0,2,3,3],[3,2,2,2],[3,2,2,2],[3,2,2,2],[2,2,2,3],[2,2,2,3],[2,2,2,3]]

    func walking(view: UIView, repeatCount: Int, color: String) {
        let totalCount = repeatCount * 2
        let viewMinY = view.frame.origin.y
        
        let minY = viewMinY + 90
        let randomY = CGFloat.random(in: 0...400)
        
        let y = Double((randomY + minY) / 30)
        animateWalk(view: view, repeatCount: totalCount, currentCycle: 0, color: color, y: y)
    }

    private func animateWalk(view: UIView, repeatCount: Int, currentCycle: Int, color: String, y: Double) {
        if currentCycle == repeatCount {
            bubblecreate(color: color, x: (nowposition + 2)*30 ,y: (2 + y)*30, view: view)
            return
        }
        
        let fromPositions: [[Double]]
        let toPositions: [[Double]]
        
        var now = currentCycle % 2
        
        if currentCycle < repeatCount - 3 {
            fromPositions = (currentCycle % 2 == 0) ? walkposition1 : walkposition2
            toPositions = (currentCycle % 2 == 0) ? walkposition2 : walkposition1
        } else {
            now = 2
            if currentCycle == repeatCount - 3{
                nowposition += 1
                fromPositions = walkposition1
                toPositions = walkposition3
            }else if currentCycle == repeatCount - 2 {
                fromPositions = walkposition3
                toPositions = walkposition4
            }else{
                fromPositions = walkposition4
                toPositions = walkposition5
            }
        }
        
        if now != 2 && currentCycle % 2 == 1{
            nowposition += 1
        }
        
        walkstart(view: view, fromPositions: fromPositions, toPositions: toPositions, now: now, color:  color, yp: y) {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.animateWalk(view: view, repeatCount: repeatCount, currentCycle: currentCycle + 1, color: color, y: y)
            }
        }
    }

    private func walkstart(view: UIView, fromPositions: [[Double]], toPositions: [[Double]], now: Int, color: String, yp: Double , completion: @escaping () -> Void) {
        let size = 30.0
        var time = 0.3
        if now == 2 {
            time = 0.15
        }

        for i in 0..<fromPositions.count {
            if i == 0 {
                let aview = UIView()
                if now == 1{
                    aview.frame = CGRect(x: (fromPositions[i][0] + nowposition - 1) * size, y: (fromPositions[i][1] + yp) * size, width: size, height: size)
                }else{
                    aview.frame = CGRect(x: (fromPositions[i][0] + nowposition) * size, y: (fromPositions[i][1] + yp) * size, width: size, height: size)
                }
                aview.layer.cornerRadius = size / 2
                aview.backgroundColor = UIColor(hex: color)
                view.addSubview(aview)
                
                UIView.animate(withDuration: time, delay: 0, options: [.curveEaseInOut], animations: {
                    aview.frame = CGRect(x: (toPositions[i][0] + self.nowposition) * size, y: (toPositions[i][1] + yp) * size, width: size, height: size)
                }, completion: { _ in
                    aview.removeFromSuperview()
                })
                
            } else {
                let shineLayer = CAShapeLayer()
                let shinePath = UIBezierPath()
                if now == 1{
                    shinePath.move(to: CGPoint(x: (fromPositions[i][0] + nowposition - 1) * size, y: (fromPositions[i][1] + yp) * size))
                    shinePath.addLine(to: CGPoint(x: (fromPositions[i][2] + nowposition - 1) * size, y: (fromPositions[i][3] + yp) * size))
                }else{
                    shinePath.move(to: CGPoint(x: (fromPositions[i][0] + nowposition) * size, y: (fromPositions[i][1] + yp) * size))
                    shinePath.addLine(to: CGPoint(x: (fromPositions[i][2] + nowposition) * size, y: (fromPositions[i][3] + yp) * size))
                }
                shineLayer.path = shinePath.cgPath
                shineLayer.strokeColor = UIColor(hex: color).cgColor
                shineLayer.lineWidth = 3
                
                view.layer.addSublayer(shineLayer)
                
                let animation = CABasicAnimation(keyPath: "path")
                let newPath = UIBezierPath()
                newPath.move(to: CGPoint(x: (toPositions[i][0] + nowposition) * size, y: (toPositions[i][1] + yp) * size))
                newPath.addLine(to: CGPoint(x: (toPositions[i][2] + nowposition) * size, y: (toPositions[i][3] + yp) * size))
                
                animation.toValue = newPath.cgPath
                animation.duration = time
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                
                shineLayer.add(animation, forKey: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                    shineLayer.removeFromSuperlayer()
                }
            }
        }
        
        // アニメーション完了後の処理
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            completion()
        }
    }
    
    func bubblecreate(color: String, x: CGFloat ,y: CGFloat, view: UIView) {
        let bubbleView = UIView()
        let bubbleSize: CGFloat = 30.0
        
        bubbleView.frame = CGRect(x: x, y: y, width: bubbleSize, height: bubbleSize)
        
        bubbleView.layer.cornerRadius = bubbleSize / 2
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth =  bubbleSize/30
        bubbleView.layer.borderColor = UIColor(hex: "#ffffff").cgColor
        bubbleView.tag = -1
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bubbleView.bounds
        let topColor = UIColor(hex: color).cgColor
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
        
        view.addSubview(bubbleView)
    }
}


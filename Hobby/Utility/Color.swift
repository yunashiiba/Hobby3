//
//  Color.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/04.
//

import Foundation
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
    
    static func randomYellowToBlue() -> UIColor {
        let randomRed = CGFloat.random(in: 0...1)
        let randomGreen = CGFloat.random(in: 0...1)
        let randomBlue = CGFloat(1.0 - randomRed)
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

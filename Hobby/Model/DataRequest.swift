//
//  DataRequest.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/04.
//

import Foundation
import UIKit

func urlset() -> String{
    return "https://39f3-18-181-254-215.ngrok-free.app/"
}

func fetch(url: String, completion: @escaping (Any?, Error?) -> Void) {
    guard let url = URL(string: urlset() + url) else {
        print("Invalid URL")
        completion(nil, nil)
        return
    }

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 15
    let session = URLSession(configuration: config)
    
    let task = session.dataTask(with: url) { data, response, error in
        if let error = error as NSError? {
            // Check if the error is a timeout error
            if error.code == NSURLErrorTimedOut {
                print("Request timed out.")
            } else {
                print("Error fetching data: \(error.localizedDescription)")
            }
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
            print("Error decoding JSON: \(error.localizedDescription)")
            completion(nil, error)
        }
    }
    
    task.resume()
}


func waitingAnimation(Motherview: UIView) {
    let screenWidth:CGFloat = Motherview.frame.width
    let screenHeight:CGFloat = Motherview.frame.height
    
    let view = UIView()
    view.tag = 100
    view.frame = CGRect(x:0, y:0, width:screenWidth, height:screenHeight)
    view.backgroundColor = UIColor(white: 0, alpha: 0.3)
    Motherview.addSubview(view)
    
    for i in -1...1 {
        let circle = UIView()
        let xint = (Int(screenWidth) / 2) - i*30
        let yint = Int(screenHeight) / 2
        
        circle.tag = 100
        circle.backgroundColor = UIColor.white
        circle.layer.cornerRadius = 10
        circle.frame = CGRect(x:xint, y:yint, width:20, height:20)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double((i + 1))*0.2){
            UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse, .repeat]) {
                circle.alpha = 0
            }
        }
        Motherview.addSubview(circle)
    }
}

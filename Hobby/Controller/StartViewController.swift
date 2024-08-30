//
//  StartViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/04.
//

import UIKit

class StartViewController: UIViewController {
    
    var toQuestion = 0

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetRealm()
        
        if toQuestion == 1{
            performSegue(withIdentifier: "toQuestion", sender: self)
            toQuestion = 0
        }
    }
    
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {
    }

}

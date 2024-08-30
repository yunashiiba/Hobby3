//
//  GraphHViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/15.
//

import UIKit
import RealmSwift

class GraphHViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var hobbyst = ""
    @IBOutlet var tableView : UITableView!
    @IBOutlet var label : UILabel!
    var sortedHobbies: [(key: String, value: Int)] = []
    let realm = try! Realm()
    
    @IBOutlet var miniview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView(from: miniview)
        
        label.text = "すれちがった\n「" + hobbyst + "」\nが好きな人達の趣味"
        
        let encountHobbies = realm.objects(EncountHobby.self).filter("motherhobby == %@", hobbyst)
        
        if encountHobbies.count != 0{
            let hobbyCount = encountHobbies
                .reduce(into: [String: Int]()) { counts, encountHobby in
                    counts[encountHobby.hobby, default: 0] += 1
                }
            sortedHobbies = hobbyCount.sorted { $0.value > $1.value }
        }

        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    @IBAction func back(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedHobbies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        let hobby = sortedHobbies[indexPath.row]
        label.text =  "\(indexPath.row + 1)位 ： \(hobby.key) (\(hobby.value)人)"
        return cell
    }

}

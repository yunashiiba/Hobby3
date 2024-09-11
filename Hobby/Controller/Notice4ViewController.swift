//
//  Notice4ViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/16.
//

import UIKit
import RealmSwift
import MapKit

class Notice4ViewController: UIViewController, MKMapViewDelegate {
    
    let realm = try! Realm()
    var hobbies: [String] = []
    var hobbybuttons : [UIButton] = []
    var recentRecords: Results<Encount>?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var miniView: UIView!
    @IBOutlet var okButton: UIButton!
    
    var nowhobby = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowButton(from: okButton)
        miniView.layer.cornerRadius = 5
        
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let japanTime = calendar.date(byAdding: .second, value: 0, to: now)!
        
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: japanTime)!
        recentRecords = realm.objects(Encount.self).filter("encountDay >= %@", twentyFourHoursAgo)
        
        let user = realm.objects(UserData.self)
        hobbies = [user[0].hobby1, user[0].hobby2, user[0].hobby3]
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        buttonset()
        mapset()
    }
    
    func buttonset() {
        let hobbybutton = self.view.viewWithTag(1) as! UIButton
        hobbybutton.isSelected = true
        hobbybutton.backgroundColor = UIColor(hex: "#CBECFF")
        
        for i in 1...3 {
            let button = self.view.viewWithTag(i) as! UIButton
            if hobbies[i-1] == "" {
                button.isHidden = true
            } else {
                button.addTarget(self, action: #selector(hobbytap), for: .touchUpInside)
                button.setTitle(hobbies[i-1], for: .normal)
                hobbybuttons.append(button)
            }
            shadowButton(from: button)
        }
    }
    
    @objc func hobbytap(_ sender: UIButton) {
        if !sender.isSelected {
            hobbybuttons.forEach { element in
                element.isSelected = false
                element.backgroundColor = UIColor(hex: "#EDEFEE")
            }
            nowhobby = sender.tag - 1
        }
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? UIColor(hex: "#CBECFF") : UIColor(hex: "#EDEFEE")
        
        mapset()
    }
    
    func mapset(){
        let centerCoordinate = CLLocationCoordinate2D(latitude: 38, longitude: 138)
        let span = MKCoordinateSpan(latitudeDelta: 25.0, longitudeDelta: 25.0)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let encounters = recentRecords!.filter("hobby == %@", hobbies[nowhobby])
        for encounter in encounters {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(encounter.x), longitude: CLLocationDegrees(encounter.y))
            mapView.addAnnotation(annotation)
        }
    }

}

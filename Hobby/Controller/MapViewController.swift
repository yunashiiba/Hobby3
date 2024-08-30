//
//  MapViewController.swift
//  Hobby
//
//  Created by 椎葉友渚 on 2024/08/16.
//

import UIKit
import RealmSwift
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let realm = try! Realm()
    var hobbyst = ""
    
    @IBOutlet var label : UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var miniview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView(from: miniview)
        
        label.text = hobbyst + "\nが好きな人と会った位置"
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        mapset()
    }
    
    func mapset(){
        let centerCoordinate = CLLocationCoordinate2D(latitude: 38, longitude: 138)
        let span = MKCoordinateSpan(latitudeDelta: 25.0, longitudeDelta: 25.0)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let encounters = realm.objects(Encount.self).filter("hobby == %@", hobbyst)
        for encounter in encounters {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(encounter.x), longitude: CLLocationDegrees(encounter.y))
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            annotation.subtitle = dateFormatter.string(from: encounter.encountDay)
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func back(){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

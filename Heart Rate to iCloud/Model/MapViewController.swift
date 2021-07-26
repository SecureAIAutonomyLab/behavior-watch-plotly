//
//  MapViewController.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 7/15/21.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var latLabel: UILabel!
    @IBOutlet var longLabel: UILabel!
    let locationManager = CLLocationManager()
    let longitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[1]
    let latitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.layer.cornerRadius = 14
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        latLabel.text = ("LAT: \(latitude)")
        longLabel.text = ("LONG: \(longitude)")
        mapView.showsUserLocation = true
    }
}

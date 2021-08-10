//
//  MapViewController.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 7/15/21.
//

import UIKit
import MapKit
import CoreLocation

/// DESCRIPTION: The MapViewController class handles the creation of the map view page that shows the user's current location. The user's coordinates in decimal degrees are shown at the top of the view in decimal degrees. A navigation view is also created at the bottom so that the user can navigate back to other interfaces.
class MapViewController: UIViewController {
    
    // MARK: Data roperties
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var latLabel: UILabel!
    @IBOutlet var longLabel: UILabel!
    let locationManager = CLLocationManager()
    let longitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[1]
    let latitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[2]
    
    // MARK: Init
    /// DESCRIPTION: Called when the view first loads up, the navigation view is given a corner radius of 14 pixels. The location accuracy is set to the highest setting, the distance filter for the location is removed, and the location begins to update. The longitude and latitude labels at the top of the interface present the user's coordinates and the mapView is told to present the user's location as a blue dot on the map.
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

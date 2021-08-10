//
//  Accelerometer View Controller.swift
//  Heart Rate to iCloud WatchKit Extension
//
//  Created by vctrg on 4/23/21.
//

import Foundation
import WatchKit
import HealthKit
import WatchConnectivity
import CoreMotion
import Combine
import CoreLocation

/// DESCRIPTION: This class is responsible for showing the user the accelerometer axis diagram for the Apple Watch and displaying the UUID of the device on the top of the screen.
class AccelerometerInterfaceController: WKInterfaceController {
    
    // MARK: Data Properties
    @IBOutlet var userNameLabel: WKInterfaceLabel!
    let userDefaultsVitals = UserDefaults.standard
//    Access Shared Defaults Object
    var monitor = false

    //MARK: Init
    /// DESCRIPTION: Called when the view first loads up.
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    /// DESCRIPTION: Called when the view is about to be visible and displays the UUID of the device at the top of the screen.
    override func willActivate() {
        super.willActivate()
        userNameLabel.setText(userDefaultsVitals.string(forKey: "User Name"))
    }
    
    /// DESCRIPTION: Called when the view is no longer visible to the user.
    override func didDeactivate() {
        super.didDeactivate()
    }
}

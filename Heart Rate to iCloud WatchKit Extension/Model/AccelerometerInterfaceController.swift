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

class AccelerometerInterfaceController: WKInterfaceController {
    
    @IBOutlet var userNameLabel: WKInterfaceLabel!
    @IBOutlet weak var currentTimeStamp: WKInterfaceDate!
    
    
    let motion = CMMotionManager()
    let session = WCSession.default //Apple Watch Session variable
    let userDefaultsVitals = UserDefaults.standard
//    Access Shared Defaults Object
    var monitor = false
    var timer = Timer.init()
    var workoutSession: HKWorkoutSession? // //workout session var

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        userNameLabel.setText(userDefaultsVitals.string(forKey: "User Name"))
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}

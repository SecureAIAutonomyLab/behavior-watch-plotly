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
    
    @IBOutlet var xLabel: WKInterfaceLabel!
    @IBOutlet var yLabel: WKInterfaceLabel!
    @IBOutlet var zLabel: WKInterfaceLabel!
    @IBOutlet var userNameLabel: WKInterfaceLabel!
    @IBOutlet var accelerationButton: WKInterfaceButton!
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
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        super.willActivate()
        userNameLabel.setText(userDefaultsVitals.string(forKey: "User Name"))
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func monitorAcclerations() {
        
        if monitor == false{
            monitor = true
            startWorkout()
            startAccelerometers()
            accelerationButton.setTitle("Stop")
        }
        else{
            monitor = false
            
            timer.invalidate()
            xLabel.setText("--")
            yLabel.setText("--")
            zLabel.setText("--")
            let result = "Stop Pressed"
            let data: [String: Any] = ["Stop Pressed": result as Any]
            self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            accelerationButton.setTitle("Monitor Acceleration")
        }
    }
    
    func startAccelerometers() {
       // Make sure the accelerometer hardware is available.
       if motion.isAccelerometerAvailable && monitor == true {
        self.motion.accelerometerUpdateInterval = 1.0 / 5.0  // 5 Hz
          self.motion.startAccelerometerUpdates()

          // Configure a timer to fetch the data.
        self.timer = Timer(fire: Date(), interval: (1.0/5.0),
                repeats: true, block: { (timer) in
             // Get the accelerometer data.
             if let data = self.motion.accelerometerData {
                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
                let xRound = Double(round(1000*x)/1000)
                let yRound = Double(round(1000*y)/1000)
                let zRound = Double(round(1000*z)/1000)
                let resultantAccel = sqrt(Double(Int(xRound)^2) + Double(Int(yRound)^2) + Double(Int(zRound)^2))
                self.xLabel.setText("\(xRound) g's")
                self.yLabel.setText("\(yRound) g's")
                self.zLabel.setText("\(zRound) g's")
//                let timeStamp = self.xLabel.value(forKey: String)
//                print(timeStamp)
//                let xyzArray = [xRound, yRound, zRound]
                let resultantXYZ: [String: Any] = ["Resultant": resultantAccel as Any]
                self.session.sendMessage(resultantXYZ, replyHandler: nil, errorHandler: nil)
                // Use the accelerometer data in your app.
             }
          })

          // Add the timer to the current run loop.
        RunLoop.current.add(self.timer, forMode: .default)
       }
    }
    
    func startWorkout() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking
        workoutConfiguration.locationType = .indoor
        
        do {
            if workoutSession == nil {
                workoutSession = try HKWorkoutSession(healthStore: HealthDataManager.sharedInstance.healthStore!, configuration: workoutConfiguration)
                workoutSession?.startActivity(with: Date())
            }
        } catch {
            print("Error starting workout session: \(error.localizedDescription)")
        }
    }
    
    func stopWorkout() {
        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
        workoutSession = nil
    }
    
//    class func getDateOnly(fromTimeStamp timestamp: TimeInterval) -> String {
//      let dayTimePeriodFormatter = DateFormatter()
//      dayTimePeriodFormatter.timeZone = TimeZone.current
//      dayTimePeriodFormatter.dateFormat = "zMMMM/dd/yyyy HH:mm:ss:"
//      return dayTimePeriodFormatter.string(from: Date(timeIntervalSinceNow: timestamp))
//    }
//
//    func returnFinalTimeStamp() -> String {
//        let timeStamp = AccelerometerInterfaceController.getDateOnly(fromTimeStamp: 0.0)
//    //    set variable to return timestamp variable
//        var currentTime: Double
//        currentTime =
//        let truncatedMilliseconds = currentTime.truncatingRemainder(dividingBy: 1)
//        let finalMilliseconds = Int(truncatedMilliseconds * 1000)
//        let finalTimeStamp = "\(timeStamp)\(finalMilliseconds)"
//        return(finalTimeStamp)
//    }
}

extension AccelerometerInterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    }
    
}



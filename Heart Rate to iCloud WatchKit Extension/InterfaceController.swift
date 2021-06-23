//
//  InterfaceController.swift
//  Heart Rate to iCloud WatchKit Extension
//
//  Created by vctrg on 2/6/21.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity
import CoreMotion
import UserNotifications


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var heartRate: WKInterfaceLabel!
    @IBOutlet var SPO2Label: WKInterfaceLabel!
    @IBOutlet var noiseExposLabel: WKInterfaceLabel!
    @IBOutlet var sleepLabel: WKInterfaceLabel!
    @IBOutlet var workoutButton: WKInterfaceButton!
    @IBOutlet var timerLength: WKInterfaceLabel!
    @IBOutlet var IDNameLabel: WKInterfaceLabel!
    @IBOutlet var longitudeLabel: WKInterfaceLabel!
    @IBOutlet var latitudeLabel: WKInterfaceLabel!
    @IBOutlet var monitoringTimer: WKInterfaceTimer!
    @IBOutlet var xLabel: WKInterfaceLabel!
    @IBOutlet var yLabel: WKInterfaceLabel!
    @IBOutlet var zLabel: WKInterfaceLabel!
    @IBOutlet weak var resultantLabel: WKInterfaceLabel!
    @IBOutlet var uploadDataButton: WKInterfaceSwitch!
    @IBOutlet var uploadXYZButton: WKInterfaceSwitch!
    @IBOutlet var uploadResultantButton: WKInterfaceSwitch!
    
    let userDefaultsVitals = UserDefaults.standard
    //    Access Shared Defaults Object
    var timer2 = Timer.init()
    var timer3 = Timer.init()
    var workoutSession: HKWorkoutSession? // //workout session var
    var watchSession = WCSession.default //watch session variable
    var monitorVitals = false //button checker variable
    let session = WCSession.default //Apple Watch Session variable
    let motion = CMMotionManager()
    var timer = Timer() //timer variable
    var timerAccel = Timer.init()//timer variable for accelerometer
    let workoutTimes = ["30sec": 30, "3min": 180, "30min": 1800, "1hr": 3600, "10hr": 36000, "1day": 86400]
    var secondsPassed = 0
    var totalTime = 0
    var userName: String!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        heartRate.setText("--")
        SPO2Label.setText("--")
        noiseExposLabel.setText("--")
        sleepLabel.setText("--")
        longitudeLabel.setText("--")
        latitudeLabel.setText("--")
        resultantLabel.setText("--")
        timerLength.setText("Pick Time")
        uploadDataButton.setColor(#colorLiteral(red: 0.93564713, green: 0.2231650352, blue: 0.1551090479, alpha: 1))
        uploadXYZButton.setColor(#colorLiteral(red: 0.93564713, green: 0.2231650352, blue: 0.1551090479, alpha: 1))
        uploadResultantButton.setColor(#colorLiteral(red: 0.93564713, green: 0.2231650352, blue: 0.1551090479, alpha: 1))
        session.delegate = self
        session.activate()
        IDNameLabel.setText(userDefaultsVitals.string(forKey: "User Name"))
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        IDNameLabel.setText(userDefaultsVitals.string(forKey: "User Name"))
        if WCSession.isSupported() {
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        IDNameLabel.setText(userDefaultsVitals.string(forKey: "User Name"))
        super.didDeactivate()
    }
    
    @IBAction func didTapStartStopWorkout() {
        
        if(workoutSession == nil) {
            startWorkout()
            monitorVitals = true
            
            
        } else {
            stopWorkout()
            monitorVitals = false
            timer.invalidate()
            monitoringTimer.stop()
            monitoringTimer.setDate(.init(timeIntervalSinceNow: 0))
            timerLength.setText("Pick Time")
            timerLength.setTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            
            
        }
        if monitorVitals == true{
            startAccelerometers()
            startWorkout()
            monitorHeartRate()
            monitorSPO2()
            monitorNoise()
            monitorSleep()
            getLocation()
            let result1 = "Start Pressed"
            let data1: [String: Any] = ["Start Pressed": result1 as Any]
            self.session.sendMessage(data1, replyHandler: nil, errorHandler: nil)
        }
        else if monitorVitals == false{
            stopWorkout()
            timer2.invalidate()
            xLabel.setText("--")
            yLabel.setText("--")
            zLabel.setText("--")
            heartRate.setText("--")
            SPO2Label.setText("--")
            noiseExposLabel.setText("--")
            sleepLabel.setText("--")
            longitudeLabel.setText("--")
            latitudeLabel.setText("--")
            resultantLabel.setText("--")
            let result = "Stop Pressed"
            let data: [String: Any] = ["Stop Pressed": result as Any]
            self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            
        }
        
        
    }
    @IBAction func thirtySeconds() {
        let time = Double(workoutTimes["30sec"]!)
        timer.invalidate()
        timer2.invalidate()
        monitoringTimer.stop()
        timerLength.setText("30 Seconds")
        timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
        monitoringTimer.setDate(.init(timeIntervalSinceNow: 30))
        monitoringTimer.start()
        startAccelerometers()
        
        
    }
    @IBAction func threeMinutes() {
        let time2 = Double(workoutTimes["3min"]!)
        timer.invalidate()
        timer2.invalidate()
        monitoringTimer.stop()
        timerLength.setText("3 Minutes")
        timer = Timer.scheduledTimer(timeInterval: time2, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
        monitoringTimer.setDate(.init(timeIntervalSinceNow: 180))
        monitoringTimer.start()
        startAccelerometers()
        
    }
    @IBAction func thirtyMinutes() {
        let time3 = Double(workoutTimes["30min"]!)
        timer.invalidate()
        timer2.invalidate()
        monitoringTimer.stop()
        timerLength.setText("30 Minutes")
        timer = Timer.scheduledTimer(timeInterval: time3, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
        monitoringTimer.setDate(.init(timeIntervalSinceNow: 1800))
        monitoringTimer.start()
        startAccelerometers()
        
    }
    @IBAction func oneHour() {
        let time4 = Double(workoutTimes["1hr"]!)
        timer.invalidate()
        timer2.invalidate()
        monitoringTimer.stop()
        timerLength.setText("1 Hour")
        timer = Timer.scheduledTimer(timeInterval: time4, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
        monitoringTimer.setDate(.init(timeIntervalSinceNow: 3600))
        monitoringTimer.start()
        startAccelerometers()
        
    }
    @IBAction func tenHours() {
        let time5 = Double(workoutTimes["10hr"]!)
        timer.invalidate()
        timer2.invalidate()
        monitoringTimer.stop()
        timerLength.setText("10 Hours")
        timer = Timer.scheduledTimer(timeInterval: time5, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
        monitoringTimer.setDate(.init(timeIntervalSinceNow: 36000))
        monitoringTimer.start()
        startAccelerometers()
        
    }
    @IBAction func oneDay() {
        let time6 = Double(workoutTimes["1day"]!)
        timer.invalidate()
        timer2.invalidate()
        monitoringTimer.stop()
        timerLength.setText("1 Day")
        timer = Timer.scheduledTimer(timeInterval: time6, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
        monitoringTimer.setDate(.init(timeIntervalSinceNow: 86400))
        monitoringTimer.start()
        startAccelerometers()
        
    }
    @IBAction func uploadSwitch(_ value: Bool) {
    }
    
    @objc func updateCounter() { //update the timer so that the timer counts up
        //example functionality
        if secondsPassed < totalTime {
            //only activates when the timer has started counting down
            
            secondsPassed += 1
            monitorVitals = true
            startAccelerometers()
            // make the seconds passed count up to the total time
            
            //            let percentageProgress = Float(secondsPassed) / Float(totalTime)
            //algorithim for calculating the percent of the time that has passed as a float
            
            //            progressBar.progress = percentageProgress
            //make the percent of time passed as a decimal equal to the progress bar value
        }
        else {
            
            timer.invalidate()
            monitoringTimer.stop()
            monitoringTimer.setDate(.init(timeIntervalSinceNow: 0))
            stopWorkout()
            timer2.invalidate()
            monitorVitals = false
            //reset the timer when the timer ends
            //                playSound()
            //activate the alarm
            timerLength.setText("DONE!")
            timerLength.setTextColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
            heartRate.setText("--")
            SPO2Label.setText("--")
            noiseExposLabel.setText("--")
            sleepLabel.setText("--")
            longitudeLabel.setText("--")
            latitudeLabel.setText("--")
            xLabel.setText("--")
            yLabel.setText("--")
            zLabel.setText("--")
            resultantLabel.setText("--")
            let result = "Notification"
            let data: [String: Any] = ["Notification": result as Any]
            self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            
            //change the title to say DONE!
            
        }
    }
    
    func stopWorkout() {
        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
        workoutSession = nil
        
        workoutButton.setTitle("Monitor ∞sec")
    }
    
    func startWorkout() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking
        workoutConfiguration.locationType = .indoor
        
        do {
            if workoutSession == nil {
                workoutSession = try HKWorkoutSession(healthStore: HealthDataManager.sharedInstance.healthStore!, configuration: workoutConfiguration)
                workoutSession?.startActivity(with: Date())
                startAccelerometers()
                workoutButton.setTitle("Stop")
                heartRate.setText("--")
                SPO2Label.setText("--")
                noiseExposLabel.setText("--")
                sleepLabel.setText("--")
                longitudeLabel.setText("--")
                latitudeLabel.setText("--")
                xLabel.setText("--")
                yLabel.setText("--")
                zLabel.setText("--")
                resultantLabel.setText("--")
            }
        } catch {
            print("Error starting workout session: \(error.localizedDescription)")
        }
    }
    
    func monitorHeartRate() {
        HealthDataManager.sharedInstance.observeHeartRateSamples {
            (heartRate) -> (Void) in
            if self.monitorVitals == true {
                let heartBeatValue = String(format: "%.0f", heartRate)
                self.heartRate.setText("\(heartBeatValue) BPM")
                let data: [String: Any] = ["hr": String(heartRate) as Any]
                self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            }
            else if self.monitorVitals == false {
                self.heartRate.setText("--")
            }
        }
    }
    // monitor Blood Oxygen Saturation(SPO2) directly from apple watch
    func monitorSPO2(){
        //retrieve SPO2 value from health data manager class
        HealthDataManager.sharedInstance.observeSPO2Samples { (SPO2) -> (Void) in
            //check if user wants to monitor vitals
            if self.monitorVitals == true {
                //            print("SPO2 Sample: \(SPO2*100)")
                //convert SPO2 value into string
                let SPO2Value = String(format: "%.0f", SPO2*100,"%")
                //set watch's SPO2 label to the SPO2 value with % added for value type indication
                self.SPO2Label.setText("\(SPO2Value)%")
                // define data as spo2 value with prefix key "spo2" for future data parsing
                let data: [String: Any] = ["spo2": String(SPO2*100) as Any]
                //send data to companion app so that it can published to cloud services
                self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            }
            //what to do if user decided to quit monitoring vitals
            else if self.monitorVitals == false{
                // set SPO2 to nil value
                self.SPO2Label.setText("--")
                //            print("No SPO2 Monitoring")
            }
        }
    }
    
    func monitorNoise(){
        HealthDataManager.sharedInstance.observeEnvAudioSamples { (NoiseEX) -> (Void) in
            if self.monitorVitals == true{
                print("NoiseEX Sample: \(NoiseEX)")
                let LTNEValue = String(format: "%.0f", NoiseEX)
                self.noiseExposLabel.setText("\(LTNEValue) dB")
                
                let data: [String: Any] = ["NoiseEx": String(format: "%.0f", NoiseEX) as Any]
                self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            }
            else if self.monitorVitals == false{
                self.noiseExposLabel.setText("--")
                print("No Noise Expos Monitoring ")
            }
        }
    }
    
    func monitorSleep() {
        if self.monitorVitals == true{
            HealthDataManager.sharedInstance.retrieveSleepWithAuth { result -> Void in
                if self.monitorVitals == true{
                    DispatchQueue.main.async {
                        let finalResult = String(Int(result / 3600)) + "h " +
                            String(Int(result.truncatingRemainder(dividingBy: 3600) / 60)) + "m " +
                            String(Int(result.truncatingRemainder(dividingBy: 3600)
                                        .truncatingRemainder(dividingBy: 60))) + "s"
                        self.sleepLabel.setText(finalResult)
                        let data: [String: Any] = ["SleepTime": result as Any]
                        self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                    }
                }
                else if self.monitorVitals == false{
                    self.noiseExposLabel.setText("--")
                }
            }
        }
    }
    
    func getLocation() {
        let longitude = HealthDataManager.sharedInstance.requestLongitude()
        let latitude = HealthDataManager.sharedInstance.requestLatitude()
        longitudeLabel.setText(longitude)
        latitudeLabel.setText(latitude)
    }
    
    func checkUserRequest(){
        if(workoutSession == nil) {
            startWorkout()
            monitorVitals = true
        } else {
            stopWorkout()
        }
        if monitorVitals == true{
            startWorkout()
            monitorHeartRate()
            monitorSPO2()
            monitorNoise()
            monitorSleep()
            getLocation()
        }
        else if monitorVitals == false{
            stopWorkout()
            heartRate.setText("--")
            SPO2Label.setText("--")
            noiseExposLabel.setText("--")
            sleepLabel.setText("--")
            longitudeLabel.setText("--")
            latitudeLabel.setText("--")
            resultantLabel.setText("--")
        }
    }
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if motion.isAccelerometerAvailable && monitorVitals == true {
            self.motion.accelerometerUpdateInterval = 1.0 / 10.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            
            // Configure a timer to fetch the data.
            self.timer2 = Timer(fire: Date(), interval: (1.0/10.0),
                                repeats: true, block: { (timer) in
                                    // Get the accelerometer data.
                                    if let data = self.motion.accelerometerData {
                                        let x = data.acceleration.x
                                        let y = data.acceleration.y
                                        let z = data.acceleration.z
                                        let xRound = Double(round(1000*x)/1000)
                                        let yRound = Double(round(1000*y)/1000)
                                        let zRound = Double(round(1000*z)/1000)
                                        print(xRound)
                                        print(yRound)
                                        print(zRound)
                                        self.xLabel.setText("\(xRound) g's")
                                        self.yLabel.setText("\(yRound) g's")
                                        self.zLabel.setText("\(zRound) g's")
                                        //                let timeStamp = self.xLabel.value(forKey: String)
                                        let resultantAccel = sqrt(pow(xRound,2) + pow(yRound,2) + pow(zRound,2))
                                        let resultantRound = Double(round(1000*resultantAccel)/1000)
                                        self.resultantLabel.setText("\(resultantRound)")
                                        let xyzArray = [xRound, yRound, zRound]
                                        let XYZ: [String: Any] = ["Array": xyzArray as Any]
                                        let resultantXYZ: [String: Any] = ["Resultant": resultantAccel as Any]
                                        //                self.session.sendMessage(resultantXYZ, replyHandler: nil, errorHandler: nil)
                                        self.session.sendMessage(XYZ, replyHandler: nil, errorHandler: nil)
                                        self.session.sendMessage(resultantXYZ, replyHandler: nil, errorHandler: nil)
                                        // Use the accelerometer data in your app.
                                    }
                                })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer2, forMode: .default)
        }
    }
}

extension InterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        DispatchQueue.main.async {
            if let IDLabel = message["Name Label"] as? String {
                self.IDNameLabel.setText("\(IDLabel)")
                self.userDefaultsVitals.set(IDLabel, forKey: "User Name")
            }
        }
        DispatchQueue.main.async {
            if let longitude = message["Longitude"] as? String {
                self.longitudeLabel.setText(longitude)
            }
            if let latitude = message["Latitude"] as? String {
                self.latitudeLabel.setText(latitude)
            }
        }
        
        DispatchQueue.main.async {
            if let dataSwitchCheck = message["Data Switch Check"] as? String {
                if dataSwitchCheck == "ON" {
                    self.uploadDataButton.setOn(true)
                    self.userDefaultsVitals.setValue(true, forKey: "Upload Data Button")
                }
                if dataSwitchCheck == "OFF" {
                    self.uploadDataButton.setOn(false)
                    self.userDefaultsVitals.setValue(false, forKey: "Upload Data Button")
                }
            }
            if let xyzSwitchCheck = message["XYZ Switch Check"] as? String {
                if xyzSwitchCheck == "ON" {
                    self.uploadXYZButton.setOn(true)
                }
                if xyzSwitchCheck == "OFF" {
                    self.uploadXYZButton.setOn(false)
                }
            }
            if let resultantSwitchCheck = message["Resultant Switch Check"] as? String {
                if resultantSwitchCheck == "ON" {
                    self.uploadResultantButton.setOn(true)
                }
                if resultantSwitchCheck == "OFF" {
                    self.uploadResultantButton.setOn(false)
                }
            }
        }
    }
}







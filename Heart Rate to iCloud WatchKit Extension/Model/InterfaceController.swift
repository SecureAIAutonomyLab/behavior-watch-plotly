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
    @IBOutlet var ecgTitle: WKInterfaceLabel!
    @IBOutlet var ecgLabel: WKInterfaceLabel!
    @IBOutlet var restingHRLabel: WKInterfaceLabel!
    @IBOutlet var restingHRTitle: WKInterfaceLabel!
    @IBOutlet var moreHRDataButton: WKInterfaceButton!
    @IBOutlet var hrDataSeparator: WKInterfaceSeparator!
    @IBOutlet var hrvTitle: WKInterfaceLabel!
    @IBOutlet var hrvLabel: WKInterfaceLabel!
    @IBOutlet var thirtySec: WKInterfaceButton!
    @IBOutlet var threeMin: WKInterfaceButton!
    @IBOutlet var thirtyMin: WKInterfaceButton!
    @IBOutlet var oneHr: WKInterfaceButton!
    @IBOutlet var tenHr: WKInterfaceButton!
    @IBOutlet var oneD: WKInterfaceButton!
    @IBOutlet var showTimers: WKInterfaceButton!
    
    //    interface labes for presenting physiological data, location, and accelerations
    //    also buttons for controlling the monitoring of vitals
    //    outlets allow the coder to change properties of the interface items
    
    let userDefaultsVitals = UserDefaults.standard
    //    Access Shared Defaults Object
    let session = WCSession.default //Apple Watch Session variable
    let motion = CMMotionManager()
    let workoutTimes = ["30sec": 30, "3min": 180, "30min": 1800, "1hr": 3600, "10hr": 36000, "1day": 86400]
    //    array of times that indicate timer length
    let content = UNMutableNotificationContent()
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
    let userName = LoginDataManager.sharedLogin.loginInfo()[2]
    var timer2 = Timer.init()
    var timer3 = Timer.init()
    var timerStop = Timer.init()
    //    timers for acceleration monitoring
    var workoutSession: HKWorkoutSession? // //workout session var
    var watchSession = WCSession.default //watch session variable
    var monitorVitals = false //button checker variable
    var timer = Timer() //timer variable
    var timerAccel = Timer.init()//timer variable for accelerometer
    var clearTimer = Timer.init()
    var secondsPassed = 0
    var totalTime = 0
    var hiddenLabelVariable = true
    var hiddenTimerVariable = true
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        clearDataFields()
        timerLength.setText("Pick Time")
        IDNameLabel.setText(userName)
        //        clear interface when opening app and set colors for uploading switches
        session.delegate = self
        session.activate()
        restingHRTitle.setHidden(true)
        restingHRLabel.setHidden(true)
        hrvTitle.setHidden(true)
        hrvLabel.setHidden(true)
        ecgTitle.setHidden(true)
        ecgLabel.setHidden(true)
        hrDataSeparator.setHidden(true)
        thirtySec.setHidden(true)
        threeMin.setHidden(true)
        thirtyMin.setHidden(true)
        oneHr.setHidden(true)
        tenHr.setHidden(true)
        oneD.setHidden(true)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        IDNameLabel.setText(userDefaultsVitals.string(forKey: "User Name"))
        //        update username label again in case there issues earlier
        if WCSession.isSupported() {
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        IDNameLabel.setText(userDefaultsVitals.string(forKey: "User Name"))
        //        update username label again in case there issues earlier
        super.didDeactivate()
    }
    
    @IBAction func didTapStartStopWorkout() {
        
        if(workoutSession == nil) {
            startWorkout()
            monitorVitals = true
            // creat boolean variable for checking if monitoring began
            
        } else {
            timer2.invalidate()
            stopWorkout()
            monitorVitals = false
            timer.invalidate()
            monitoringTimer.stop()
            monitoringTimer.setDate(.init(timeIntervalSinceNow: 0))
            timerLength.setText("Pick Time")
            timerLength.setTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            //            reset timer label after canceling timer or when it finishes running
            
        }
        if monitorVitals == true{
            self.userDefaultsVitals.set("Run Loops", forKey: "Run Loops")
            startAccelerometers()
            let result1 = "Start Pressed"
            let data1: [String: Any] = ["Start Pressed": result1 as Any]
            self.session.sendMessage(data1, replyHandler: nil, errorHandler: nil)
            //            tell iPhone that the user started monitoring on the apple watch
        }
        else if monitorVitals == false{
            stopWorkout()
            //            stop workout simulation
            timer2.invalidate()
            clearDataFields()
            //            clear interface when user stops monitoring on the apple watch
            let result = "Stop Pressed"
            let data: [String: Any] = ["Stop Pressed": result as Any]
            self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            //            tell iPhone that the user pressed the stop monitoring button
        }
    }
    @IBAction func thirtySeconds() {
        let time = Double(workoutTimes["30sec"]!)
        timerStarted(time: time)
        timerLength.setText("30 Seconds")
    }
    @IBAction func threeMinutes() {
        let time = Double(workoutTimes["3min"]!)
        timerStarted(time: time)
        timerLength.setText("3 Minutes")
    }
    @IBAction func thirtyMinutes() {
        let time = Double(workoutTimes["30min"]!)
        timerStarted(time: time)
        timerLength.setText("30 Minutes")
    }
    @IBAction func oneHour() {
        let time = Double(workoutTimes["1hr"]!)
        timerStarted(time: time)
        timerLength.setText("1 Hour")
    }
    @IBAction func tenHours() {
        let time = Double(workoutTimes["10hr"]!)
        timerStarted(time: time)
        timerLength.setText("10 Hours")
    }
    @IBAction func oneDay() {
        let time = Double(workoutTimes["1day"]!)
        timerStarted(time: time)
        timerLength.setText("1 Day")
    }
    @IBAction func moreHRData() {
        if hiddenLabelVariable == true {
            restingHRLabel.setHidden(false)
            restingHRTitle.setHidden(false)
            hrvLabel.setHidden(false)
            hrvTitle.setHidden(false)
            ecgTitle.setHidden(false)
            ecgLabel.setHidden(false)
            hrDataSeparator.setHidden(false)
            moreHRDataButton.setTitle("Hide HR Data")
            hiddenLabelVariable = false
        }
        else {
            restingHRTitle.setHidden(true)
            restingHRLabel.setHidden(true)
            hrvLabel.setHidden(true)
            hrvTitle.setHidden(true)
            ecgTitle.setHidden(true)
            ecgLabel.setHidden(true)
            hrDataSeparator.setHidden(true)
            moreHRDataButton.setTitle("More HR Data")
            hiddenLabelVariable = true
        }
        
    }
    
    @IBAction func ShowTimer() {
        if hiddenTimerVariable == true {
            thirtySec.setHidden(false)
            threeMin.setHidden(false)
            thirtyMin.setHidden(false)
            oneHr.setHidden(false)
            tenHr.setHidden(false)
            oneD.setHidden(false)
            showTimers.setTitle("Hide Timers")
            hiddenTimerVariable = false
        }
        else {
            thirtySec.setHidden(true)
            threeMin.setHidden(true)
            thirtyMin.setHidden(true)
            oneHr.setHidden(true)
            tenHr.setHidden(true)
            oneD.setHidden(true)
            showTimers.setTitle("Timers")
            hiddenTimerVariable = true
        }
    }
    
    @objc func updateCounter() { //update the timer so that the timer counts up
        //example functionality
        if secondsPassed < totalTime {
            //only activates when the timer has started counting down
            
            secondsPassed += 1
            monitorVitals = true
            startAccelerometers()
        }
        else {
            let request = UNNotificationRequest(identifier: "Test Identifier", content: content, trigger: trigger)
            timer.invalidate()
            monitoringTimer.stop()
            monitoringTimer.setDate(.init(timeIntervalSinceNow: 0))
            stopWorkout()
            timer2.invalidate()
            monitorVitals = false
            timerLength.setText("DONE!")
            timerLength.setTextColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
            clearDataFields()
            content.title = "Timer Done"
            content.body = "Finished Monitoring"
            content.sound = UNNotificationSound.default
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            let result = "Stop Pressed"
            let data: [String: Any] = ["Stop Pressed": result as Any]
            self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func stopWorkout() {
        monitorVitals = false
        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
        workoutSession = nil
        workoutButton.setTitle("Monitor ∞sec")
        timer2.invalidate()
        timer.invalidate()
    }
    
    func startWorkout() {
        monitorVitals = true
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking
        workoutConfiguration.locationType = .indoor
        monitorHeartRate()
        monitorRestingHR()
        monitorHRV()
        monitorSPO2()
        monitorNoise()
        monitorSleep()
        getLocation()
        
        do {
            if workoutSession == nil {
                workoutSession = try HKWorkoutSession(healthStore: HealthDataManager.sharedInstance.healthStore!, configuration: workoutConfiguration)
                workoutSession?.startActivity(with: Date())
                workoutButton.setTitle("Stop")
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
    
    func monitorRestingHR() {
        HealthDataManager.sharedInstance.observeRestingHeartRate {
            (restingHR) -> (Void) in
            if self.monitorVitals == true {
                let restingHRValue = String(format: "%.0f", restingHR)
                self.restingHRLabel.setText("\(restingHRValue) BPM")
                let data: [String: Any] = ["restingHR": restingHRValue as Any]
                self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            }
        }
    }
    
    func monitorHRV() {
        HealthDataManager.sharedInstance.sdnnQuery()
        let hrvValue = userDefaultsVitals.double(forKey: "HRV")
        hrvLabel.setText("\(hrvValue) millis")
        let hrvData: [String: Any] = ["hrv": "\(hrvValue)" as Any]
        //send data to companion app so that it can published to cloud services
        self.session.sendMessage(hrvData, replyHandler: nil, errorHandler: nil)
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
    
    func getLocation() {
        let longitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[1]
        let latitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[2]
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
            monitorRestingHR()
            monitorHRV()
        }
        else if monitorVitals == false{
            stopWorkout()
            clearDataFields()
        }
    }
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if motion.isAccelerometerAvailable  {
            self.motion.accelerometerUpdateInterval = 1.0 / 10.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            // Configure a timer to fetch the data.
            self.timer2 = Timer(fire: Date(), interval: (1.0/10.0),
                                repeats: true, block: { (timer2) in
                                    // Get the accelerometer data.
                                    if let data = self.motion.accelerometerData {
                                        let x = data.acceleration.x
                                        let y = data.acceleration.y
                                        let z = data.acceleration.z
                                        let xRound = Double(round(1000*x)/1000)
                                        let yRound = Double(round(1000*y)/1000)
                                        let zRound = Double(round(1000*z)/1000)
                                        let resultantAccel = sqrt(pow(xRound,2) + pow(yRound,2) + pow(zRound,2))
                                        let resultantRound = Double(round(1000*resultantAccel)/1000)
                                        self.resultantLabel.setText("\(resultantRound)")
                                        self.xLabel.setText("\(xRound) g's")
                                        self.yLabel.setText("\(yRound) g's")
                                        self.zLabel.setText("\(zRound) g's")
                                        let XYZ: [String: Any] = ["Array": [xRound, yRound, zRound] as Any]
                                        let resultantXYZ: [String: Any] = ["Resultant": resultantAccel as Any]
                                        self.session.sendMessage(XYZ, replyHandler: nil, errorHandler: nil)
                                        self.session.sendMessage(resultantXYZ, replyHandler: nil, errorHandler: nil)
                                        // Use the accelerometer data in your app.
                                        if self.userDefaultsVitals.string(forKey: "Run Loops") == "Stop Loops" {
                                            timer2.invalidate()
                                        }
                                    }
                                })
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer2, forMode: .default)
            
        }
    }
    
    func clearDataFields() {
        heartRate.setText("--")
        restingHRLabel.setText("--")
        hrvLabel.setText("--")
        ecgLabel.setText("--")
        SPO2Label.setText("--")
        noiseExposLabel.setText("--")
        sleepLabel.setText("--")
        longitudeLabel.setText("--")
        latitudeLabel.setText("--")
        resultantLabel.setText("--")
        xLabel.setText("--")
        yLabel.setText("--")
        zLabel.setText("--")
    }
    
    func timerStarted(time: Double){
        timer.invalidate()
        timer2.invalidate()
        monitoringTimer.stop()
        timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
        monitoringTimer.setDate(.init(timeIntervalSinceNow: time))
        monitoringTimer.start()
        startAccelerometers()
        let result1 = "Start Pressed"
        let data1: [String: Any] = ["Start Pressed": result1 as Any]
        self.session.sendMessage(data1, replyHandler: nil, errorHandler: nil)
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
            if let monitor = message["Remote Monitor"] as? String {
                if monitor == "Monitor" {
                    self.userDefaultsVitals.set("Run Loops", forKey: "Run Loops")
                    self.startWorkout()
                    self.startAccelerometers()
                    self.monitorHeartRate()
                    self.monitorRestingHR()
                    self.monitorSPO2()
                    self.monitorNoise()
                    self.monitorSleep()
                    self.getLocation()
                    self.monitorHRV()
                    self.timer.invalidate()
                }
                else if monitor == "Stop" {
                    self.stopWorkout()
                    self.userDefaultsVitals.set("Stop Loops", forKey: "Run Loops")
                    DispatchQueue.main.async {
                        self.timer.invalidate()
                        self.timer2.invalidate()
                        self.clearTimer = Timer(fire: Date(), interval: (1.0/100.0),
                                                repeats: true, block: { (timer) in
                                                    self.clearDataFields()
                                                })
                        RunLoop.current.add(self.clearTimer, forMode: .default)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                            // Code you want to be delayed
                            self.clearTimer.invalidate()
                        }
                    }
                }
            }
        }
        DispatchQueue.main.async {
            if let ECG = message["ECG"] as? String {
                self.ecgLabel.setText(ECG)
        }
    }
    }
}







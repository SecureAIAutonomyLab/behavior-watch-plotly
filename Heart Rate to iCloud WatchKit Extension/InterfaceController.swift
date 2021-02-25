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


class InterfaceController: WKInterfaceController {

    @IBOutlet var heartRate: WKInterfaceLabel!
    @IBOutlet var SPO2Label: WKInterfaceLabel!
    @IBOutlet var noiseExposLabel: WKInterfaceLabel!
    @IBOutlet var ecgLabel: WKInterfaceLabel!
    @IBOutlet var workoutButton: WKInterfaceButton!
    @IBOutlet var timerLength: WKInterfaceLabel!
    @IBOutlet var IDNameLabel: WKInterfaceLabel!
    
    var workoutSession: HKWorkoutSession? // //workout session var
    var watchSession = WCSession.default //watch session variable
    var monitorVitals = false //button checker variable
    let session = WCSession.default //Apple Watch Session variable
    var timer = Timer() //timer variable
    let workoutTimes = ["30sec": 30, "3min": 180, "30min": 1800, "1hr": 3600, "10hr": 36000, "1day": 8640]
    var secondsPassed = 0
    var totalTime = 0

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        heartRate.setText("--")
        SPO2Label.setText("--")
        noiseExposLabel.setText("--")
        timerLength.setText("Pick Time")
//        HealthDataManager.sharedInstance.newECGQuery()
        
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func didTapStartStopWorkout() {
        

        if(workoutSession == nil) {
            startWorkout()
            monitorVitals = true
            HealthDataManager.sharedInstance.newECGQuery()

        } else {
            stopWorkout()
            monitorVitals = false
            timer.invalidate()
            timerLength.setText("Pick Time")
            timerLength.setTextColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            HealthDataManager.sharedInstance.newECGQuery()

        
    }
        if monitorVitals == true{
            startWorkout()
            monitorHeartRate()
            monitorSPO2()
            monitorNoise()
            monitorECG()
        }
        else if monitorVitals == false{
            stopWorkout()
            heartRate.setText("--")
            SPO2Label.setText("--")
            noiseExposLabel.setText("--")
       }
        
        
    }
    @IBAction func thirtySeconds() {
        let time = Double(workoutTimes["30sec"]!)
        timer.invalidate()
//        print(time)
        timerLength.setText("30 Seconds")
        timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))

    }
    @IBAction func threeMinutes() {
        let time2 = Double(workoutTimes["3min"]!)
        timer.invalidate()
        //        print(time2)
        timerLength.setText("3 Minutes")
        timer = Timer.scheduledTimer(timeInterval: time2, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
    }
    @IBAction func thirtyMinutes() {
        let time3 = Double(workoutTimes["30min"]!)
        timer.invalidate()
        timerLength.setText("30 Minutes")
        timer = Timer.scheduledTimer(timeInterval: time3, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
    }
    @IBAction func oneHour() {
        let time4 = Double(workoutTimes["1hr"]!)
        timer.invalidate()
        timerLength.setText("1 Hour")
        timer = Timer.scheduledTimer(timeInterval: time4, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
    }
    @IBAction func tenHours() {
        let time5 = Double(workoutTimes["10hr"]!)
        timer.invalidate()
        timerLength.setText("10 Hours")
        timer = Timer.scheduledTimer(timeInterval: time5, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
    }
    @IBAction func oneDay() {
        let time6 = Double(workoutTimes["1day"]!)
        timer.invalidate()
        timerLength.setText("1 Day")
        timer = Timer.scheduledTimer(timeInterval: time6, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        checkUserRequest()
        timerLength.setTextColor(#colorLiteral(red: 0.07800521816, green: 1, blue: 0, alpha: 1))
    }
    
    @objc func updateCounter() { //update the timer so that the timer counts up
        //example functionality
        if secondsPassed < totalTime {
            //only activates when the timer has started counting down
            
            secondsPassed += 1
            monitorVitals = true
            // make the seconds passed count up to the total time

//            let percentageProgress = Float(secondsPassed) / Float(totalTime)
            //algorithim for calculating the percent of the time that has passed as a float
            
//            progressBar.progress = percentageProgress
            //make the percent of time passed as a decimal equal to the progress bar value
        }
            else {
                
                timer.invalidate()
                stopWorkout()
                monitorVitals = false
            //reset the timer when the timer ends
//                playSound()
            //activate the alarm
                timerLength.setText("DONE!")
                timerLength.setTextColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
                
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
                
                workoutButton.setTitle("Stop")
                heartRate.setText("--")
                SPO2Label.setText("--")
                noiseExposLabel.setText("--")
            }
        } catch {
            print("Error starting workout session: \(error.localizedDescription)")
        }
    }
    
    func monitorHeartRate() {
        HealthDataManager.sharedInstance.observeHeartRateSamples {
            (heartRate) -> (Void) in
            if self.monitorVitals == true {
                self.heartRate.setText(
                String(format: "%.0f", heartRate))
                print("heart rate sample: \(heartRate)")
//              self.sendHeartRate(heartRate: heartRate)
                let data: [String: Any] = ["hr": String(heartRate) as Any]
                self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            }
            else if self.monitorVitals == false {
                self.heartRate.setText("--")
//                print("No Heart Beat Monitoring")
            }
        }
    }
    func monitorSPO2(){
    HealthDataManager.sharedInstance.observeSPO2Samples { (SPO2) -> (Void) in
        if self.monitorVitals == true {
            print("SPO2 Sample: \(SPO2*100)")
            self.SPO2Label.setText(String(format: "%.0f", SPO2*100,"%"))
            
            let data: [String: Any] = ["spo2": String(SPO2*100) as Any]
            self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        }
        else if self.monitorVitals == false{
            self.SPO2Label.setText("--")
            print("No SPO2 Monitoring")
        }
    }
    }
    
    func monitorNoise(){
        HealthDataManager.sharedInstance.observeEnvAudioSamples { (NoiseEX) -> (Void) in
            if self.monitorVitals == true{
                print("NoiseEX Sample: \(NoiseEX)")
                self.noiseExposLabel.setText(String(format: "%.0f", NoiseEX))
                
                let data: [String: Any] = ["NoiseEx": String(format: "%.0f", NoiseEX) as Any]
                self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        }
            else if self.monitorVitals == false{
                self.noiseExposLabel.setText("--")
                print("No Noise Expos Monitoring ")
            }
    }
    }
    
    func monitorECG(){
        HealthDataManager.sharedInstance.observeECGsamples { (ecgData) -> (Void) in
        print("NoiseEX Sample: \(ecgData)")
        self.ecgLabel.setText(ecgData)
        }
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
            monitorECG()
        }
        else if monitorVitals == false{
            stopWorkout()
            heartRate.setText("--")
            SPO2Label.setText("--")
            noiseExposLabel.setText("--")
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
                    print(IDLabel)
            }
        }
    }
}







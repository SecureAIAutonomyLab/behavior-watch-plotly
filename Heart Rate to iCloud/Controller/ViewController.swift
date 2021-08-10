//
//  ViewController.swift
//  Heart Rate to iCloud
//
//  Created by vctrg on 2/6/21.
//

import UIKit
import HealthKit
import WatchConnectivity
import BackgroundTasks
import CoreLocation
import GoogleSignIn
import NotificationCenter


//   DESCRIPTION: The ViewController class with the UIViewController subclass presents physiological data along with location data. The class handles the capturing of data from the apple watch via a WatchKit session and presents that data on its respective interface. Simultaneously the class also pushes the collected data to AWS in a specified format. The class also allows for the navigation between interfaces and it presents the user's name username and email once they have logged in using the various authentification services.
class ViewController: UIViewController {
    
    @IBOutlet var heartBeatiOS: UILabel!
    //    set up heart beat label variable
    @IBOutlet var SPO2iOS: UILabel!
    //    set up SPO2 label variable
    @IBOutlet var avgLongTermNE: UILabel!
    //    set up long term noise label variable
    @IBOutlet var hoursSleptLabel: UILabel!
    //    set up sleep label variable
    @IBOutlet var longitudeLatitudeLabel: UILabel!
    //    set up long. and lat. label
    @IBOutlet weak var dataSwitch: UISwitch!
    //    create AWS data sending switch
    @IBOutlet var userGuideButton: UIButton!
    //    create button to allow user to navigate to user guide
    @IBOutlet var accelerationButton: UIButton!
    //    create button to allow user to navigate to acceleration data page
    @IBOutlet var homeButton: UIButton!
    let userDefaultsVitals = UserDefaults.standard
    //    Access Shared Defaults Objec
    let settingsVC = SettingsViewController()
    let timeStamp = TimeStampCreator()
    var awsData = AWSDataManager()
    let loginData = LoginDataManager()
    var session: WCSession?
    //    set up first watch session variable
    var clientId = "0000"
    //    create dummy client variable to initiate clientID function later ont
    var userName: String!
    //    set up user name variable
    var appleID: String!
    //    set up Apple ID variable
    var fullName: String!
    //    set up full name variable
    var timer = Timer.init()
    //    create a timer for uploading location data at specified intervals
    var timer2 = Timer.init()
    //    create another timer for checking the state of the uploading switches
    
    
//    DESCRIPTION: The viewDidLoad function runs when the view is loading and becoming visible for the user. Here the specifics of the interface are managed and the login information is presented on the screen. Also the connection between the iPhone and Apple Watch is established by calling the configureWatchKitSession() method. Finally the array where physiological, location, and acceleration data is stored is created and configured.
    override func viewDidLoad() {
        super.viewDidLoad()
        //    Do any additional setup after loading the view.

        //        access app's data array
        userGuideButton.layer.cornerRadius = 13
        //        curve user guide button corners with 13 pixel radius
        accelerationButton.layer.cornerRadius = 13
        //        curve acceleration page button corners with 13 pixel radius
        homeButton.layer.cornerRadius = 13
        //        check if the biometric array is empty and initialize it if it is
        settingsVC.dataSwitchCheck()
        //        check what state the switch should be in
        configureWatchKitSession()
        //    call watch session function
    }
    
//    DESCRIPTION: The configureWatchKitSession() allows the user to configure the connection between the iPhone and Apple Watch apps. It first checks if a session is supported and then gives it the default configuration if it is available.
    func configureWatchKitSession(){
        if WCSession.isSupported() {
            //            check if apple watch sessions are supported
            session = WCSession.default
            //            create variable and set it to default watch session config.
            session?.delegate = self
            session?.activate()
            //            begin session
        }
    }
    
    @IBAction func goToAcclerometer(_ sender: Any) {
        //        runs when accelerometer button is pressed
    }
    
    @IBAction func sendDataSwitch(_ sender: Any) {
        //        change state of switch when it is pressed
    }
    
}

extension ViewController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        DispatchQueue.main.async {
            //            run in main thread
            if let heartRate = message["hr"] as? String {
                //                check if message from apple watch is for heart rate
                let heartRateFormat = ("\(heartRate) BPM")
                self.heartBeatiOS.text = heartRateFormat
                print(heartRate)
                self.userDefaultsVitals.setValue(heartRateFormat, forKey: "Heart Rate")
                let heartRateMessage = ("heart_rate:\(heartRate)")
                //                retrieve and format data from apple watch
                if self.dataSwitch.isOn{
                    self.awsData.uploadPhysiologicalData(vitalsValue: heartRateMessage)
                    //                    send value to upload function
                }
            }
            
            if let SPO2 = message["spo2"] as? String {
                //                check if message is for SPO2
                self.SPO2iOS.text = ("\(SPO2)%")
                let spo2Message = ("blood_o2:\(SPO2)")
                if self.dataSwitch.isOn{
                    self.awsData.uploadPhysiologicalData(vitalsValue: spo2Message)
                    //                    send spo2 value to upload function
                }
            }
            
            if let noiseExpos = message["NoiseEx"] as? String {
                //                check if message is for long term noise exposure
                self.avgLongTermNE.text = ("\(noiseExpos) dB")
                let longTermNEMessage = ("noise:\(noiseExpos)")
                if self.dataSwitch.isOn{
                    self.awsData.uploadPhysiologicalData(vitalsValue: longTermNEMessage)
                    //                    send noise value to upload function
                }
            }
            
            if let sleepTime = message["SleepTime"] as? Double {
                //                check if message is for sleep
                let sleepMessage = ("sleep:\(sleepTime)")
                HealthDataManager.sharedInstance.retrieveSleep { result -> Void in
                    DispatchQueue.main.async {
                        let timeSlept = String(Int(result / 3600)) + "h " +
                            String(Int(result.truncatingRemainder(dividingBy: 3600) / 60)) + "m " +
                            String(Int(result.truncatingRemainder(dividingBy: 3600)
                                        .truncatingRemainder(dividingBy: 60))) + "s"
                        //                        format sleep data into --h --m --s (hours, minutes, seconds)
                        self.hoursSleptLabel.text = String(timeSlept)
                        //                        update interface with sleep data
                    }
                }
                
                if self.dataSwitch.isOn{
                    self.awsData.uploadPhysiologicalData(vitalsValue: sleepMessage)
                    //                    if uploading is enabled send value to upload function
                }
            }
            
            if (message["Start Pressed"] as? String) != nil {
                //                check if user started monitoring on apple watch
                let userName = self.loginData.loginInfo()[2]
                let location = HealthDataManager.sharedInstance.requestLocationAuthorization()[0]
                let uploadLocation = HealthDataManager.sharedInstance.requestLocationAuthorization()[1]
                let longitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[2]
                let latitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[3]
                    self.timer = Timer(fire: Date(), interval: (120.0/1.0),
                                       repeats: true, block: { (timer) in
                                        self.longitudeLatitudeLabel.text = location
                                        let dataLO: [String: Any] = ["Longitude": longitude as Any]
                                        self.session!.sendMessage(dataLO, replyHandler: nil, errorHandler: nil)
                                        let dataLA: [String: Any] = ["Latitude": latitude as Any]
                                        self.session!.sendMessage(dataLA, replyHandler: nil, errorHandler: nil)
                                        let data: [String: Any] = ["Name Label":"\(userName)" as Any]
                                        // transform Username into Data datatype [String: Any]
                                        self.session!.sendMessage(data, replyHandler: nil, errorHandler: nil)
                                        // send username to apple watch to update value
                                        if self.dataSwitch.isOn{
                                            self.awsData.uploadPhysiologicalData(vitalsValue: uploadLocation)
                                        }
                                       })
                    //                    send location to apple watch
                    RunLoop.current.add(self.timer, forMode: .default)
                    //                     run timer sending location every 2 minutes
                self.userDefaultsVitals.setValue("Start", forKey: "Check Pressed")
                //                check for state of monitor button on the apple watch
            }
            
            if (message["Stop Pressed"] as? String) != nil {
                //                check user stopped monitoring data on apple watch
                self.timer.invalidate()
                self.heartBeatiOS.text = "--"
                self.SPO2iOS.text = "--"
                self.avgLongTermNE.text = "--"
                self.hoursSleptLabel.text = "--"
                self.longitudeLatitudeLabel.text = "--,--"
                self.userDefaultsVitals.setValue("Stop", forKey: "Check Pressed")
                //                clear interface if user wants to stop monitoring
            }
            
            if let IDScreenCheck = message["Watch Display Activated"] as? String {
                if IDScreenCheck == "Activated"{
                    let data: [String : Any]  = ["Load Main Watch Screen" : "Activate Screen" as Any]
                    self.session?.sendMessage(data, replyHandler: nil, errorHandler: nil)
                }
                //                check when user logs into phone or if they have previously logged in to login to apple watch app
            }
            
            //            run all processes below in the main thread
            if let xyzArray = message["Array"] as? [Double] {
                self.xLabel.text = ("\(xyzArray[0])")
                self.yLabel.text = ("\(xyzArray[1])")
                self.zLabel.text = ("\(xyzArray[2])")
                //                retrieve xyz acceleration values from apple watch
                let xyzFormat = "xyz_acc:\(xyzArray[0]) \(xyzArray[1]) \(xyzArray[2])"
                if self.xyzSwitch.isOn {
                    self.awsData.uploadPhysiologicalData(vitalsValue: xyzFormat)
                }
                else{
                }
                //                upload xyz values if enabled
            }
            if let resultantXYZ = message["Resultant"] as? Double {
                let resultantRound = Double(round(1000*resultantXYZ)/1000)
                self.resultantLabel.text = ("\(resultantRound)")
                //                retrieve resultant acceleration value from apple watch
                let resultantFormat = "resultant_acc:\(resultantRound)"
                if self.resultantSwitch.isOn {
                    self.awsData.uploadPhysiologicalData(vitalsValue: resultantFormat)
                }
                else{
                }
                //                upload resultant values if enabled
            }
            if (message["Stop Pressed"] as? String) != nil {
                self.timer.invalidate()
                self.xLabel.text = "--"
                self.yLabel.text = "--"
                self.zLabel.text = "--"
                self.resultantLabel.text = "--"
                self.userDefaultsVitals.setValue("Stop", forKey: "Check Pressed")
                //                clear interface if user stopped monitoring on the apple watch
                }
            }
        }
    }
}



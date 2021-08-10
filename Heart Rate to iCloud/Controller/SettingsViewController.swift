//
//  SettingsViewController.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 6/23/21.
//

import Foundation
import UIKit
import GoogleSignIn
import WatchConnectivity
import AdSupport
import AppTrackingTransparency
import Amplify
import AmplifyPlugins
import Combine

/// DESCRIPTION: The SettingsViewController class is responsible for allowing the user to be able to configure Cloud Vitals to upload certain or all or none of the data being transmitted from the apple watch. The class is also responsible for allowing the user to enable location and health data monitoring, and the ability for the app to track the user to get the device's UUID.
class SettingsViewController: UITableViewController {
    
    // MARK: Data Properties
    @IBOutlet var healthAuthButton: UIButton!
    @IBOutlet var locationAuthButton: UIButton!
    @IBOutlet var loginOnAppleWatch: UIButton!
    @IBOutlet var secretKeyLabel: UILabel!
    @IBOutlet var heartBeatSwitch: UISwitch!
    @IBOutlet var restingHRSwitch: UISwitch!
    @IBOutlet var hrvSwitch: UISwitch!
    @IBOutlet var bloodO2Switch: UISwitch!
    @IBOutlet var noiseExposureSwitch: UISwitch!
    @IBOutlet var sleepSwitch: UISwitch!
    @IBOutlet var locationSwitch: UISwitch!
    @IBOutlet var xyzSwitch: UISwitch!
    @IBOutlet var resultantSwitch: UISwitch!
    @IBOutlet var ecgSwitch: UISwitch!
    @IBOutlet var uploadAllSwitch: UISwitch!
    @IBOutlet var enableTrackingButton: UIButton!
    @IBOutlet var hrDropDown: UIButton!
    
    let userDefaultsSettings = UserDefaults.standard
    //    Access Shared Defaults Object
    let loginData = LoginDataManager()
    let sharedASIdentifierManager = ASIdentifierManager.shared()
    let imageDown = UIImage(systemName: "chevron.down.circle.fill")
    let imageUp = UIImage(systemName: "chevron.up.circle.fill")
    var session: WCSession?
    var resultSink: AnyCancellable?
    var progressSink: AnyCancellable?
    var hiddenHRSwitches = true
    
    // MARK: Init
    ///    DESCRIPTION: The method is called when the interface is first loading. The method configures the attributes of interface items like adjusting the shape of the buttons. It also retrieves the login information and displays them on the screen. Finally the method configures the connection between the apple watch and the iphone for data transfer and communication.
    override func viewDidLoad() {
        super.viewDidLoad()
        var ID = sharedASIdentifierManager.advertisingIdentifier
        healthAuthButton.layer.cornerRadius = 17.5
        locationAuthButton.layer.cornerRadius = 17.5
        loginOnAppleWatch.layer.cornerRadius = 17.5
        enableTrackingButton.layer.cornerRadius = 17.5
        secretKeyLabel.text = ("\(ID)")
        userDefaultsSettings.setValue("\(ID)", forKey: "UUID")
        checkExtraSwitches()
        dataSwitchCheck()
    }
    
    /// DESCRIPTION: The tableView function configures the top table view to hide and show the resting heart beat row in case the user decides they want to view extra heart beat data.
    /// PARAMS: The parameters for the table view method are the UITableView that is being configured and the index path of the section and row that is being configured in the table view.
    /// RETURNS: The tableView method returns a CGFloat that determines the height of table view cell that is being transformed by the function.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 1 && indexPath.row == 4 && hiddenHRSwitches == true{
            return 0
        }
        else if indexPath.section == 1 && indexPath.row == 4 && hiddenHRSwitches == false {
            return 45
        }
        if indexPath.section == 1 && indexPath.row == 5 && hiddenHRSwitches == true{
            return 0
        }
        else if indexPath.section == 1 && indexPath.row == 5 && hiddenHRSwitches == false {
            return 45
        }
        if indexPath.section == 1 && indexPath.row == 6 && hiddenHRSwitches == true{
            return 0
        }
        else if indexPath.section == 1 && indexPath.row == 6 && hiddenHRSwitches == false {
            return 45
        }
        if indexPath.section == 1 && indexPath.row == 17 && hiddenHRSwitches == true{
            return 0
        }
        else if indexPath.section == 1 && indexPath.row == 17 && hiddenHRSwitches == false {
            return 0
        }
        return tableView.rowHeight
    }
    
    // MARK: IBActions
    /// DESCRIPTION: The uploadAllToggled method is called when the user interacts with the "Upload All" Switch. When the user turns it on all the othe uploading switches will also turn on and when it is turned off all of the other switches do the same. Depending on the state of the switch all or non of the data being transmitted from the watch will be uploaded to AWS. The internal states of all the other switches are also altered when this switch is pressed.
    /// PARAMS: The parameters for this method are the Switch that was pressed.
    @IBAction func uploadAllToggled(_ sender: UISwitch) {
        if uploadAllSwitch.isOn {
            heartBeatSwitch.setOn(true, animated: true)
            restingHRSwitch.setOn(true, animated: true)
            hrvSwitch.setOn(true, animated: true)
            ecgSwitch.setOn(true, animated: true)
            bloodO2Switch.setOn(true, animated: true)
            noiseExposureSwitch.setOn(true, animated: true)
            sleepSwitch.setOn(true, animated: true)
            locationSwitch.setOn(true, animated: true)
            xyzSwitch.setOn(true, animated: true)
            resultantSwitch.setOn(true, animated: true)
            userDefaultsSettings.setValue("ON", forKey: "HB Switch")
            userDefaultsSettings.setValue("ON", forKey: "RHR Switch")
            userDefaultsSettings.setValue("ON", forKey: "HRV Switch")
            userDefaultsSettings.setValue("ON", forKey: "ECG Switch")
            userDefaultsSettings.setValue("ON", forKey: "SPO2 Switch")
            userDefaultsSettings.setValue("ON", forKey: "Noise Switch")
            userDefaultsSettings.setValue("ON", forKey: "Sleep Switch")
            userDefaultsSettings.setValue("ON", forKey: "Location Switch")
            userDefaultsSettings.setValue("ON", forKey: "XYZ Switch")
            userDefaultsSettings.setValue("ON", forKey: "Resultant Switch")
        }
        else if uploadAllSwitch.isOn == false {
            heartBeatSwitch.setOn(false, animated: true)
            restingHRSwitch.setOn(false, animated: true)
            hrvSwitch.setOn(false, animated: true)
            ecgSwitch.setOn(false, animated: true)
            bloodO2Switch.setOn(false, animated: true)
            noiseExposureSwitch.setOn(false, animated: true)
            sleepSwitch.setOn(false, animated: true)
            locationSwitch.setOn(false, animated: true)
            xyzSwitch.setOn(false, animated: true)
            resultantSwitch.setOn(false, animated: true)
            userDefaultsSettings.setValue("OFF", forKey: "HB Switch")
            userDefaultsSettings.setValue("OFF", forKey: "RHR Switch")
            userDefaultsSettings.setValue("OFF", forKey: "HRV Switch")
            userDefaultsSettings.setValue("OFF", forKey: "ECG Switch")
            userDefaultsSettings.setValue("OFF", forKey: "SPO2 Switch")
            userDefaultsSettings.setValue("OFF", forKey: "Noise Switch")
            userDefaultsSettings.setValue("OFF", forKey: "Sleep Switch")
            userDefaultsSettings.setValue("OFF", forKey: "Location Switch")
            userDefaultsSettings.setValue("OFF", forKey: "XYZ Switch")
            userDefaultsSettings.setValue("OFF", forKey: "Resultant Switch")
        }
    }
    
    /// DESCRIPTION: This method is called when any of the swtiches in the settings page are toggled besides the upload all switch. The method is responsible for changing the internal state and interface state of each switch that was pressed. With this method the user can specifically choose which data to upload or not upload to AWS.
    /// PARAMS: The parameters for this method are any of the switches that were pressed that are linked to this @IBAction.
    @IBAction func uploadSwitchToggled(_ sender: UISwitch) {
        if heartBeatSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "HB Switch")
        }
        else if heartBeatSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "HB Switch")
        }
        if restingHRSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "RHR Switch")
        }
        else if restingHRSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "RHR Switch")
        }
        if hrvSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "HRV Switch")
        }
        else if hrvSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "HRV Switch")
        }
        if ecgSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "ECG Switch")
        }
        else if ecgSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "ECG Switch")
        }
        if bloodO2Switch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "SPO2 Switch")
        }
        else if bloodO2Switch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "SPO2 Switch")
        }
        if noiseExposureSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "Noise Switch")
        }
        else if noiseExposureSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "Noise Switch")
        }
        if sleepSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "Sleep Switch")
        }
        else if sleepSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "Sleep Switch")
        }
        if locationSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "Location Switch")
        }
        else if locationSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "Location Switch")
        }
        if xyzSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "XYZ Switch")
        }
        else if xyzSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "XYZ Switch")
        }
        if resultantSwitch.isOn == true {
            userDefaultsSettings.setValue("ON", forKey: "Resultant Switch")
        }
        else if resultantSwitch.isOn == false {
            userDefaultsSettings.setValue("OFF", forKey: "Resultant Switch")
        }
    }
    ///    DESCRIPTION: This method is called when the Refresh Apple Watch User Name button is pressed and it sends the username to the apple watch to be displayed on its main interface.
    ///    PARAMS: the sender which is the specific button that was pressed
    @IBAction func loginOnAppleWatchPressed(_ sender: UIButton) {
//        let userName = loginData.loginInfo()[2]
        //        retrieve username from internal storage
        let ID = userDefaultsSettings.string(forKey: "UUID")!
        let data: [String: Any] = ["Name Label":"\(ID)" as Any]
        //        convert it to sendable data
        self.session!.sendMessage(data, replyHandler: nil, errorHandler: nil)
    }
    
    /// DESCRIPTION: The moreHRSwitches method is called when the chevron arrow next to the Upload Heart Beat
    @IBAction func moreHRSwitches(_ sender: UIButton) {
        if hiddenHRSwitches == true {
            hrDropDown.setImage(imageUp, for: .normal)
            userDefaultsSettings.set(1, forKey: "MORE SWITCHES")
            hiddenHRSwitches = false
            tableView.reloadData()
        }
        else {
            hrDropDown.setImage(imageDown, for: .normal)
            userDefaultsSettings.setValue(0, forKey: "MORE SWITCHES")
            hiddenHRSwitches = true
            tableView.reloadData()
        }
    }
    ///    DESCRIPTION: This method is called when the Authorize Health Data button is pressed and it asks the user to enable the ability to collect heart beat, blood O2, noise exposure, and sleep data.
    ///    PARAMS: The sender which refers to the specific button that was pressed
    @IBAction func authorizeHealthDataPressed(_ sender: UIButton) {
        HealthDataManager.sharedInstance.retrieveSleepWithAuth() { result -> Void in DispatchQueue.main.async {
            print("authorization for sleep requested")
        }
        //        retrieve if authorized.
        }
        HealthDataManager.sharedInstance.requestAuthorization { (success) in
            DispatchQueue.main.async {
                let message = success ? "Authorized health data access." : "Failed to authorize health data access."
                let alertController = UIAlertController(title: "Health Data", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            //            request authorization for sleep data
        }
    }
    ///    DESCRIPTION: This method is called when the Enable Location Services button is pressed. When pressed the app requests permission to access the user's location so that location data can be collected and sent to AWS. If the user denies access no location data will be collected and it will not appear on the interface
    ///    PARAMS: the sender which refers to the specific button that was pressed
    @IBAction func enableLocationPressed(_ sender: UIButton) {
        HealthDataManager.sharedInstance.requestLocationAuthorization()
        //        request authorization for location data
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        }
        //        initalize notification services and create notification with specific attributes
    }
    
    /// DESCRIPTION: This method is calle when the "Enable Tracking Data" button is pressed in the settings page of the app. Pressing this button displays an alert to the user requesting for them to enable access for data tracking. If enabled the device's unique identifier will be displayed.
    @IBAction func enableTrackingPressed(_ sender: UIButton) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { (status) in
                if status == ATTrackingManager.AuthorizationStatus.authorized {
                    let ID = self.sharedASIdentifierManager.advertisingIdentifier
                    DispatchQueue.main.async {
                    self.secretKeyLabel.text = ("\(ID)")
                    self.userDefaultsSettings.set("\(ID)", forKey: "UUID")
                    }
                }
                
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    /// DESCRIPTION: When the "Sign Out" button is pressed the user is prompted with an alert asking them to confirm if they really want to sign out. The user is then taken back into the login page. This method is currently not in use since the login features have been disabled.
    @IBAction func signOutPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Sign Out?", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        //            create alert verifying if user wants to sign out
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in alertController.dismiss(animated: true, completion: nil)
            //            runs if user selects yes on the alert
            self.userDefaultsSettings.setValue("OUT", forKey: "Sign In")
            //            set state of app to signed out
            GIDSignIn.sharedInstance().signOut()
            //            sign out of google services if user signed in with google
            self.performSegue(withIdentifier: "signOutSegue", sender: self)
            //            head back to login screen
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        //        runs if user selects cancel on the alert
        self.present(alertController, animated: true, completion: nil)
        //        show alert
        
    }
    
    // MARK: Methods
    ///    DESCRIPTION: The configureWatchKitSession() allows the user to configure the connection between the iPhone and Apple Watch apps. It first checks if a session is supported and then gives it the default configuration if it is available.
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
    
    /// DESCRIPTION: The dataSwitchCheck method is called when the settings interface loads up and it checks the previous state of the uploading data switches and sets them to that previous state.
    func dataSwitchCheck() {
        let hbSwitchCheck = userDefaultsSettings.string(forKey: "HB Switch")
        let restingHRSwitchCheck = userDefaultsSettings.string(forKey: "RHR Switch")
        let hrvSwitchCheck = userDefaultsSettings.string(forKey: "HRV Switch")
        let spo2SwitchCheck = userDefaultsSettings.string(forKey: "SPO2 Switch")
        let noiseSwitchCheck = userDefaultsSettings.string(forKey: "Noise Switch")
        let sleepSwitchCheck = userDefaultsSettings.string(forKey: "Sleep Switch")
        let locationSwitchCheck = userDefaultsSettings.string(forKey: "Location Switch")
        let xyzSwitchCheck = userDefaultsSettings.string(forKey: "XYZ Switch")
        let resultantSwitchCheck = userDefaultsSettings.string(forKey: "Resultant Switch")
        //        retrieve state of data switch
        if hbSwitchCheck == "ON" {
            heartBeatSwitch.setOn(true, animated: true)
            //        if state is on turn switch on
        }
        else if hbSwitchCheck == "OFF" {
            heartBeatSwitch.setOn(false, animated: true)
            //        if state is off turn switch off
        }
        if restingHRSwitchCheck == "ON" {
            restingHRSwitch.setOn(true, animated: true)
        }
        else if restingHRSwitchCheck == "OFF" {
            restingHRSwitch.setOn(false, animated: true)
        }
        if hrvSwitchCheck == "ON" {
            hrvSwitch.setOn(true, animated: true)
        }
        else if hrvSwitchCheck == "OFF" {
            hrvSwitch.setOn(false, animated: true)
        }
        if spo2SwitchCheck == "ON" {
            bloodO2Switch.setOn(true, animated: true)
            //        if state is on turn switch on
        }
        else if spo2SwitchCheck == "OFF" {
            bloodO2Switch.setOn(false, animated: true)
            //        if state is off turn switch off
        }
        if noiseSwitchCheck == "ON" {
            noiseExposureSwitch.setOn(true, animated: true)
            //        if state is on turn switch on
        }
        else if noiseSwitchCheck == "OFF" {
            noiseExposureSwitch.setOn(false, animated: true)
            //        if state is off turn switch off
        }
        if sleepSwitchCheck == "ON" {
            sleepSwitch.setOn(true, animated: true)
            //        if state is on turn switch on
        }
        else if sleepSwitchCheck == "OFF" {
            sleepSwitch.setOn(false, animated: true)
            //        if state is off turn switch off
        }
        if locationSwitchCheck == "ON" {
            locationSwitch.setOn(true, animated: true)
            //        if state is on turn switch on
        }
        else if locationSwitchCheck == "OFF" {
            locationSwitch.setOn(false, animated: true)
            //        if state is off turn switch off
        }
        if xyzSwitchCheck == "ON" {
            xyzSwitch.setOn(true, animated: true)
            //        if state is on turn switch on
        }
        else if xyzSwitchCheck == "OFF" {
            xyzSwitch.setOn(false, animated: true)
            //        if state is off turn switch off
        }
        if resultantSwitchCheck == "ON" {
            resultantSwitch.setOn(true, animated: true)
            //        if state is on turn switch on
        }
        else if resultantSwitchCheck == "OFF" {
            resultantSwitch.setOn(false, animated: true)
            //        if state is off turn switch off
        }
    }
    
    /// DESCRIPTION: The checkExtraSwitches method checks for wether the user had chosen to hide or display the extra heart rate switches. The method is called when the settings display loads up and it either hides or displays the switches depending on whether they were previously left hidden or displayed.
    func checkExtraSwitches() {
        if userDefaultsSettings.integer(forKey: "MORE SWITCHES") == 0 {
            hrDropDown.setImage(imageDown, for: .normal)
            hiddenHRSwitches = true
            tableView.reloadData()
        }
        else if userDefaultsSettings.integer(forKey: "MORE SWITCHES") == 1 {
            hrDropDown.setImage(imageUp, for: .normal)
            hiddenHRSwitches = false
            tableView.reloadData()
        }
    }
}

// MARK: Extension
// DESCRIPTION: Used for receiving message from the apple watch a more detailed description of this class extension can be found in DataViewController.swift.
extension SettingsViewController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        }
    }


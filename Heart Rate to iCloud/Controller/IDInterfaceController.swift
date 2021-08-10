//
//  IDInterfaceController.swift
//  Heart Rate to iCloud
//
//  Created by vctrg on 3/25/21.
//
// MARK: UNUSED FILE

import Foundation
import WatchConnectivity
import UIKit
import GoogleSignIn
import FBSDKLoginKit

///    DESCRIPTION: The IDInterfaceController class that inherits the UIViewController subclass creates an interface that the user can use to login into Cloud Vitals with either their Apple ID or their google account. Their login information is internally stored so that if a user exits the app and opens it again they don't have to log in if they already have. This class also produces a unique secret key when the user logs in so that when their data is sent to cloud services it remains anonymous.
class IDInterfaceController: UIViewController{
    
    // MARK: Data Properties
    //    set up internal storag variable
    var session = WCSession.default
    //    create apple watch session variable
    var timer = Timer.init()
    let loginButton = FBLoginButton()
    let login = LoginDataManager()
    let userDefaults = UserDefaults.standard
    @IBOutlet var loginStackView: UIStackView!
    //    create stack view for login button
    @IBOutlet var parentView: UIView!
    //    create parent view variable for comparison
    
    // MARK: Init
    ///   DESCRIPTION: viewDidLoad method runs when the screen is about to be presented to the user and when it is called it configures the connection between the Apple Watch and iPhon app components. It also establishes the services to login with google accounts. It also checks if the user has logged in previously with a google account. The method also runs a looping method that checks if the user has logged in previously so that the app can automatically log them in if they have.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWatchKitSession()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //      automatically sign in user
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        //      initialize watch session
        loginButton.center = view.center
        view.addSubview(loginButton)
        self.timer = Timer(fire: Date(), interval: (1.0/5.0),
                           repeats: true, block: { (timer) in
                            self.checkLogin()
                            print(self.userDefaults.string(forKey: "Sign In")!)
                           })
        RunLoop.current.add(self.timer, forMode: .default)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLogin()
        //          run login check function
    }
    
    // MARK: Segue
    /// DESCRIPTION: The prepare method triggers the segue to the Home Screen. The method is called once the user has logged in.
    /// PARAMS: The for segue parameter indicates that the data type that the method is dealing with is a UIStoryboardSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue" {
            let homeVC = segue.destination as! HomeViewController
            let data: [String: Any] = ["Name Label":"\(login.loginInfo()[2])" as Any]
            //                create data to be sent to apple watch
            self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            //                send user name to apple watch
            userDefaults.setValue("IN", forKey: "Sign In")
        }
    }
    
    // MARK: Methods
    func configureWatchKitSession(){
        if WCSession.isSupported() {
            session = WCSession.default
            //            initialize apple watch session
            session.delegate = self
            //            set session delegate as self
            session.activate()
            //            activate apple watch session
        }
    }
    func checkLogin() {
        let email = userDefaults.string(forKey: "Email")
        //        retrieve email from user defaults storage
        let signInCheck = userDefaults.string(forKey: "Sign In")
        if email != nil && (signInCheck == "IN" || signInCheck == nil) {
            //        check for any storage in user defaults if
            performSegue(withIdentifier: "loginSegue", sender: self)
            //            userDefaults.setValue("IN", forKey: "Sign In")
            timer.invalidate()
            //         if email storage is present start user off at vitals screen
        }
    }
}

// MARK: Extension
extension IDInterfaceController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
    //    class for setting up bluetooth apple watch session
}


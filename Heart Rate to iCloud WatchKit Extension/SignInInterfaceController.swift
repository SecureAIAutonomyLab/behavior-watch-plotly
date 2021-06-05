//
//  SignInInterfaceController.swift
//  Heart Rate to iCloud WatchKit Extension
//
//  Created by vctrg on 3/25/21.
//

import Foundation
import WatchKit
import WatchConnectivity
import AuthenticationServices
import UIKit

class SignInInterfaceController: WKInterfaceController {
    
    @IBOutlet var signedInButton: WKInterfaceButton!
    let endIFC = InterfaceController()
    var watchSession = WCSession.default //watch session variable
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        configureWatchKitSession()
        signedInButton.setEnabled(false)
        signedInButton.setTitle("Not Signed In")
    }
    
    override func willActivate() {
        super.willActivate()
        DispatchQueue.main.async {
        let data: [String: Any] = ["Watch Display Activated": "Activated"  as Any]
        self.watchSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
        }
    }
    override func didDeactivate() {
        super.didDeactivate()
    }
    @IBAction func signInPushed() {
    }
    
    func configureWatchKitSession(){
        if WCSession.isSupported() {
            watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    func loggedIn(){
        pushController(withName:"Interface Storyboard", context: self)
    }
    
}
extension SignInInterfaceController: WCSessionDelegate {
    

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let IDLabel = message["Name Label"] as? String {
                self.endIFC.userName = IDLabel
                print(IDLabel)
                self.signedInButton.setEnabled(true)
                self.signedInButton.setBackgroundColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
                self.signedInButton.setTitle("Signed In!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    //.2 second code delay
                self.loggedIn()
            }
        }
    }
        DispatchQueue.main.async {
            if (message["Load Main Watch Screen"] as? String) != nil {
                self.loggedIn()
            }
        }
}
}

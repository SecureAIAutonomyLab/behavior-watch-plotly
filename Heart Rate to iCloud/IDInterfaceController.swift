//
//  IDInterfaceController.swift
//  Heart Rate to iCloud
//
//  Created by vctrg on 3/25/21.
//

import Foundation
import WatchConnectivity
import AuthenticationServices
import UIKit

class IDInterfaceController: UIViewController{
    
    let appleIDProvider = ASAuthorizationAppleIDProvider()
//    set up apple ID auth. services
    let userDefaults = UserDefaults.standard
    var session = WCSession.default
    let alphabetArray : [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    let numberArray : [String] = ["1","2","3","4","5","6","7","8","9","0"]
    let symbolArray : [String] = ["!","@","#","$","%","^","&","*","(",")"]
    @IBOutlet var loginStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureWatchKitSession()
        setUpSignInAppleButton()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLogin()
    }
    
    func setUpSignInAppleButton() {
      let authorizationButton = ASAuthorizationAppleIDButton()
      authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
      //Add button on some view or stack
      authorizationButton.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
      self.loginStackView.addArrangedSubview(authorizationButton)
    }
    
    @objc
    func handleAppleIdRequest() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.performRequests()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "loginSegue" {
                let dataVC = segue.destination as! ViewController
                let email = userDefaults.string(forKey: "Email")!
                let fnValue = userDefaults.string(forKey: "Full Name")!
                let userName = email.components(separatedBy: "@")[0]
                
                
                let data: [String: Any] = ["Name Label":"\(userName)" as Any]
                self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
                dataVC.userName = userName
                dataVC.appleID = email
                dataVC.fullName = fnValue
        }
        
    }
    func configureWatchKitSession(){
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    func checkLogin() {
        let email = userDefaults.string(forKey: "Email")
        if email != nil {
            performSegue(withIdentifier: "loginSegue", sender: self)
            print("test")
        }
    }
}
extension IDInterfaceController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
    let userIdentifier = appleIDCredential.user
    let fullName = appleIDCredential.fullName!
    let email = appleIDCredential.email
    print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
        
    if email != nil {
    let alphaRando = alphabetArray.randomElement()!
    let numRando = numberArray.randomElement()!
    let symbRando = symbolArray.randomElement()!
    let alphaRando1 = alphabetArray.randomElement()!
    let numRando1 = numberArray.randomElement()!
    let symbRando1 = symbolArray.randomElement()!
    let alphaRando2 = alphabetArray.randomElement()!
    let numRando2 = numberArray.randomElement()!
    let symbRando2 = symbolArray.randomElement()!
    let alphaRando3 = alphabetArray.randomElement()!
    let numRando3 = numberArray.randomElement()!
    let symbRando3 = symbolArray.randomElement()!
        
    let randomKey = ("\(alphaRando)\(alphaRando1)\(alphaRando2)\(numRando)\(numRando1)\(numRando2)\(symbRando)\(symbRando1)\(symbRando2)\(alphaRando3)\(numRando3)\(symbRando3)")
//              random key format: aaa111!!!a1!
    let firstName = fullName.givenName!
    let lastName = fullName.familyName!
    let fullNameString = "\(firstName) \(lastName)"
    let emailString = "\(email!)"
    //To save the string
    userDefaults.set(randomKey, forKey: "Random Key")
    userDefaults.set(fullNameString, forKey: "Full Name")
    userDefaults.set(emailString, forKey: "Email")
        }
    //To retrieve from the key
    let vc = ViewController()
    let userName = "test"
    vc.userName = userName
    performSegue(withIdentifier: "loginSegue", sender: self)
    }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("Authorization Error")
    }
}
extension IDInterfaceController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
    }
        
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
}


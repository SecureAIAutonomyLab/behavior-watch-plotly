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
import GoogleSignIn

class IDInterfaceController: UIViewController{
    
    let appleIDProvider = ASAuthorizationAppleIDProvider()
//    set up apple ID auth. services
    let userDefaults = UserDefaults.standard
//    set up internal storag variable
    var session = WCSession.default
//    create apple watch session variable
    let alphabetArray : [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    let numberArray : [String] = ["1","2","3","4","5","6","7","8","9","0"]
    let symbolArray : [String] = ["!","@","#","$","%","^","&","*","(",")"]
//    arrays for random key creation
    var timer = Timer.init()
//  create timer for looping function
    @IBOutlet var loginStackView: UIStackView!
//    create stack view for login button
    @IBOutlet var parentView: UIView!
//    create parent view variable for comparison
    @IBOutlet var googleSignIn: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWatchKitSession()
        GIDSignIn.sharedInstance()?.presentingViewController = self
//      automatically sign in user
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
//      initialize watch session
        setUpSignInAppleButton()
//      run apple id button setup function
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
    
    func setUpSignInAppleButton() {
        let authorizationButton = ASAuthorizationAppleIDButton()
//        set button variable to apple's apple ID button class
        authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for:     .touchUpInside)
//        Add button on some view or stack
        authorizationButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        set button background color
        loginStackView.center = parentView.center
//        center stack view in parent view's center
        self.loginStackView.addArrangedSubview(authorizationButton)
//        add subview in stack view with apple ID button inside

        
    }
    
    @objc
    func handleAppleIdRequest() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
//        creat variable for apple ID authentication
    let request = appleIDProvider.createRequest()
//        request apple for apple ID provider
    request.requestedScopes = [.fullName, .email]
//        specifically request for user's full name and email
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        setup final request variable before running request
    authorizationController.delegate = self
//        set authorization controller delegate as ASAuthorizationControllerDelegate
    authorizationController.performRequests()
//        finally perform login and personal info requests
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "loginSegue" {
                let dataVC = segue.destination as! ViewController
//                set ViewController.swift as destination view controller
                let data: [String: Any] = ["Name Label":"\(dataVC.appleSignInCheck()[2])" as Any]
//                create data to be sent to apple watch
                self.session.sendMessage(data, replyHandler: nil, errorHandler: nil)
//                send user name to apple watch
                userDefaults.setValue("IN", forKey: "Sign In")
        }
    }
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
extension IDInterfaceController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        check for authorization completion
    if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
//        check apple ID credentials
    userDefaults.setValue("True", forKey: "Apple Sign In")
    let fullName = appleIDCredential.fullName!
//        create variable for full name from login
    let email = appleIDCredential.email
//        create variable for email from login
    if email != nil {
//        check if email has been previously stored
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
//        create random string of variables to act as a secret key once the user has logged in for the first and only time
        
    let randomKey = ("\(alphaRando)\(alphaRando1)\(alphaRando2)\(numRando)\(numRando1)\(numRando2)\(symbRando)\(symbRando1)\(symbRando2)\(alphaRando3)\(numRando3)\(symbRando3)")   
//              random key format: aaa111!!!a1!
//        create random keyy
//    let randomKey = "test"
    let firstName = fullName.givenName!
//        split full name into just first name
    let lastName = fullName.familyName!
//        split full name into just last name
    let fullNameString = "\(firstName) \(lastName)"
//        create string of first and last name
    let emailString = "\(email!)"
//        create string from email
    userDefaults.set(randomKey, forKey: "Random Key")
    userDefaults.set(fullNameString, forKey: "Full Name Apple")
    userDefaults.set(emailString, forKey: "Email Apple")
    userDefaults.set(fullNameString, forKey: "Full Name")
    userDefaults.set(emailString, forKey: "Email")
//        To save the strings for the email, random key, and full name
    userDefaults.setValue("IN", forKey: "Sign In")
    }
    performSegue(withIdentifier: "loginSegue", sender: self)
//        go to ViewController.swift
    }
}
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("Authorization Error")
    }
//    handles any errors when logging in
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
//    class for setting up bluetooth apple watch session
}


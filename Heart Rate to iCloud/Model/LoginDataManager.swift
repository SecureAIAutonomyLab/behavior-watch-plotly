//
//  LoginDataManager.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 6/24/21.
//

// MARK: UNUSED FILE

import Foundation

struct LoginDataManager {
    
    static let sharedLogin = LoginDataManager()
    let alphabetArray : [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    let numberArray : [String] = ["1","2","3","4","5","6","7","8","9","0"]
    let symbolArray : [String] = ["!","@","#","$","%","^","&","*","(",")"]
//    arrays for random key creation
    let userDefaultsLogin = UserDefaults.standard
    
    func secretKey(){
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
    //        create random key
        userDefaultsLogin.setValue("IN", forKey: "Sign In")
        userDefaultsLogin.setValue(randomKey, forKey: "Random Key")
    }
    //    run specified background tasks
    
    
    func loginInfo() -> [String]{
//        let email = userDefaultsLogin.string(forKey: "Email")!
        //     retrieve email from internal storage
                let email = "-------@gmail.com"
        //        ^^^ dummy email for testing
//        let fnValue = userDefaultsLogin.string(forKey: "Full Name")!
        //     retrieve full name from internal storage
                let fnValue = "first last"
        //        ^^^ dummy name for testing
//        let userName = email.components(separatedBy: "@")[0]
        //     make user name from login email
                let userName = "-------"
        //     dummy user name for testing
//        let secretKey = userDefaultsLogin.string(forKey: "Random Key")!
                let secretKey = "abc123!@$a1!"
        return [email, fnValue, userName, secretKey]
        //            return array of user authentication variables
    }
    
}

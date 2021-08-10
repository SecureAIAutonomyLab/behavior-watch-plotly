//
//  homeViewControlle.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 6/24/21.
//

import Foundation
import UIKit
import WatchConnectivity
import HealthKit
/// DESCRIPTION: The HomeViewController class is responsible for giving the user a page to navigate to the various modules of Cloud Vitals. The user can use the navigation bar at the bottom of the screen to travel to the user guide, data screen, and the settings page.
class HomeViewController: UIViewController {
    
    // MARK: Data Properties
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userGuideButton: UIButton!
    @IBOutlet var vitalsButton: UIButton!
    @IBOutlet var navigationView: UIView!
    @IBOutlet var settingsButton: UIButton!
    let loginData = LoginDataManager()
    
    // MARK: Init
    /// DESCRIPTION: When the homescreen is loading the interfaced is configured with the following attributes. The navigation buttons are configured to have curved corners.
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = loginData.loginInfo()[1]
        navigationView.layer.cornerRadius = 14
        userGuideButton.layer.cornerRadius = 6
        vitalsButton.layer.cornerRadius = 6
        settingsButton.layer.cornerRadius = 6
    }
  
}

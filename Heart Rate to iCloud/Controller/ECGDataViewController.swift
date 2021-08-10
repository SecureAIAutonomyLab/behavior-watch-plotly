//
//  ECGDataViewController.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 7/20/21.
//

import UIKit
import HealthKit

/// DESCRIPTION: The ECGDataViewController class is created to give the user more info about their most recent Electrocardiogram sample that they have taken. The view controller shows their average heart rate during the ECG, the classification of the ECG and it presents a large scrollable table view containing all of the individual voltages recorded during the ECG sample in micro volts.
class ECGDataViewController: UIViewController {
    
    // MARK: Data Properties
    @IBOutlet var classificationLabel: UILabel!
    @IBOutlet var averageHRLabel: UILabel!
    var tableView = UITableView()
    let userECDDefaults = UserDefaults.standard
    
    // MARK: Init
    /// DESCRIPTION: Called when view first loads and it checks if ther is any available ECG data. If data is available the data is presented at the top of the interface and the ECG query runs to get the ECG's classification. The tableView is also created in this method by calling the setTableView() method.
    override func viewDidLoad() {
        super.viewDidLoad()
        let averageHR = userECDDefaults.string(forKey: "ECG HR")
        if averageHR == nil {
            averageHRLabel.text = ("NO DATA")
        }
        else {
            averageHRLabel.text = ("\(averageHR!) BPM")
        }
        setTableView()
        HealthDataManager.sharedInstance.ecgQuery { result -> Void in
            DispatchQueue.main.async {
                self.classificationLabel.text = result
            }
        }
    }
    
    // MARK: Methods
    /// DESCRIPTION: The setTableView method handles all of the interface properties of the tableView such as its location in the frame, background color, corner radius, delegate, and dataSource.
    func setTableView() {
        tableView.frame = self.view.frame.inset(by: UIEdgeInsets.init(top: 151, left: 20, bottom: 0, right: 20))
        tableView.backgroundColor = UIColor.colorFromHex(hexString: "#212121")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 15
        self.view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: Extension
/// DESCRIPTION: The extension to ECGDataViewController conforms to the UITableViewDelegate and UITableViewDataSource protocols. This extension handles the more advanced configurations of the tabelView like amount of sections, number of rows in each section, and what is presented in each row of the tableView.
extension ECGDataViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// DESCRIPTION: Tells the tableView how many sections to create.
    /// PARAMS: The parameter is the tableView that is being configured.
    /// RETURNS: An integer is returned representing how many sections to creat in the tableView.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// DESCRIPTION: This redeclaration of the tableView method creates a specific amount of tableView cells in the tableView. The method checks if there is any data from the ECG query to prevent the app from crashing.
    /// PARAMS: The parameters for this method is the tableView being configured and the amount of sections returned by the numberOfSections method.
    /// RETURNS: The returned value is an integer representing how many cells are in the tableView's section. Depending on whether or not there is data from the ECG query the tableView will either have one cell or have as many cells as the amount of voltages recorded from the ECG query.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ecgDataCount = userECDDefaults.stringArray(forKey: "ECG Array")
        if ecgDataCount == nil {
            return 1
        }
        else {
            return ecgDataCount!.count
        }
    }
    
    /// DESCRIPTION: This redeclaration of the tableView method handles the data that is presented in the individual cells created in the tableView. It checks for data from the ECG query and if there is none "NO DATA" is displayed in the cells. If there is data each cell is given a different voltage value from the ECG query in the sequential order that they were collected in.
    /// PARAMS: The parameters are the tableView being configured and the indexPath of the cell that the data is being added to. The indexPath is the location of the cell in question with regards to the position of the other cells.
    /// RETURNS: The method returns a UITableViewCell that is added to the tableView with the specified text. This method is called until there is no more ECG data left to fill the cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let ecgDataCount = userECDDefaults.stringArray(forKey: "ECG Array")
        if ecgDataCount == nil {
            cell.textLabel?.text = "NO DATA"
            return cell
        }
        else {
            cell.textLabel?.text = ecgDataCount![indexPath.row]
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
    
}

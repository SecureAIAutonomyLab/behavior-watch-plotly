//
//  ECGDataViewController.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 7/20/21.
//

import UIKit
import HealthKit

class ECGDataViewController: UIViewController {
    
    @IBOutlet var classificationLabel: UILabel!
    @IBOutlet var averageHRLabel: UILabel!
    var tableView = UITableView()
    let userECDDefaults = UserDefaults.standard
    
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

extension ECGDataViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ecgDataCount = userECDDefaults.stringArray(forKey: "ECG Array")
        if ecgDataCount == nil {
            return 1
        }
        else {
            return ecgDataCount!.count
        }
    }
    
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

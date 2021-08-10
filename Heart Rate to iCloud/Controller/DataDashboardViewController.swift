//
//  Simple example usage of ScrollableGraphView.swift
//  #################################################
//

import UIKit
import ScrollableGraphView

class DataDashboardViewController: UIViewController {
    
    // MARK: Data Properties
    var examples: GraphManager!
    var graphView: ScrollableGraphView!
    var currentGraphType = GraphType.heartBeat
    var graphConstraints = [NSLayoutConstraint]()
    var xOnly = false
    var yOnly = false
    var zOnly = false
    var label = UILabel()
    var titleLabel = UILabel()
    var reloadLabel = UILabel()
    var xLabel = UILabel()
    var yLabel = UILabel()
    var zLabel = UILabel()
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: Init
    ///    DESCRIPTION: The method is called when the interface is first loading. The method handles interface functions such as setting the dimension fo the graphView to be the fram of the screen as  CGRect. It also displays the heart rate gaph every time it loads with the title label and the back and next buttons present. The method also sets up the constraints for the graphView so that it remains in the same relative position even when the screen is rotated. When loading the method also checks for the existence of Heart Rate data and if there is not a empty graph is formed.
    override func viewDidLoad() {
        super.viewDidLoad()
        examples = GraphManager()
        graphView = examples.createHRGraph(self.view.frame)
        addBackLabel()
        addNextLabel()
        
        if examples.getHRArray().1 == 0 {
            addTitleLabel(withText: "NO HR DATA")
        }
        else {
            addTitleLabel(withText: "HEART BEAT(BPM)")
        }
        
        self.view.insertSubview(graphView, belowSubview: reloadLabel)
        setupConstraints()
    }
    
    // MARK: Constraints
    /// DESCRIPTION: The setupConstraints method is used for ensure that the graphView is bound to the device's view. The method makes the graphView offset by zero pixels from the sides and top of the device's view but it makes the bottom edge of the graph offset by 80 pixels upward from the bottom of the view. The constraints created are in the form of an array and each constraint is appended to that array.
    private func setupConstraints() {
        
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        graphConstraints.removeAll()
        let topConstraint = NSLayoutConstraint(item: self.graphView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.graphView!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.graphView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -80)
        let leftConstraint = NSLayoutConstraint(item: self.graphView!, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        
        graphConstraints.append(topConstraint)
        graphConstraints.append(bottomConstraint)
        graphConstraints.append(leftConstraint)
        graphConstraints.append(rightConstraint)
                
        self.view.addConstraints(graphConstraints)
    }
    
    // MARK: Labels
    /// DESCRIPTION: The addNextLabel method adds a user interaction enabled label to the interface that allows the user to switch to the next graphView in the sequence. The label has constraints making it offset by 20 pixels from the right side of the screen, by 20 pixels from the top of the screen, with a height of 40 pixels, and a width of 1.5 times the height of the label. A gesture recognizer was also added to the label allowing for it to act like a button.
    private func addNextLabel() {
        // Adding and updating the graph switching label in the top right corner of the screen.
        label.removeFromSuperview()
        label = createLabel(withText: "NEXT")
        label.isUserInteractionEnabled = true
        
            let rightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: -20)
            
            let topConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 20)
            
            let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
            let widthConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: label.frame.width * 1.5)
            
            let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTap))
            label.addGestureRecognizer(tapGestureRecogniser)
            
            self.view.insertSubview(label, aboveSubview: reloadLabel)
            self.view.addConstraints([rightConstraint, topConstraint, heightConstraint, widthConstraint])

    }
    
    /// DESCRIPTION: The addBackLabel method adds a user interaction enabled label to the interface that allows the user to switch to the previous graphView in the sequence. The label has constraints making it offset by 20 pixels from the left side of the screen, by 20 pixels from the top of the screen, with a height of 40 pixels, and a width of 1.5 times the height of the label. A gesture recognizer was also added to the label allowing for it to act like a button.
    private func addBackLabel() {
        
        reloadLabel.removeFromSuperview()
        reloadLabel = createLabel(withText: "BACK")
        reloadLabel.isUserInteractionEnabled = true
        
        let leftConstraint = NSLayoutConstraint(item: reloadLabel, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 20)
        
        let topConstraint = NSLayoutConstraint(item: reloadLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 20)
        
        let heightConstraint = NSLayoutConstraint(item: reloadLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        
        let widthConstraint = NSLayoutConstraint(item: reloadLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: reloadLabel.frame.width * 1.5)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(reloadDidTap))
        reloadLabel.addGestureRecognizer(tapGestureRecogniser)
        
        self.view.insertSubview(reloadLabel, aboveSubview: graphView)
        self.view.addConstraints([leftConstraint, topConstraint, heightConstraint, widthConstraint])
    }
    
    /// DESCRIPTION: The addTitleLabel method adds a user interaction enabled label to the interface that allows the user to switch to the next graphView in the sequence. The label has constraints centered horizontally in the view, offset by 40 pixels from the top of the screen, with a height of 40 pixels, and a width of 1.5 times the height of the label. A gesture recognizer was also added to the label allowing for it to act like a button.
    /// PARAMS: The input parameters for this method are a String that is used to represent the title of the graph being shown to the user.
    private func addTitleLabel(withText text: String) {
        
        titleLabel.removeFromSuperview()
        titleLabel = createLabel(withText: text)
        
            let centerXConstraint = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
    
            let topConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 40)
            
            let heightConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
            let widthConstraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: titleLabel.frame.width * 1.5)
            
            
            self.view.insertSubview(titleLabel, aboveSubview: view)
            self.view.addConstraints([centerXConstraint, topConstraint, heightConstraint, widthConstraint])

    }
    
    /// DESCRIPTION: The addXOnlyLabel method adds a user interaction enabled label to the interface that allows the user to hide the Y and Z acceleration graphs so that only the X acceleration graph is visibl. When pressed for the first time the label title changes to "Show All" so that if it is pressed again the Y and Z graphs become visible again.
    /// PARAMS: The input parameters for this method are a String that is used to represent the title of the graph being shown to the user. Only Strings passed to this method are "X Only" and "Show All"
    private func addXOnlyLabel(withText text: String) {
        
        xLabel.removeFromSuperview()
        xLabel = createLabel(withText: text)
        xLabel.isUserInteractionEnabled = true
        
        let leftConstraint = NSLayoutConstraint(item: xLabel, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 40)
        
        let topConstraint = NSLayoutConstraint(item: xLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -120)
        
        let heightConstraint = NSLayoutConstraint(item: xLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        
        let widthConstraint = NSLayoutConstraint(item: xLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: xLabel.frame.width * 1.5)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(xDidTap))
        xLabel.addGestureRecognizer(tapGestureRecogniser)
        
        self.view.insertSubview(xLabel, aboveSubview: graphView)
        self.view.addConstraints([leftConstraint, topConstraint, heightConstraint, widthConstraint])
    }
    
    /// DESCRIPTION: The addYOnlyLabel method adds a user interaction enabled label to the interface that allows the user to hide the X and Z acceleration graphs so that only the Y acceleration graph is visibl. When pressed for the first time the label title changes to "Show All" so that if it is pressed again the X and Z graphs become visible again.
    /// PARAMS: The input parameters for this method are a String that is used to represent the title of the graph being shown to the user. Only Strings passed to this method are "Y Only" and "Show All"
    private func addYOnlyLabel(withText text: String) {
        
        yLabel.removeFromSuperview()
        yLabel = createLabel(withText: text)
        yLabel.isUserInteractionEnabled = true
        
        let centerXConstraint = NSLayoutConstraint(item: yLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let topConstraint = NSLayoutConstraint(item: yLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -120)
        
        let heightConstraint = NSLayoutConstraint(item: yLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        
        let widthConstraint = NSLayoutConstraint(item: yLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: yLabel.frame.width * 1.5)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(yDidTap))
        yLabel.addGestureRecognizer(tapGestureRecogniser)
        
        self.view.insertSubview(yLabel, aboveSubview: graphView)
        self.view.addConstraints([centerXConstraint, topConstraint, heightConstraint, widthConstraint])
    }
    
    /// DESCRIPTION: The addZOnlyLabel method adds a user interaction enabled label to the interface that allows the user to hide the Y and X acceleration graphs so that only the Z acceleration graph is visibl. When pressed for the first time the label title changes to "Show All" so that if it is pressed again the Y and X graphs become visible again.
    /// PARAMS: The input parameters for this method are a String that is used to represent the title of the graph being shown to the user. Only Strings passed to this method are "Z Only" and "Show All"
    private func addZOnlyLabel(withText text: String) {
        
        zLabel.removeFromSuperview()
        zLabel = createLabel(withText: text)
        zLabel.isUserInteractionEnabled = true
        
        let rightConstraint = NSLayoutConstraint(item: zLabel, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: -40)
        
        let topConstraint = NSLayoutConstraint(item: zLabel, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -120)
        
        let heightConstraint = NSLayoutConstraint(item: zLabel, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        
        let widthConstraint = NSLayoutConstraint(item: zLabel, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: zLabel.frame.width * 1.5)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(zDidTap))
        zLabel.addGestureRecognizer(tapGestureRecogniser)
        
        self.view.insertSubview(zLabel, aboveSubview: graphView)
        self.view.addConstraints([rightConstraint, topConstraint, heightConstraint, widthConstraint])
    }
    
    /// DESCRIPTION: The createLabel method is called to format the labels being made. It handles the label's background color, text, text color, font, corner radi, and whether or not the label clips to bounds. All addLabel methods call this method to configue the label.
    /// PARAMS: The parameters for this method is the text that is being displayed on the label as a String datatype.
    /// RETURNS: The method returns a UILabel with the specified configurations from the createLabel method. This UILabel is passed to the interface to create the various labels for the graphView.
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        label.text = text
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        label.layer.cornerRadius = 2
        label.clipsToBounds = true
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        
        return label
    }
    
    // MARK: Button Taps
    /// DESCRITPION: The didTap method is called when the UITapGestureRecognizer on the "NEXT" label is pressed. When pressed the graphView cycles through the various graph types in the positive cycle. Goes HeartBeat, Blood O2, Noise Exposure, Sleep, Resting Heart Rate, Heart Rate Variability, XYZ Accelerations, Resultant Accelerations, and ECG. The method uses a switch statement to cycle through the methods and change the labels to fit the current graphView. It begins by removing the contraints, removing the graphView, changing the graphView to the next one in the cycle, adding it back to the interface, and then adding the constraints to the graphView.
    /// PARAMS: The input parameter is the UITapGestureRecognizer that was created at the "NEXT" label.
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        
        currentGraphType.next()
        
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        
        switch(currentGraphType) {
        
        case .heartBeat: // Show simple graph, no adapting, single line.
            examples.reloadHR()
            addBackLabel()
            addNextLabel()
            if examples.getHRArray().1 == 0 {
                addTitleLabel(withText: "NO HR DATA")
            }
            else {
                addTitleLabel(withText: "HEART BEAT(BPM)")
            }
            graphView = examples.createHRGraph(self.view.frame)
            
        case .bloodO2:
            examples.reloadSPO2()
            addBackLabel()
            addNextLabel()
            if examples.getSPO2Array().1 == 0 {
                addTitleLabel(withText: "NO SPO2 DATA")
            }
            else {
                addTitleLabel(withText: "BLOOD O2(%)")
            }
            graphView = examples.createSPO2Graph(self.view.frame)
            
        case .noiseExpos:
            examples.reloadNE()
            addBackLabel()
            addNextLabel()
            if examples.getNEArray().1 == 0 {
                addTitleLabel(withText: "NO NOISE DATA")
            }
            else {
                addTitleLabel(withText: "NOISE EXPOSURE(dB)")
            }
            graphView = examples.createNEGraph(self.view.frame)
            
        case .sleep:
            examples.reloadSleep()
            addBackLabel()
            addNextLabel()
            if examples.getSleepArray().1 == 0 {
                addTitleLabel(withText: "NO SLEEP DATA")
            }
            else {
                addTitleLabel(withText: "TIME SLEPT(hr)")
            }
            graphView = examples.createSleepGraph(self.view.frame)
            
        case .rhr:
            examples.reloadRHR()
            addBackLabel()
            addNextLabel()
            if examples.getRHRArray().1 == 0 {
                addTitleLabel(withText: "NO RESTING HR DATA")
            }
            else {
                addTitleLabel(withText: "RESTING HR(BPM)")
            }
            graphView = examples.createRHRGraph(self.view.frame)
            
        case .hrv:
            examples.reloadHRV()
            addBackLabel()
            addNextLabel()
            if examples.getHRVArray().1 == 0 {
                addTitleLabel(withText: "NO HRV DATA")
            }
            else {
                addTitleLabel(withText: "HEART RATE VAR.(ms)")
            }
            graphView = examples.createHRVGraph(self.view.frame)
           
        case .xyz:
            examples.reloadXYZ()
            addBackLabel()
            addNextLabel()
            if examples.getXYZArray().3 == 0 {
                addTitleLabel(withText: "NO ACCEL. DATA")
            }
            else {
                addTitleLabel(withText: "XYZ ACCEL.(g's)")
                addXOnlyLabel(withText: "X ONLY")
                addYOnlyLabel(withText: "Y ONLY")
                addZOnlyLabel(withText: "Z ONLY")
            }
            graphView = examples.createXYZGraph(self.view.frame, xLineColor: #colorLiteral(red: 1, green: 0.05464977098, blue: 0, alpha: 1), yLineColor: #colorLiteral(red: 0.05281795074, green: 1, blue: 0, alpha: 1), zLineColor: #colorLiteral(red: 0, green: 0.01606260887, blue: 1, alpha: 1))
            yOnly = false
            xOnly = false
            zOnly = false
            
        case .result:
            examples.reloadResultant()
            addBackLabel()
            addNextLabel()
            if examples.getRArray().1 == 0 {
                addTitleLabel(withText: "NO RESULTANT DATA")
            }
            else {
                addTitleLabel(withText: "RESULTANT ACC.(g's)")
            }
            graphView = examples.createResultantGraph(self.view.frame)
            
        case .ecg:
            examples.reloadECG()
            addBackLabel()
            addNextLabel()
            if examples.getECGArray().1 == 0 {
                addTitleLabel(withText: "NO ECG DATA")
            }
            if examples.getECGArray().1 > 0 {
                addTitleLabel(withText: "LATEST ECG(μV)")
            }
            graphView = examples.createECGGraph(self.view.frame)
        }
        
        self.view.insertSubview(graphView, belowSubview: reloadLabel)
        
        setupConstraints()
    }
    
    /// DESCRITPION: The reloadDidTap  method is called when the UITapGestureRecognizer on the "BACK" label is pressed. When pressed the graphView cycles through the various graph types in the negative cycle. Goes HeartBeat, ECG, Resultant Accelerations, XYZ Accelerations, Heart Rate Variability, Resting Heart Rate, Sleep, Noise Exposure, and Blood O2. The method uses a switch statement to cycle through the methods and change the labels to fit the current graphView. It begins by removing the contraints, removing the graphView, changing the graphView to the next one in the cycle, adding it back to the interface, and then adding the constraints to the graphView.
    /// PARAMS: The input parameter is the UITapGestureRecognizer that was created at the "BACK" label.
    @objc func reloadDidTap(_ gesture: UITapGestureRecognizer) {
        currentGraphType.back()
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        
        switch(currentGraphType) {
        
        case .heartBeat: // Show simple graph, no adapting, single line.
            examples.reloadHR()
            addBackLabel()
            addNextLabel()
            if examples.getHRArray().1 == 0 {
                addTitleLabel(withText: "NO HR DATA")
            }
            else {
                addTitleLabel(withText: "HEART BEAT(BPM)")
            }
            graphView = examples.createHRGraph(self.view.frame)
            
        case .bloodO2:
            examples.reloadSPO2()
            addBackLabel()
            addNextLabel()
            if examples.getSPO2Array().1 == 0 {
                addTitleLabel(withText: "NO SPO2 DATA")
            }
            else {
                addTitleLabel(withText: "BLOOD O2(%)")
            }
            graphView = examples.createSPO2Graph(self.view.frame)
            
        case .noiseExpos:
            examples.reloadNE()
            addBackLabel()
            addNextLabel()
            if examples.getNEArray().1 == 0 {
                addTitleLabel(withText: "NO NOISE DATA")
            }
            else {
                addTitleLabel(withText: "NOISE EXPOSURE(dB)")
            }
            graphView = examples.createNEGraph(self.view.frame)
            
        case .sleep:
            examples.reloadSleep()
            addBackLabel()
            addNextLabel()
            if examples.getSleepArray().1 == 0 {
                addTitleLabel(withText: "NO SLEEP DATA")
            }
            else {
                addTitleLabel(withText: "TIME SLEPT(hr)")
            }
            graphView = examples.createSleepGraph(self.view.frame)
            
        case .rhr:
            examples.reloadRHR()
            addBackLabel()
            addNextLabel()
            if examples.getRHRArray().1 == 0 {
                addTitleLabel(withText: "NO RESTING HR DATA")
            }
            else {
                addTitleLabel(withText: "RESTING HR(BPM)")
            }
            graphView = examples.createRHRGraph(self.view.frame)
            
        case .hrv:
            examples.reloadHRV()
            addBackLabel()
            addNextLabel()
            if examples.getHRVArray().1 == 0 {
                addTitleLabel(withText: "NO HRV DATA")
            }
            else {
                addTitleLabel(withText: "HEART RATE VAR.(ms)")
            }
            graphView = examples.createHRVGraph(self.view.frame)
           
        case .xyz:
            examples.reloadXYZ()
            addBackLabel()
            addNextLabel()
            if examples.getXYZArray().3 == 0 {
                addTitleLabel(withText: "NO ACCEL. DATA")
            }
            else {
                addTitleLabel(withText: "XYZ ACCEL.(g's)")
                addXOnlyLabel(withText: "X ONLY")
                addYOnlyLabel(withText: "Y ONLY")
                addZOnlyLabel(withText: "Z ONLY")
            }
            graphView = examples.createXYZGraph(self.view.frame, xLineColor: #colorLiteral(red: 1, green: 0.05464977098, blue: 0, alpha: 1), yLineColor: #colorLiteral(red: 0.05281795074, green: 1, blue: 0, alpha: 1), zLineColor: #colorLiteral(red: 0, green: 0.01606260887, blue: 1, alpha: 1))
            yOnly = false
            xOnly = false
            zOnly = false
            
        case .result:
            examples.reloadResultant()
            addBackLabel()
            addNextLabel()
            if examples.getRArray().1 == 0 {
                addTitleLabel(withText: "NO RESULTANT DATA")
            }
            else {
                addTitleLabel(withText: "RESULTANT ACC.(g's)")
            }
            graphView = examples.createResultantGraph(self.view.frame)
            
        case .ecg:
            examples.reloadECG()
            addBackLabel()
            addNextLabel()
            if examples.getECGArray().1 == 0 {
                addTitleLabel(withText: "NO ECG DATA")
            }
            if examples.getECGArray().1 > 0 {
                addTitleLabel(withText: "LATEST ECG(μV)")
            }
            graphView = examples.createECGGraph(self.view.frame)
        }
        
        self.view.insertSubview(graphView, belowSubview: reloadLabel)
        
        setupConstraints()
    }
    
    /// DESCRIPTION: The xDidTap method is only called when the XYZ Accelerations graph is visible since that is the only time these labels are present. When tapped the X acceleration graph becomes the only graph visible. The label then changes to show "SHOW ALL" and can then be pressed again to restore the original view showing all three acceleration graphs again. The graphView is reloaded to adjust for the interface changes which is why the whole graph is recreated instead of just adding the label.
    /// PARAMS: The parameter for this method is the UITapGestureRecognizer that is added to the "X ONLY" label.
    @objc func xDidTap(_ gesture: UITapGestureRecognizer) {
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        if xOnly == false {
            examples.reloadXYZ()
            graphView = examples.createXYZGraph(self.view.frame, xLineColor: #colorLiteral(red: 1, green: 0.05464977098, blue: 0, alpha: 1), yLineColor: UIColor.clear, zLineColor: UIColor.clear)
            addXOnlyLabel(withText: "SHOW ALL")
            addYOnlyLabel(withText: "Y ONLY")
            addZOnlyLabel(withText: "Z ONLY")
            xOnly = true
            yOnly = false
            zOnly = false
        }
        else {
            examples.reloadXYZ()
            graphView = examples.createXYZGraph(self.view.frame, xLineColor: #colorLiteral(red: 1, green: 0.05464977098, blue: 0, alpha: 1), yLineColor: #colorLiteral(red: 0.05281795074, green: 1, blue: 0, alpha: 1), zLineColor: #colorLiteral(red: 0, green: 0.01606260887, blue: 1, alpha: 1))
            addXOnlyLabel(withText: "X ONLY")
            addYOnlyLabel(withText: "Y ONLY")
            addZOnlyLabel(withText: "Z ONLY")
            xOnly = false
            yOnly = false
            zOnly = false
        }
        
        self.view.insertSubview(graphView, belowSubview: reloadLabel)
        
        setupConstraints()
    }
    
    /// DESCRIPTION: The yDidTap method is only called when the XYZ Accelerations graph is visible since that is the only time these labels are present. When tapped the Y acceleration graph becomes the only graph visible. The label then changes to show "SHOW ALL" and can then be pressed again to restore the original view showing all three acceleration graphs again. The graphView is reloaded to adjust for the interface changes which is why the whole graph is recreated instead of just adding the label.
    /// PARAMS: The parameter for this method is the UITapGestureRecognizer that is added to the "Y ONLY" label.
    @objc func yDidTap(_ gesture: UITapGestureRecognizer) {
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        if yOnly == false {
            examples.reloadXYZ()
            graphView = examples.createXYZGraph(self.view.frame, xLineColor: UIColor.clear, yLineColor: #colorLiteral(red: 0.05281795074, green: 1, blue: 0, alpha: 1), zLineColor: UIColor.clear)
            addYOnlyLabel(withText: "SHOW ALL")
            addXOnlyLabel(withText: "X ONLY")
            addZOnlyLabel(withText: "Z ONLY")
            yOnly = true
            xOnly = false
            zOnly = false
        }
        else {
            examples.reloadXYZ()
            graphView = examples.createXYZGraph(self.view.frame, xLineColor: #colorLiteral(red: 1, green: 0.05464977098, blue: 0, alpha: 1), yLineColor: #colorLiteral(red: 0.05281795074, green: 1, blue: 0, alpha: 1), zLineColor: #colorLiteral(red: 0, green: 0.01606260887, blue: 1, alpha: 1))
            addYOnlyLabel(withText: "Y ONLY")
            addXOnlyLabel(withText: "X ONLY")
            addZOnlyLabel(withText: "Z ONLY")
            yOnly = false
            xOnly = false
            zOnly = false
        }
        
        self.view.insertSubview(graphView, belowSubview: reloadLabel)
        
        setupConstraints()
    }
    
    /// DESCRIPTION: The zDidTap method is only called when the XYZ Accelerations graph is visible since that is the only time these labels are present. When tapped the Z acceleration graph becomes the only graph visible. The label then changes to show "SHOW ALL" and can then be pressed again to restore the original view showing all three acceleration graphs again. The graphView is reloaded to adjust for the interface changes which is why the whole graph is recreated instead of just adding the label.
    /// PARAMS: The parameter for this method is the UITapGestureRecognizer that is added to the "Z ONLY" label.
    @objc func zDidTap(_ gesture: UITapGestureRecognizer) {
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        if zOnly == false {
            examples.reloadXYZ()
            graphView = examples.createXYZGraph(self.view.frame, xLineColor: UIColor.clear, yLineColor: UIColor.clear, zLineColor: #colorLiteral(red: 0, green: 0.01606260887, blue: 1, alpha: 1))
            addZOnlyLabel(withText: "SHOW ALL")
            addXOnlyLabel(withText: "X ONLY")
            addYOnlyLabel(withText: "Y ONLY")
            zOnly = true
            xOnly = false
            yOnly = false
        }
        else {
            examples.reloadXYZ()
            graphView = examples.createXYZGraph(self.view.frame, xLineColor: #colorLiteral(red: 1, green: 0.05464977098, blue: 0, alpha: 1), yLineColor: #colorLiteral(red: 0.05281795074, green: 1, blue: 0, alpha: 1), zLineColor: #colorLiteral(red: 0, green: 0.01606260887, blue: 1, alpha: 1))
            addXOnlyLabel(withText: "X ONLY")
            addYOnlyLabel(withText: "Y ONLY")
            addZOnlyLabel(withText: "Z ONLY")
            zOnly = false
            xOnly = false
            yOnly = false
        }
        
        self.view.insertSubview(graphView, belowSubview: reloadLabel)
        
        setupConstraints()
    }
}


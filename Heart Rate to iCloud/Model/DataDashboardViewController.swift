//
//  Simple example usage of ScrollableGraphView.swift
//  #################################################
//

import UIKit
import ScrollableGraphView

class DataDashboardViewController: UIViewController {
    // MARK: Properties
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        examples = GraphManager()
        graphView = examples.createHRGraph(self.view.frame)
        addReloadLabel(withText: "BACK")
        addLabel(withText: "NEXT")
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
    
    private func setupConstraints() {
        
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        graphConstraints.removeAll()
        
        let topConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -80)
        let leftConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
        
        graphConstraints.append(topConstraint)
        graphConstraints.append(bottomConstraint)
        graphConstraints.append(leftConstraint)
        graphConstraints.append(rightConstraint)
                
        self.view.addConstraints(graphConstraints)
    }
    
    // Adding and updating the graph switching label in the top right corner of the screen.
    private func addLabel(withText text: String) {
        
        label.removeFromSuperview()
        label = createLabel(withText: text)
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
    
    private func addReloadLabel(withText text: String) {
        
        reloadLabel.removeFromSuperview()
        reloadLabel = createLabel(withText: text)
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
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        
        currentGraphType.next()
        
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        
        switch(currentGraphType) {
        
        case .heartBeat: // Show simple graph, no adapting, single line.
            examples.reloadHR()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getHRArray().1 == 0 {
                addTitleLabel(withText: "NO HR DATA")
            }
            else {
                addTitleLabel(withText: "HEART BEAT(BPM)")
            }
            graphView = examples.createHRGraph(self.view.frame)
            
        case .bloodO2:
            examples.reloadSPO2()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getSPO2Array().1 == 0 {
                addTitleLabel(withText: "NO SPO2 DATA")
            }
            else {
                addTitleLabel(withText: "BLOOD O2(%)")
            }
            graphView = examples.createSPO2Graph(self.view.frame)
            
        case .noiseExpos:
            examples.reloadNE()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getNEArray().1 == 0 {
                addTitleLabel(withText: "NO NOISE DATA")
            }
            else {
                addTitleLabel(withText: "NOISE EXPOSURE(dB)")
            }
            graphView = examples.createNEGraph(self.view.frame)
            
        case .sleep:
            examples.reloadSleep()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getSleepArray().1 == 0 {
                addTitleLabel(withText: "NO SLEEP DATA")
            }
            else {
                addTitleLabel(withText: "TIME SLEPT(hr)")
            }
            graphView = examples.createSleepGraph(self.view.frame)
            
        case .rhr:
            examples.reloadRHR()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getRHRArray().1 == 0 {
                addTitleLabel(withText: "NO RESTING HR DATA")
            }
            else {
                addTitleLabel(withText: "RESTING HR(BPM)")
            }
            graphView = examples.createRHRGraph(self.view.frame)
            
        case .hrv:
            examples.reloadHRV()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getHRVArray().1 == 0 {
                addTitleLabel(withText: "NO HRV DATA")
            }
            else {
                addTitleLabel(withText: "HEART RATE VAR.(ms)")
            }
            graphView = examples.createHRVGraph(self.view.frame)
           
        case .xyz:
            examples.reloadXYZ()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
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
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getRArray().1 == 0 {
                addTitleLabel(withText: "NO RESULTANT DATA")
            }
            else {
                addTitleLabel(withText: "RESULTANT ACC.(g's)")
            }
            graphView = examples.createResultantGraph(self.view.frame)
            
        case .ecg:
            examples.reloadECG()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
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
    
    @objc func reloadDidTap(_ gesture: UITapGestureRecognizer) {
        currentGraphType.back()
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        
        switch(currentGraphType) {
        
        case .heartBeat: // Show simple graph, no adapting, single line.
            examples.reloadHR()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getHRArray().1 == 0 {
                addTitleLabel(withText: "NO HR DATA")
            }
            else {
                addTitleLabel(withText: "HEART BEAT(BPM)")
            }
            graphView = examples.createHRGraph(self.view.frame)
            
        case .bloodO2:
            examples.reloadSPO2()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getSPO2Array().1 == 0 {
                addTitleLabel(withText: "NO SPO2 DATA")
            }
            else {
                addTitleLabel(withText: "BLOOD O2(%)")
            }
            graphView = examples.createSPO2Graph(self.view.frame)
            
        case .noiseExpos:
            examples.reloadNE()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getNEArray().1 == 0 {
                addTitleLabel(withText: "NO NOISE DATA")
            }
            else {
                addTitleLabel(withText: "NOISE EXPOSURE(dB)")
            }
            graphView = examples.createNEGraph(self.view.frame)
            
        case .sleep:
            examples.reloadSleep()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getSleepArray().1 == 0 {
                addTitleLabel(withText: "NO SLEEP DATA")
            }
            else {
                addTitleLabel(withText: "TIME SLEPT(hr)")
            }
            graphView = examples.createSleepGraph(self.view.frame)
            
        case .rhr:
            examples.reloadRHR()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getRHRArray().1 == 0 {
                addTitleLabel(withText: "NO RESTING HR DATA")
            }
            else {
                addTitleLabel(withText: "RESTING HR(BPM)")
            }
            graphView = examples.createRHRGraph(self.view.frame)
            
        case .hrv:
            examples.reloadHRV()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getHRVArray().1 == 0 {
                addTitleLabel(withText: "NO HRV DATA")
            }
            else {
                addTitleLabel(withText: "HEART RATE VAR.(ms)")
            }
            graphView = examples.createHRVGraph(self.view.frame)
           
        case .xyz:
            examples.reloadXYZ()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
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
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
            if examples.getRArray().1 == 0 {
                addTitleLabel(withText: "NO RESULTANT DATA")
            }
            else {
                addTitleLabel(withText: "RESULTANT ACC.(g's)")
            }
            graphView = examples.createResultantGraph(self.view.frame)
            
        case .ecg:
            examples.reloadECG()
            addReloadLabel(withText: "BACK")
            addLabel(withText: "NEXT")
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


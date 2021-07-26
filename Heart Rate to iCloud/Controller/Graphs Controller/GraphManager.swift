//
//  Graphs.swift
//  GraphView
//
//  Created by Kelly Roach on 8/18/18.
//

import UIKit
import ScrollableGraphView

class GraphManager : ScrollableGraphViewDataSource {
    // MARK: Data Properties
    let userDefaultsGraphs = UserDefaults.standard
    private lazy var numberOfDataItems = getHRArray().1
    private lazy var heartBeatData: [Double] = getHRArray().0
    private lazy var bloodO2Data: [Double] =  getSPO2Array().0
    private lazy var noiseExposData: [Double] = getNEArray().0
    private lazy var sleepData: [Double] = getSleepArray().0
    private lazy var rhrData: [Double] = getRHRArray().0
    private lazy var hrvData: [Double] = getHRVArray().0
    private lazy var xData: [Double] = getXYZArray().0
    private lazy var yData: [Double] = getXYZArray().1
    private lazy var zData: [Double] = getXYZArray().2
    private lazy var rData: [Double] = getRArray().0
    private lazy var ecgData: [Double] = getECGArray().0
    private lazy var xAxisLabels: [String] =  getHRArray().2
    // Labels for the x-axis
    
    
    // MARK: ScrollableGraphViewDataSource protocol
    // #########################################################
    // You would usually only have a couple of cases here, one for each
    // plot you want to display on the graph. However as this is showing
    // off many graphs with different plots, we are using one big switch
    // statement.
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        
        switch(plot.identifier) {
        
        // Data for the graphs with a single plot
        case "heartBeat":
            return heartBeatData[pointIndex]
        case "heartBeatDot":
            return heartBeatData[pointIndex]
        case "bloodO2":
            return bloodO2Data[pointIndex]
        case "bloodO2Dot":
            return bloodO2Data[pointIndex]
        case "noiseExpos":
            return noiseExposData[pointIndex]
        case "noiseExposDot":
            return noiseExposData[pointIndex]
        case "sleep":
            return sleepData[pointIndex]
        case "rhr":
            return rhrData[pointIndex]
        // Data for MULTI graphs
        case "hrv":
            return hrvData[pointIndex]
        case "x":
            return xData[pointIndex]
        case "y":
            return yData[pointIndex]
        case "z":
            return zData[pointIndex]
        case "r":
            return rData[pointIndex]
        case "ecg":
            return ecgData[pointIndex]
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        // Ensure that you have a label to return for the index
        return xAxisLabels[pointIndex]
    }
    
    func numberOfPoints() -> Int {
        return numberOfDataItems
    }
    //    MARK: HEART BEAT GRAPH
    func createHRGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        // Compose the graph view by creating a graph, then adding any plots
        // and reference lines before adding the graph to the view hierarchy.
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        let linePlot = LinePlot(identifier: "heartBeat") // Identifier should be unique for each plot.
        linePlot.lineColor = UIColor.colorFromHex(hexString: "#E03561")
        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        linePlot.lineWidth = 7
        
        let blueDotPlot = DotPlot(identifier: "heartBeatDot")
        blueDotPlot.dataPointType = ScrollableGraphViewDataPointType.circle
        blueDotPlot.dataPointSize = 10
        blueDotPlot.dataPointFillColor = UIColor.colorFromHex(hexString: "#E03561")
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.includeMinMax = false
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.dataPointLabelsSparsity = 2
        referenceLines.relativePositions = [0.0952381, 0.19047619, 0.28571429, 0.38095238, 0.47619048, 0.57142857, 0.66666667, 0.76190476, 0.85714286,  0.95238095]
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        graphView.addPlot(plot: linePlot)
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        graphView.dataPointSpacing = 60
        graphView.rangeMax = 210
        graphView.shouldAnimateOnStartup = true
        graphView.shouldRangeAlwaysStartAtZero = true
        
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: linePlot)
        graphView.addPlot(plot: blueDotPlot)
        
        return graphView
    }
    
    //    MARK: BLOOD O2 GRAPH
    func createSPO2Graph(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        let bloodO2Plot = LinePlot(identifier: "bloodO2")
        
        bloodO2Plot.lineWidth = 5
        bloodO2Plot.lineColor = #colorLiteral(red: 0.3705744743, green: 0.7852829099, blue: 0.9998752475, alpha: 1)
        bloodO2Plot.lineStyle = ScrollableGraphViewLineStyle.smooth
        bloodO2Plot.shouldFill = true
        bloodO2Plot.fillType = ScrollableGraphViewFillType.solid
        bloodO2Plot.fillColor = #colorLiteral(red: 0.3705744743, green: 0.7852829099, blue: 0.9998752475, alpha: 1).withAlphaComponent(0.5)
        bloodO2Plot.animationDuration = 0.7
        bloodO2Plot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        
        // Setup the reference lines.
        
        let dotPlot = DotPlot(identifier: "bloodO2Dot") // Add dots as well.
        dotPlot.dataPointSize = 7
        dotPlot.dataPointFillColor = UIColor.white
        
        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        
        // Setup the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.referenceLineUnits = "%"
        referenceLines.shouldShowReferenceLineUnits = true
        referenceLines.includeMinMax = false
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.relativePositions = [0.2173913, 0.43478261, 0.65217391, 0.86956522]
        
        
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        
        graphView.dataPointSpacing = 120
        graphView.rangeMin = 80
        graphView.rangeMax = 103
        graphView.shouldAnimateOnStartup = true
        // Add everything to the graph.
        graphView.addReferenceLines(referenceLines: referenceLines)
        //        graphView.addPlot(plot: blueLinePlot)
        graphView.addPlot(plot: bloodO2Plot)
        graphView.addPlot(plot: dotPlot)
        
        return graphView
    }
    //    MARK: NOISE EXPOSURE GRAPH
    func createNEGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        // Compose the graph view by creating a graph, then adding any plots
        // and reference lines before adding the graph to the view hierarchy.
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        let linePlot = LinePlot(identifier: "noiseExpos") // Identifier should be unique for each plot.
        linePlot.lineColor = #colorLiteral(red: 0.9999365211, green: 0.9009391665, blue: 0.1236188784, alpha: 1)
        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        linePlot.lineWidth = 7
        
        let blueDotPlot = DotPlot(identifier: "noiseExposDot")
        blueDotPlot.dataPointType = ScrollableGraphViewDataPointType.square
        blueDotPlot.dataPointSize = 10
        blueDotPlot.dataPointFillColor = #colorLiteral(red: 0.9999365211, green: 0.9009391665, blue: 0.1236188784, alpha: 1)
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.includeMinMax = false
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.relativePositions = [0.09375, 0.1875, 0.28125, 0.375, 0.46875, 0.5625, 0.6625, 0.75, 0.84375,  0.9375]
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        graphView.addPlot(plot: linePlot)
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        graphView.dataPointSpacing = 120
        graphView.rangeMax = 160
        graphView.shouldAnimateOnStartup = true
        graphView.shouldRangeAlwaysStartAtZero = true
        
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: linePlot)
        graphView.addPlot(plot: blueDotPlot)
        
        return graphView
    }
    
    //    MARK: TIME SLEPT GRAPH
    func createSleepGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        // Setup the plot
        let barPlot = BarPlot(identifier: "sleep")
        
        barPlot.barWidth = 35
        barPlot.barLineWidth = 1
        barPlot.barLineColor = #colorLiteral(red: 0.04178788513, green: 0.876685977, blue: 0.8765240908, alpha: 1)
        barPlot.barColor = #colorLiteral(red: 0.02816172689, green: 0.3499967456, blue: 0.3541096151, alpha: 1)
        
        barPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        barPlot.animationDuration = 1.5
        
        // Setup the reference lines
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.includeMinMax = false
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.relativePositions = [0, 0.07692308, 0.15384615, 0.23076923, 0.30769231, 0.38461538, 0.46153846, 0.53846154, 0.61538462, 0.69230769, 0.76923077, 0.84615385, 0.92307692]
        referenceLines.dataPointLabelColor = UIColor.white
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        
        graphView.shouldAnimateOnStartup = true
        
        graphView.rangeMax = 13
        graphView.rangeMin = 0
        graphView.dataPointSpacing = 70
        // Add everything
        graphView.addPlot(plot: barPlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        return graphView
    }
    
    //    MARK: RESTING HEART RATE GRAPH
    func createRHRGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        // Setup the plot
        let plot = DotPlot(identifier: "rhr")
        
        plot.dataPointSize = 10
        plot.dataPointFillColor = #colorLiteral(red: 1, green: 0.6264340028, blue: 0.4462322564, alpha: 1)
        
        // Setup the reference lines
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.includeMinMax = false
        referenceLines.relativePositions = [0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875]
        referenceLines.dataPointLabelColor = UIColor.white
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        graphView.shouldAdaptRange = false
        graphView.shouldAnimateOnAdapt = false
        
        graphView.dataPointSpacing = 120
        graphView.rangeMax = 85
        graphView.rangeMin = 45
        
        // Add everything
        graphView.addPlot(plot: plot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        return graphView
    }
    
    //    MARK: HEART RATE VARIABILITY GRAPH
    func createHRVGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        // Setup the plot
        let linePlot = LinePlot(identifier: "hrv")
        
        linePlot.lineColor = #colorLiteral(red: 1, green: 0.3965862392, blue: 0.5971020051, alpha: 1)
        linePlot.shouldFill = true
        linePlot.fillColor = #colorLiteral(red: 1, green: 0.3965862392, blue: 0.5971020051, alpha: 1)
        
        // Setup the reference lines
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineThickness = 1
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.dataPointLabelColor = UIColor.white
        referenceLines.includeMinMax = false
        referenceLines.relativePositions = [0, 0.3125, 0.625, 0.9375]
        
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        
        graphView.dataPointSpacing = 120
        graphView.rangeMin = 0
        graphView.rangeMax = 160
        
        // Add everything
        graphView.addPlot(plot: linePlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        return graphView
    }
    
    //    MARK: XYZ ACCELERATIONS GRAPH
    func createXYZGraph(_ frame: CGRect, xLineColor: UIColor, yLineColor: UIColor, zLineColor: UIColor) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        // Setup the first line plot.
        let xLine = LinePlot(identifier: "x")
        
        xLine.lineWidth = 5
        xLine.lineColor = xLineColor
        xLine.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        xLine.shouldFill = false
        xLine.fillType = ScrollableGraphViewFillType.solid
        xLine.fillColor = UIColor.colorFromHex(hexString: "#16aafc").withAlphaComponent(0.5)
        
        xLine.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        // Setup the second line plot.
        let yLine = LinePlot(identifier: "y")
        
        yLine.lineWidth = 5
        yLine.lineColor = yLineColor
        yLine.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        yLine.shouldFill = false
        yLine.fillType = ScrollableGraphViewFillType.solid
        yLine.fillColor = UIColor.colorFromHex(hexString: "#ff7d78").withAlphaComponent(0.5)
        
        yLine.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let zLine = LinePlot(identifier: "z")
        
        zLine.lineWidth = 5
        zLine.lineColor = zLineColor
        zLine.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        zLine.shouldFill = false
        zLine.fillType = ScrollableGraphViewFillType.solid
        zLine.fillColor = UIColor.colorFromHex(hexString: "#ff7d78").withAlphaComponent(0.5)
        
        zLine.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        // Customise the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.dataPointLabelsSparsity = 2
        referenceLines.dataPointLabelColor = UIColor.white
        referenceLines.includeMinMax = false
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.relativePositions = [0.0294, 0.0882, 0.1471, 0.2059, 0.2647, 0.3235, 0.3824, 0.4412, 0.5, 0.5588, 0.6176, 0.6765, 0.7353, 0.7941, 0.8529, 0.9118, 0.9706]
        
        // All other graph customisation is done in Interface Builder,
        // e.g, the background colour would be set in interface builder rather than in code.
        // graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#333333")
        
        // Add everything to the graph.
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        graphView.rangeMax = 17
        graphView.rangeMin = -17
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: xLine)
        graphView.addPlot(plot: yLine)
        graphView.addPlot(plot: zLine)
        return graphView
    }
    
    //    MARK: RESULTANT ACCELERATION GRAPH
    func createResultantGraph(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        // Setup the first line plot.
        let rLine = LinePlot(identifier: "r")
        
        rLine.lineWidth = 5
        rLine.lineColor = UIColor.white
        rLine.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        rLine.shouldFill = false
        rLine.fillType = ScrollableGraphViewFillType.solid
        rLine.fillColor = UIColor.colorFromHex(hexString: "#16aafc").withAlphaComponent(0.5)
        
        rLine.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        // Setup the second line plot.
        
        // Customise the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.dataPointLabelsSparsity = 2
        referenceLines.dataPointLabelColor = UIColor.white
        referenceLines.includeMinMax = false
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.relativePositions = [0, 0.0588, 0.1176, 0.1765, 0.2352, 0.2941, 0.3529, 0.4118, 0.4706, 0.5294, 0.5882, 0.6471, 0.7059, 0.7647, 0.8235, 0.8824, 0.9412]
        
        // All other graph customisation is done in Interface Builder,
        // e.g, the background colour would be set in interface builder rather than in code.
        // graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#333333")
        
        // Add everything to the graph.
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        graphView.rangeMax = 17
        graphView.rangeMin = 0
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: rLine)
        return graphView
    }
    
    //    MARK: ECG GRAPH
    func createECGGraph(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        // Setup the first line plot.
        let ecgLine = LinePlot(identifier: "ecg")
        
        ecgLine.lineWidth = 3
        ecgLine.lineColor = UIColor.colorFromHex(hexString: "#E03561")
        ecgLine.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        ecgLine.shouldFill = false
        ecgLine.fillType = ScrollableGraphViewFillType.solid
        ecgLine.fillColor = UIColor.colorFromHex(hexString: "#16aafc").withAlphaComponent(0.5)
        // Setup the second line plot.
        
        // Customise the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.dataPointLabelsSparsity = 2
        referenceLines.dataPointLabelColor = UIColor.white
        referenceLines.includeMinMax = true
        referenceLines.dataPointLabelsSparsity = 70
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        //            referenceLines.relativePositions =
        
        // All other graph customisation is done in Interface Builder,
        // e.g, the background colour would be set in interface builder rather than in code.
        // graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#333333")
        
        // Add everything to the graph.
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        graphView.rangeMax = 800
        graphView.rangeMin = -800
        graphView.dataPointSpacing = 1
        graphView.shouldAnimateOnStartup = false
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: ecgLine)
        return graphView
    }
    
    // MARK: Data Generation
    
    func reloadHR() {
        bloodO2Data = getHRArray().0
        numberOfDataItems = getHRArray().1
        xAxisLabels = getHRArray().2
    }
    
    func reloadSPO2() {
        bloodO2Data = getSPO2Array().0
        numberOfDataItems = getSPO2Array().1
        xAxisLabels = getSPO2Array().2
    }
    
    func reloadNE() {
        noiseExposData = getNEArray().0
        numberOfDataItems = getNEArray().1
        xAxisLabels = getNEArray().2
    }
    
    func reloadSleep() {
        sleepData = getSleepArray().0
        numberOfDataItems = getSleepArray().1
        xAxisLabels = getSleepArray().2
    }
    
    func reloadRHR() {
        rhrData = getRHRArray().0
        numberOfDataItems = getRHRArray().1
        xAxisLabels = getRHRArray().2
    }
    
    func reloadHRV() {
        hrvData = getHRVArray().0
        numberOfDataItems = getHRVArray().1
        xAxisLabels = getHRVArray().2
    }
    
    func reloadXYZ() {
        xData = getXYZArray().0
        yData = getXYZArray().1
        zData = getXYZArray().2
        numberOfDataItems = getXYZArray().3
        xAxisLabels = getXYZArray().4
    }
    
    func reloadResultant() {
        rData = getRArray().0
        numberOfDataItems = getRArray().1
        xAxisLabels = getRArray().2
    }
    
    func reloadECG() {
        ecgData = getECGArray().0
        numberOfDataItems = getECGArray().1
        xAxisLabels = getECGArray().2
    }
    
    func getHRArray() -> ([Double], Int, [String]) {
        let hrArray = userDefaultsGraphs.stringArray(forKey: "HR Array")
        let ts1Array = userDefaultsGraphs.stringArray(forKey: "TS1")
        if hrArray == nil {
            return ([], 0, [])
        }
        else {
            let hrDoubleArray = hrArray!.compactMap(Double.init)
            return (hrDoubleArray, hrDoubleArray.count, ts1Array!)
        }
    }
    
    func getSPO2Array() -> ([Double], Int, [String]) {
        let spo2Array = userDefaultsGraphs.stringArray(forKey: "SPO2 Array")
        let ts2Array = userDefaultsGraphs.stringArray(forKey: "TS2")
        if spo2Array == nil {
            return ([], 0, [])
        }
        else {
            let spo2DoubleArray = spo2Array!.compactMap(Double.init)
            return (spo2DoubleArray, spo2DoubleArray.count, ts2Array!)
        }
    }
    
    func getNEArray() -> ([Double], Int, [String]) {
        let noiseArray = userDefaultsGraphs.stringArray(forKey: "NE Array")
        let ts3Array = userDefaultsGraphs.stringArray(forKey: "TS3")
        if noiseArray == nil {
            return ([], 0, [])
        }
        else {
        let neDoubleArray = noiseArray!.compactMap(Double.init)
        return (neDoubleArray, neDoubleArray.count, ts3Array!)
        }
    }
    
    func getSleepArray() -> ([Double], Int, [String]) {
        let sleepArray = userDefaultsGraphs.stringArray(forKey: "Sleep Array")
        let ts4Array = userDefaultsGraphs.stringArray(forKey: "TS4")
        if sleepArray == nil {
            return ([], 0, [])
        }
        else {
        let sleepDoubleArray = sleepArray!.compactMap(Double.init)
        return (sleepDoubleArray, sleepDoubleArray.count, ts4Array!)
        }
    }
    
    func getRHRArray() -> ([Double], Int, [String]) {
        let rhrArray = userDefaultsGraphs.stringArray(forKey: "RHR Array")
        let ts5Array = userDefaultsGraphs.stringArray(forKey: "TS5")
        if rhrArray == nil {
            return ([], 0, [])
        }
        else {
        let rhrDoubleArray = rhrArray!.compactMap(Double.init)
        return (rhrDoubleArray, rhrDoubleArray.count, ts5Array!)
        }
    }
    
    func getHRVArray() -> ([Double], Int, [String]) {
        let hrvArray = userDefaultsGraphs.stringArray(forKey: "HRV Array")
        let ts6Aray = userDefaultsGraphs.stringArray(forKey: "TS6")
        if hrvArray == nil {
            return ([], 0, [])
        }
        else {
        let hrvDoubleArray = hrvArray!.compactMap(Double.init)
        return (hrvDoubleArray, hrvDoubleArray.count, ts6Aray!)
        }
    }
    
    func getXYZArray() -> ([Double], [Double], [Double], Int, [String]) {
        let xArray = userDefaultsGraphs.stringArray(forKey: "X Array")
        let yArray = userDefaultsGraphs.stringArray(forKey: "Y Array")
        let zArray = userDefaultsGraphs.stringArray(forKey: "Z Array")
        let ts7Array = userDefaultsGraphs.stringArray(forKey: "TS7")
        if xArray == nil {
            return ([], [], [], 0, [])
        }
        else {
        let xDoubleArray = xArray!.compactMap(Double.init)
        let yDoubleArray = yArray!.compactMap(Double.init)
        let zDoubleArray = zArray!.compactMap(Double.init)
            return (xDoubleArray, yDoubleArray, zDoubleArray, xArray!.count, ts7Array!)
        }
    }
    
    func getRArray() -> ([Double], Int, [String]) {
        let rArray = userDefaultsGraphs.stringArray(forKey: "R Array")
        let rTimeStamp = userDefaultsGraphs.stringArray(forKey: "TS8")
        if rArray == nil {
            return ([], 0, [])
        }
        else {
        let rDoubleArray = rArray!.compactMap(Double.init)
        return (rDoubleArray, rDoubleArray.count, rTimeStamp!)
        }
    }
    
    func getECGArray() -> ([Double], Int, [String]) {
        let ecgArray = userDefaultsGraphs.stringArray(forKey: "ECG Array")
        let timeArray = userDefaultsGraphs.stringArray(forKey: "ECG Time")
        if ecgArray == nil {
            return ([], 0, [])
        }
        else {
        let ecgDoubleArray = ecgArray!.compactMap(Double.init)
        return (ecgDoubleArray, ecgArray!.count, timeArray!)
        }
    }
}

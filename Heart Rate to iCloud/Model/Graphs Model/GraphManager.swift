//
//  Graphs.swift
//  GraphView
//
//  Created by Victor Guzman on 7/20/21
//

import UIKit
import ScrollableGraphView

/// DESCRIPTION: The GraphManager class handles the bulk of creating the graphViews. It handles specific properties of the graphs like scaling, line color, type of graph, etc.. The class handles the creation of each unique graph for each different data frame collected from the appleWatch.
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
    /// DESCRIPTION: This method handles the numerical values that are passed into the graphs and plots them accordingly. It uses a switch statement to determine what graph is in view and then plots the specific data for that graph on the interface. This method keeps running until it reaches the end of the pointIndex array which means it has run through all the data that is supposed to be plotted on the graph.
    /// PARAMS: The parameters for this method are the Plot being made and the location of the value that is being plotted in the form of an integer.
    /// RETURNS: The method returns the location of the data from the specific graph type as a double.
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        
        switch(plot.identifier) {
        
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
    
    ///DESCRIPTION: Creates the labels for the X axis at specific places on the graph. By default creates a label directly underneath each data point from the value() method. This method keeps running until it reaches the end of the pointIndex array which means it has run through all the data that is supposed to be plotted on the graph.
    /// PARAMS: The parameters for the graph are the location of the label as an Integer from the pointIndex array.
    /// RETURNS: The label method returns a string that is the title of each label on the x-axis
    func label(atIndex pointIndex: Int) -> String {
        // Ensure that you have a label to return for the index
        return xAxisLabels[pointIndex]
    }
    
    /// DESCRIPTION: Takes the number of items from the Data Properties to tell the graphViews exactly how many points that are going to be plotted on the graph. This value is what creates the pointIndex array and its limits.
    /// RETURNS: The method returns the numberOfDataItems specified by each graph when they are about to be presented.
    func numberOfPoints() -> Int {
        return numberOfDataItems
    }
    //    MARK: HEART BEAT GRAPH
    /// DESCRIPTION: Creates a graph that shows the Heart Beat data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: Dot and Line combo
    /// Line Width: 7 Pixels
    /// Line Style: Straight
    /// Dot Shape: Circle
    /// Dot Size: 10 Pixels
    /// Point Spacing: 60 pixels
    /// Animation: Ease Out
    /// Visible Data Range: 20-200
    /// Units: Beats Per Minute
    /// Label Sparsity: Every two values
    func createHRGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        // Compose the graph view by creating a graph, then adding any plots
        // and reference lines before adding the graph to the view hierarchy.
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        let hrLinePlot = LinePlot(identifier: "heartBeat") // Identifier should be unique for each plot.
        hrLinePlot.lineColor = UIColor.colorFromHex(hexString: "#E03561")
        hrLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        hrLinePlot.lineWidth = 7
        
        let hrDotPlot = DotPlot(identifier: "heartBeatDot")
        hrDotPlot.dataPointType = ScrollableGraphViewDataPointType.circle
        hrDotPlot.dataPointSize = 10
        hrDotPlot.dataPointFillColor = UIColor.colorFromHex(hexString: "#E03561")
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.includeMinMax = false
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.dataPointLabelsSparsity = 2
        referenceLines.relativePositions = [0.0952381, 0.19047619, 0.28571429, 0.38095238, 0.47619048, 0.57142857, 0.66666667, 0.76190476, 0.85714286, 0.95238095]
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        graphView.addPlot(plot: hrLinePlot)
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#212121")
        graphView.dataPointSpacing = 60
        graphView.rangeMax = 210
        graphView.shouldAnimateOnStartup = true
        graphView.shouldRangeAlwaysStartAtZero = true
        
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: hrLinePlot)
        graphView.addPlot(plot: hrDotPlot)
        
        return graphView
    }
    
    //    MARK: BLOOD O2 GRAPH
    /// DESCRIPTION: Creates a graph that shows the Blood O2 data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: Dot and Filled Line combo
    /// Line Width: 5 Pixels
    /// Line Style: Smooth
    /// Dot Shape: Circle
    /// Dot Size: 7 Pixels
    /// Point Spacing: 120
    /// Animation: Ease Out
    /// Animation Duration: 0.7 seconds
    /// Visible Data Range: 85-100
    /// Units: Percent
    /// Label Sparsity: Every value
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
        
        let bloodO2DotPlot = DotPlot(identifier: "bloodO2Dot") // Add dots as well.
        bloodO2DotPlot.dataPointSize = 7
        bloodO2DotPlot.dataPointFillColor = UIColor.white
        
        bloodO2DotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.easeOut
        
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
        graphView.addPlot(plot: bloodO2DotPlot)
        
        return graphView
    }
    //    MARK: NOISE EXPOSURE GRAPH
    /// DESCRIPTION: Creates a graph that shows the Noise Exposure data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: Dot and Line combo
    /// Line Width: 7 Pixels
    /// Line Style: Straight
    /// Dot Shape: Square
    /// Dot Size: 10 Pixels
    /// Point Spacing: 120
    /// Animation: Ease Out
    /// Visible Data Range: 15-150
    /// Units: Decibels
    /// Label Sparsity: Every value
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
    /// DESCRIPTION: Creates a graph that shows the Time Slept data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: Bar Graph
    /// Bar Line Width: 1 Pixel
    /// Bar Width: 35 Pixels
    /// Bar Spacing: 70 Pixels
    /// Animation: Elastic
    /// Animation Duration: 1.5 seconds
    /// Visible Data Range: 0-12
    /// Units: Hours
    /// Label Sparsity: Every value
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
    /// DESCRIPTION: Creates a graph that shows the Resting Heart Beat data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: Dot Plot
    /// Dot Shape: Circle
    /// Dot Size: 10 Pixels
    /// Point Spacing: 120 pixels
    /// Animation: Ease Out
    /// Visible Data Range: 50-80
    /// Units: Beats Per Minute
    /// Label Sparsity: Every value
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
        graphView.shouldAnimateOnAdapt = true
        
        graphView.dataPointSpacing = 120
        graphView.rangeMax = 85
        graphView.rangeMin = 45
        
        // Add everything
        graphView.addPlot(plot: plot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        return graphView
    }
    
    //    MARK: HEART RATE VARIABILITY GRAPH
    /// DESCRIPTION: Creates a graph that shows the Heart Beat Variability data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: Filled Line Graph
    /// Line Style: Straight
    /// Point Spacing: 120 pixels
    /// Animation: Ease Out
    /// Visible Data Range: 50-150
    /// Units: Milliseconds
    /// Label Sparsity: Every value
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
    /// DESCRIPTION: Creates a graph that shows the X, Y, and Z Acceleration data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: 3 Line Combo
    /// Line Width: 5 Pixels
    /// Line Style: Smooth
    /// Animation: Elastic
    /// Visible Data Range: (-16)-(+16)
    /// Units: Gravitational Accelerations (g's)
    /// Label Sparsity: Every two values
    func createXYZGraph(_ frame: CGRect, xLineColor: UIColor, yLineColor: UIColor, zLineColor: UIColor) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        // Setup the first line plot.
        let xLine = LinePlot(identifier: "x")
        
        xLine.lineWidth = 5
        xLine.lineColor = xLineColor
        xLine.lineStyle = ScrollableGraphViewLineStyle.smooth
        xLine.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        // Setup the second line plot.
        let yLine = LinePlot(identifier: "y")
        
        yLine.lineWidth = 5
        yLine.lineColor = yLineColor
        yLine.lineStyle = ScrollableGraphViewLineStyle.smooth
        yLine.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let zLine = LinePlot(identifier: "z")
        
        zLine.lineWidth = 5
        zLine.lineColor = zLineColor
        zLine.lineStyle = ScrollableGraphViewLineStyle.smooth
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
    /// DESCRIPTION: Creates a graph that shows the Resultant Acceleration data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: Line Graph
    /// Line Width: 5 Pixels
    /// Line Style: Smooth
    /// Animation: Elastic
    /// Visible Data Range: 0-16
    /// Units: Gravitational Accelerations (g's)
    /// Label Sparsity: Every two values
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
    /// DESCRIPTION: Creates a graph that shows the Electrocardiogram data that has been uploaded to AWS only.
    /// PARAMS: The total frame of the iPhone's screen.
    /// RETURNS: ScrollableGraphView configuration that can now be presented on the interface.
    /// GRAPH PROPERTIES:
    /// Graph Type: Line Graph
    /// Line Width: 3 Pixels
    /// Line Style: Smooth
    /// Point Spacing: 70 pixels
    /// Animation: None
    /// Visible Data Range: (-800)-(+800)
    /// Units: Micro Volts
    /// Label Sparsity: Every 70 values
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
    
    // MARK: Updating Graph Data
    
    /// DESCRIPTION: Updates the Heart Beat Dot/Line Graph with any new data that has been sent to AWS gathers the new data from the getHRArray() method.
    func reloadHR() {
        bloodO2Data = getHRArray().0
        numberOfDataItems = getHRArray().1
        xAxisLabels = getHRArray().2
    }
    
    /// DESCRIPTION: Updates the Blood O2 Dot/Line Graph with any new data that has been sent to AWS gathers the new data from the getBloodO2Array() method.
    func reloadSPO2() {
        bloodO2Data = getSPO2Array().0
        numberOfDataItems = getSPO2Array().1
        xAxisLabels = getSPO2Array().2
    }
    
    /// DESCRIPTION: Updates the Noise Exposure Dot/Line Graph with any new data that has been sent to AWS gathers the new data from the getNEArray() method.
    func reloadNE() {
        noiseExposData = getNEArray().0
        numberOfDataItems = getNEArray().1
        xAxisLabels = getNEArray().2
    }
    
    /// DESCRIPTION: Updates the Sleep Bar Graph with any new data that has been sent to AWS gathers the new data from the getSleepArray() method.
    func reloadSleep() {
        sleepData = getSleepArray().0
        numberOfDataItems = getSleepArray().1
        xAxisLabels = getSleepArray().2
    }
    
    /// DESCRIPTION: Updates the Resting Heart Beat Dot Plot with any new data that has been sent to AWS gathers the new data from the getRHRArray() method.
    func reloadRHR() {
        rhrData = getRHRArray().0
        numberOfDataItems = getRHRArray().1
        xAxisLabels = getRHRArray().2
    }
    
    /// DESCRIPTION: Updates the Heart Beat Variability Line Graph with any new data that has been sent to AWS gathers the new data from the getHRVArray() method.
    func reloadHRV() {
        hrvData = getHRVArray().0
        numberOfDataItems = getHRVArray().1
        xAxisLabels = getHRVArray().2
    }
    
    /// DESCRIPTION: Overwrites the 3 X, Y, and Z Acceleration Line Graphs with the newest XYZ  acceleration monitoring session done on the iPhone/Apple Watch apps. Gathers data from the getXYZArray() method.
    func reloadXYZ() {
        xData = getXYZArray().0
        yData = getXYZArray().1
        zData = getXYZArray().2
        numberOfDataItems = getXYZArray().3
        xAxisLabels = getXYZArray().4
    }
    
    /// DESCRIPTION: Updates the Resultant Acceleration Line Graph with newest resultant acceleration monitoring session done on the iPhone/Apple Watch apps. Gathers data from the getRArray() method.
    func reloadResultant() {
        rData = getRArray().0
        numberOfDataItems = getRArray().1
        xAxisLabels = getRArray().2
    }
    
    /// DESCRIPTION: Overwrites the ECG Line Graph with the most recent Electrocardiogram sample. Gathers the data from the getECGArray() method.
    func reloadECG() {
        ecgData = getECGArray().0
        numberOfDataItems = getECGArray().1
        xAxisLabels = getECGArray().2
    }
    
    // MARK: Data Retrieval
    /// DESCRIPTION: Retrieves the Heart Beat values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. Checks for the existence of stored Heart Beat values and if there are none blank values are returned.
    /// RETURNS: Returns all of the uploaded Heart Beat values as a double array, the count of that array as an integer, and all of the Heart Beat value's respective timestamps as an array of strings.
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
    
    /// DESCRIPTION: Retrieves the Blood O2 values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. Checks for the existence of stored Blood O2 values and if there are none blank values are returned.
    /// RETURNS: Returns all of the uploaded Blood O2 values as a double array, the count of that array as an integer, and all of the Blood O2 value's respective timestamps as an array of strings.
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
    
    /// DESCRIPTION: Retrieves the Noise Exposure values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. Checks for the existence of stored Noise Exposure values and if there are none blank values are returned.
    /// RETURNS: Returns all of the uploaded Noise Exposure values as a double array, the count of that array as an integer, and all of the Noise Exposure value's respective timestamps as an array of strings.
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
    
    /// DESCRIPTION: Retrieves the Time Slept values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. Checks for the existence of stored Time Slept values and if there are none blank values are returned.
    /// RETURNS: Returns all of the uploaded Time Slept values as a double array, the count of that array as an integer, and all of the Time Slept value's respective timestamps as an array of strings.
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
    
    /// DESCRIPTION: Retrieves the Resting Heart Rate values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. Checks for the existence of stored Resting Heart Rate values and if there are none blank values are returned.
    /// RETURNS: Returns all of the uploaded Resting Heart Rate values as a double array, the count of that array as an integer, and all of the Resting Heart Rate value's respective timestamps as an array of strings.
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
    
    /// DESCRIPTION: Retrieves the Heart Rate Variability values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. Checks for the existence of stored Heart Rate Variability values and if there are none blank values are returned.
    /// RETURNS: Returns all of the uploaded Heart Rate Variability values as a double array, the count of that array as an integer, and all of the Heart Rate Variability value's respective timestamps as an array of strings.
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
    
    /// DESCRIPTION: Retrieves the X, Y, and Z Acceleration values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. When a new acceleration session is recorded the data is overwritten and that data is what this method looks for. Checks for the existence of stored X, Y, and Z Acceleration values and if there are none blank values are returned.
    /// RETURNS: Returns all of the uploaded X, Y, and Z Acceleration values in the most recent session as three separate double arrays, the count of the xArray as an integer (all 3 arrays have the same count), and all of the Acceleration value's respective timestamps as an array of strings (all 3 accelerations have the same timestamps).
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
    
    /// DESCRIPTION: Retrieves the Resultant Acceleration values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. When a new acceleration session is recorded the data is overwritten and that data is what this method looks for. Checks for the existence of stored Resultant Acceleration values and if there are none blank values are returned.
    /// RETURNS: Returns all of the uploaded Resultant Acceleration values in the most recent session as a double arrays, the count of that array as an integer, and all of the Resultant Acceleration value's respective timestamps as an array of strings.
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
    
    /// DESCRIPTION: Retrieves the Electrocardiogram(ECG) values and each value's timestamp from the iPhone's internal storage. When the data was uploaded to the cloud it was stored locally so that it can be graphed later. Checks for the existence of stored Heart Rate Variability values and if there are none blank values are returned. Gathers only the data from the most recent ECG sample and overwrites teh older sample's data
    /// RETURNS: Returns all of the uploaded ECG values from the most recent ECG sample as a double array, the count of that array as an integer, and all of the ECG value's respective timestamps as an array of strings.
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

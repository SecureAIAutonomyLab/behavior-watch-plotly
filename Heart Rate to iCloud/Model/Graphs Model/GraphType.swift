//
//  GraphType.swift
//  GraphView
//
//  Created by Victor Guzman on 7/20/21
//

// MARK: Graphs
/// DESCRIPTION: The type of the current graph we are showing.
enum GraphType {
    case heartBeat
    case bloodO2
    case noiseExpos
    case sleep
    case rhr
    case hrv
    case xyz
    case result
    case ecg
    
    // MARK: Cycles +
    /// DESCRIPTION: The positive cycle for the graphs, cycles through the switch statement on case at a time when the "NEXT" button is pressed. Loops back to .heartBeat when it reaches the last case.
    mutating func next() {
        switch(self) {
        case .heartBeat:
            self = GraphType.bloodO2
        case .bloodO2:
            self = GraphType.noiseExpos
        case .noiseExpos:
            self = GraphType.sleep
        case .sleep:
            self = GraphType.rhr
        case .rhr:
            self = GraphType.hrv
        case .hrv:
            self = GraphType.xyz
        case .xyz:
            self = GraphType.result
        case .result:
            self = GraphType.ecg
        case .ecg:
            self = GraphType.heartBeat
        }
    }
    
    // MARK: Cycles +
    /// DESCRIPTION: The negative cycle for the graphs, cycles through the switch statement on case at a time when the "BACK" button is pressed. Loops back to .heartBeat when it reaches the last case.
    mutating func back() {
        switch(self) {
        case .heartBeat:
            self = GraphType.ecg
        case .ecg:
            self = GraphType.result
        case .result:
            self = GraphType.xyz
        case .xyz:
            self = GraphType.hrv
        case .hrv:
            self = GraphType.rhr
        case .rhr:
            self = GraphType.sleep
        case .sleep:
            self = GraphType.noiseExpos
        case .noiseExpos:
            self = GraphType.bloodO2
        case .bloodO2:
            self = GraphType.heartBeat
        }
    }
}

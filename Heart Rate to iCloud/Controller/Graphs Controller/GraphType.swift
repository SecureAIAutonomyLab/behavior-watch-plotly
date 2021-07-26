//
//  GraphType.swift
//  GraphView
//
//  Created by Kelly Roach on 8/18/18.
//

// The type of the current graph we are showing.
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

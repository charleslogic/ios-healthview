//
//  HeartRateSample.swift
//  HealthView
//

import Foundation

struct HeartRateSample: Identifiable {
    let id = UUID()
    let date: Date
    let bpm: Double
}

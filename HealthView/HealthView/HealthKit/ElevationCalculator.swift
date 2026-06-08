//
//  ElevationCalculator.swift
//  HealthView
//

import Foundation

enum ElevationCalculator {
    /// Total ascent and descent in feet, summed from altitude deltas between
    /// consecutive route points.
    static func gainAndLoss(from points: [RoutePoint]) -> (gain: Double, loss: Double)? {
        guard points.count > 1 else { return nil }

        var gain = 0.0
        var loss = 0.0
        for i in 1..<points.count {
            let delta = points[i].altitudeFeet - points[i - 1].altitudeFeet
            if delta > 0 {
                gain += delta
            } else {
                loss += -delta
            }
        }
        return (gain, loss)
    }
}

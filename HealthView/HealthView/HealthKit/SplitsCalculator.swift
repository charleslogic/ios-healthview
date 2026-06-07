//
//  SplitsCalculator.swift
//  HealthView
//

import CoreLocation
import Foundation

struct Split: Identifiable {
    let id = UUID()
    let index: Int
    let distanceMeters: Double
    let duration: TimeInterval

    var formattedPace: String {
        guard distanceMeters > 0 else { return "--" }
        let miles = distanceMeters / 1609.344
        let secondsPerMile = duration / miles
        let minutes = Int(secondsPerMile) / 60
        let seconds = Int(secondsPerMile) % 60
        return String(format: "%d:%02d /mi", minutes, seconds)
    }
}

enum SplitsCalculator {
    private static let metersPerMile = 1609.344

    /// Computes per-mile splits by walking the route and accumulating distance
    /// between consecutive points until each mile boundary is crossed.
    static func compute(from points: [RoutePoint]) -> [Split] {
        guard points.count > 1 else { return [] }

        var splits: [Split] = []
        var splitDistance = 0.0
        var splitStart = points[0].timestamp
        var splitIndex = 1

        for i in 1..<points.count {
            let previous = points[i - 1]
            let current = points[i]
            let segment = CLLocation(latitude: previous.coordinate.latitude, longitude: previous.coordinate.longitude)
                .distance(from: CLLocation(latitude: current.coordinate.latitude, longitude: current.coordinate.longitude))

            splitDistance += segment

            if splitDistance >= metersPerMile {
                let duration = current.timestamp.timeIntervalSince(splitStart)
                splits.append(Split(index: splitIndex, distanceMeters: splitDistance, duration: duration))

                splitIndex += 1
                splitDistance = 0
                splitStart = current.timestamp
            }
        }

        // Trailing partial split
        if splitDistance > 0 {
            let duration = points.last!.timestamp.timeIntervalSince(splitStart)
            splits.append(Split(index: splitIndex, distanceMeters: splitDistance, duration: duration))
        }

        return splits
    }
}

//
//  RoutePoint.swift
//  HealthView
//

import CoreLocation
import Foundation

struct RoutePoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let altitude: CLLocationDistance
    let timestamp: Date

    var altitudeFeet: Double {
        altitude * 3.28084
    }
}

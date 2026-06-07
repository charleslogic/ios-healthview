//
//  RoutePoint.swift
//  HealthView
//

import CoreLocation
import Foundation

struct RoutePoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
}

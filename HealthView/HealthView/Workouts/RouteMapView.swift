//
//  RouteMapView.swift
//  HealthView
//

import SwiftUI
import MapKit

struct RouteMapView: View {
    let points: [RoutePoint]
    var selectedPoint: RoutePoint?

    private var coordinates: [CLLocationCoordinate2D] {
        points.map(\.coordinate)
    }

    private var region: MKCoordinateRegion? {
        guard !coordinates.isEmpty else { return nil }
        var rect = MKMapRect.null
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }
        let padded = rect.insetBy(dx: -rect.width * 0.15, dy: -rect.height * 0.15)
        return MKCoordinateRegion(padded)
    }

    var body: some View {
        if let region {
            Map(initialPosition: .region(region)) {
                MapPolyline(coordinates: coordinates)
                    .stroke(.blue, lineWidth: 3)

                if let selectedPoint {
                    Annotation("", coordinate: selectedPoint.coordinate) {
                        Circle()
                            .fill(.red)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                            .shadow(radius: 2)
                    }
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

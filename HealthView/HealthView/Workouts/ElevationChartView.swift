//
//  ElevationChartView.swift
//  HealthView
//

import SwiftUI
import Charts

struct ElevationChartView: View {
    let points: [RoutePoint]

    var body: some View {
        Chart(points) { point in
            AreaMark(
                x: .value("Time", point.timestamp),
                y: .value("Elevation", point.altitudeFeet)
            )
            .foregroundStyle(.green.opacity(0.25))

            LineMark(
                x: .value("Time", point.timestamp),
                y: .value("Elevation", point.altitudeFeet)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(.green)
        }
        .chartYAxisLabel("ft")
        .frame(height: 140)
    }
}

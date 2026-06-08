//
//  ElevationChartView.swift
//  HealthView
//

import SwiftUI
import Charts

struct ElevationChartView: View {
    let points: [RoutePoint]

    private var yDomain: ClosedRange<Double> {
        let values = points.map(\.altitudeFeet)
        guard let lowest = values.min(), let highest = values.max() else { return 0...1 }
        let padding = max((highest - lowest) * 0.1, 1)
        return (lowest - padding)...(highest + padding)
    }

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
        .chartYScale(domain: yDomain)
        .chartYAxisLabel("ft")
        .frame(height: 140)
    }
}

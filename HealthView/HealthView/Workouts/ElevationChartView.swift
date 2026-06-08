//
//  ElevationChartView.swift
//  HealthView
//

import SwiftUI
import Charts

struct ElevationChartView: View {
    let points: [RoutePoint]
    @Binding var selectedDate: Date?

    private var yDomain: ClosedRange<Double> {
        let values = points.map(\.altitudeFeet)
        guard let lowest = values.min(), let highest = values.max() else { return 0...1 }
        let padding = max((highest - lowest) * 0.1, 1)
        return (lowest - padding)...(highest + padding)
    }

    private var selectedPoint: RoutePoint? {
        guard let selectedDate else { return nil }
        return points.min { lhs, rhs in
            abs(lhs.timestamp.timeIntervalSince(selectedDate)) < abs(rhs.timestamp.timeIntervalSince(selectedDate))
        }
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

            if let selectedPoint {
                RuleMark(x: .value("Time", selectedPoint.timestamp))
                    .foregroundStyle(.secondary.opacity(0.5))
                PointMark(
                    x: .value("Time", selectedPoint.timestamp),
                    y: .value("Elevation", selectedPoint.altitudeFeet)
                )
                .foregroundStyle(.green)
                .annotation(position: .top) {
                    Text("\(Int(selectedPoint.altitudeFeet)) ft")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.regularMaterial, in: Capsule())
                }
            }
        }
        .chartYScale(domain: yDomain)
        .chartYAxisLabel("ft")
        .chartXSelection(value: $selectedDate)
        .frame(height: 140)
    }
}

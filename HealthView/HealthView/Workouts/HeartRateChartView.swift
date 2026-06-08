//
//  HeartRateChartView.swift
//  HealthView
//

import SwiftUI
import Charts

struct HeartRateChartView: View {
    let samples: [HeartRateSample]

    private var yDomain: ClosedRange<Double> {
        let values = samples.map(\.bpm)
        guard let lowest = values.min(), let highest = values.max() else { return 0...1 }
        let padding = max((highest - lowest) * 0.1, 1)
        return (lowest - padding)...(highest + padding)
    }

    var body: some View {
        Chart(samples) { sample in
            LineMark(
                x: .value("Time", sample.date),
                y: .value("BPM", sample.bpm)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(.red)
        }
        .chartYScale(domain: yDomain)
        .chartYAxisLabel("BPM")
        .frame(height: 180)
    }
}

//
//  HeartRateChartView.swift
//  HealthView
//

import SwiftUI
import Charts

struct HeartRateChartView: View {
    let samples: [HeartRateSample]

    var body: some View {
        Chart(samples) { sample in
            LineMark(
                x: .value("Time", sample.date),
                y: .value("BPM", sample.bpm)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(.red)
        }
        .chartYAxisLabel("BPM")
        .frame(height: 180)
    }
}

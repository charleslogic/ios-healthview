//
//  HeartRateChartView.swift
//  HealthView
//

import SwiftUI
import Charts

struct HeartRateChartView: View {
    let samples: [HeartRateSample]
    @Binding var selectedDate: Date?

    private var yDomain: ClosedRange<Double> {
        let values = samples.map(\.bpm)
        guard let lowest = values.min(), let highest = values.max() else { return 0...1 }
        let padding = max((highest - lowest) * 0.1, 1)
        return (lowest - padding)...(highest + padding)
    }

    private var selectedSample: HeartRateSample? {
        guard let selectedDate else { return nil }
        return samples.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(selectedDate)) < abs(rhs.date.timeIntervalSince(selectedDate))
        }
    }

    var body: some View {
        Chart(samples) { sample in
            LineMark(
                x: .value("Time", sample.date),
                y: .value("BPM", sample.bpm)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(.red)

            if let selectedSample {
                RuleMark(x: .value("Time", selectedSample.date))
                    .foregroundStyle(.secondary.opacity(0.5))
                PointMark(
                    x: .value("Time", selectedSample.date),
                    y: .value("BPM", selectedSample.bpm)
                )
                .foregroundStyle(.red)
                .annotation(position: .top) {
                    Text("\(Int(selectedSample.bpm)) BPM")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.regularMaterial, in: Capsule())
                }
            }
        }
        .chartYScale(domain: yDomain)
        .chartYAxisLabel("BPM")
        .chartXSelection(value: $selectedDate)
        .frame(height: 180)
    }
}

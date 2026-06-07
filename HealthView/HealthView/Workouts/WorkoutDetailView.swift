//
//  WorkoutDetailView.swift
//  HealthView
//

import SwiftUI

struct WorkoutDetailView: View {
    let summary: WorkoutSummary

    @Environment(HealthKitManager.self) private var healthKitManager

    @State private var heartRateSamples: [HeartRateSample] = []
    @State private var routePoints: [RoutePoint] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    if !routePoints.isEmpty {
                        RouteMapView(points: routePoints)
                    }

                    if !heartRateSamples.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Heart Rate")
                                .font(.headline)
                            HeartRateChartView(samples: heartRateSamples)
                        }
                    }

                    let splits = SplitsCalculator.compute(from: routePoints)
                    if !splits.isEmpty {
                        SplitsView(splits: splits)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(summary.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadDetails() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(summary.startDate, style: .date)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                statView(title: "Duration", value: summary.formattedDuration)
                if let distance = summary.formattedDistance {
                    statView(title: "Distance", value: distance)
                }
                if let pace = summary.formattedPace {
                    statView(title: "Pace", value: pace)
                }
            }
        }
    }

    private func statView(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .bold()
        }
    }

    private func loadDetails() async {
        isLoading = true
        async let heartRate = try? healthKitManager.fetchHeartRateSamples(for: summary.workout)
        async let route = try? healthKitManager.fetchRoute(for: summary.workout)

        heartRateSamples = await heartRate ?? []
        routePoints = await route ?? []
        isLoading = false
    }
}

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
    @State private var selectedDate: Date?

    private var selectedRoutePoint: RoutePoint? {
        guard let selectedDate else { return nil }
        return routePoints.min { lhs, rhs in
            abs(lhs.timestamp.timeIntervalSince(selectedDate)) < abs(rhs.timestamp.timeIntervalSince(selectedDate))
        }
    }

    private var averageHeartRate: Double? {
        guard !heartRateSamples.isEmpty else { return nil }
        return heartRateSamples.map(\.bpm).reduce(0, +) / Double(heartRateSamples.count)
    }

    private var maxHeartRate: Double? {
        heartRateSamples.map(\.bpm).max()
    }

    private struct Stat: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let value: String
    }

    private var stats: [Stat] {
        var items = [Stat(icon: "clock", title: "Duration", value: summary.formattedDuration)]

        if let distance = summary.formattedDistance {
            items.append(Stat(icon: "arrow.right", title: "Distance", value: distance))
        }
        if let pace = summary.formattedPace {
            items.append(Stat(icon: "speedometer", title: "Avg Pace", value: pace))
        }
        if let speed = summary.formattedSpeed {
            items.append(Stat(icon: "gauge.with.needle", title: "Avg Speed", value: speed))
        }
        if let (gain, loss) = ElevationCalculator.gainAndLoss(from: routePoints) {
            items.append(Stat(icon: "arrow.up", title: "Elevation +", value: "\(Int(gain.rounded())) ft"))
            items.append(Stat(icon: "arrow.down", title: "Elevation -", value: "\(Int(loss.rounded())) ft"))
        }
        if let averageHeartRate {
            items.append(Stat(icon: "heart", title: "Avg HR", value: "\(Int(averageHeartRate.rounded())) bpm"))
        }
        if let maxHeartRate {
            items.append(Stat(icon: "heart.fill", title: "Max HR", value: "\(Int(maxHeartRate.rounded())) bpm"))
        }
        if let calories = summary.formattedCalories {
            items.append(Stat(icon: "flame", title: "Calories", value: calories))
        }

        return items
    }

    private let statColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    statsGrid

                    if !routePoints.isEmpty {
                        RouteMapView(points: routePoints, selectedPoint: selectedRoutePoint)
                    }

                    if !heartRateSamples.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Heart Rate")
                                .font(.headline)
                            HeartRateChartView(samples: heartRateSamples, selectedDate: $selectedDate)
                        }
                    }

                    if !routePoints.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Elevation")
                                .font(.headline)
                            ElevationChartView(points: routePoints, selectedDate: $selectedDate)
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
            HStack {
                Text(summary.startDate, style: .date)
                Text("·")
                Text(summary.sourceName)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if summary.formattedDistance == nil {
                Text("No distance recorded for this workout, so pace and splits aren't available — common for indoor or strength workouts, or activities where the source app didn't record GPS/distance.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: statColumns, spacing: 12) {
            ForEach(stats) { stat in
                StatCardView(icon: stat.icon, title: stat.title, value: stat.value)
            }
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

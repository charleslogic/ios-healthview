//
//  WorkoutListView.swift
//  HealthView
//

import SwiftUI

struct WorkoutListView: View {
    @Environment(HealthKitManager.self) private var healthKitManager

    @State private var workouts: [WorkoutSummary] = []
    @State private var isLoading = true
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Workouts")
                .task { await loadWorkouts() }
                .refreshable { await loadWorkouts() }
                .navigationDestination(for: WorkoutSummary.self) { summary in
                    WorkoutDetailView(summary: summary)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ProgressView()
        } else if let loadError {
            ContentUnavailableView("Couldn't Load Workouts", systemImage: "exclamationmark.triangle", description: Text(loadError))
        } else if workouts.isEmpty {
            ContentUnavailableView("No Workouts", systemImage: "figure.run", description: Text("Workouts you record on your Apple Watch will show up here."))
        } else {
            List(workouts) { summary in
                NavigationLink(value: summary) {
                    WorkoutRowView(summary: summary)
                }
            }
        }
    }

    private func loadWorkouts() async {
        isLoading = true
        loadError = nil
        do {
            workouts = try await healthKitManager.fetchWorkouts()
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }
}

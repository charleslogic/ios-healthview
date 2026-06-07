//
//  WorkoutListView.swift
//  HealthView
//

import SwiftUI

struct WorkoutListView: View {
    private static let pageSize = 30

    @Environment(HealthKitManager.self) private var healthKitManager

    @State private var workouts: [WorkoutSummary] = []
    @State private var isLoading = true
    @State private var isLoadingMore = false
    @State private var loadError: String?
    @State private var fetchLimit = WorkoutListView.pageSize
    @State private var reachedEnd = false

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
            List {
                ForEach(workouts) { summary in
                    NavigationLink(value: summary) {
                        WorkoutRowView(summary: summary)
                    }
                    .onAppear {
                        if summary.id == workouts.last?.id {
                            Task { await loadMoreIfNeeded() }
                        }
                    }
                }

                if isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func loadWorkouts() async {
        isLoading = true
        loadError = nil
        fetchLimit = Self.pageSize
        reachedEnd = false
        do {
            let results = try await healthKitManager.fetchWorkouts(limit: fetchLimit)
            workouts = results
            reachedEnd = results.count < fetchLimit
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }

    private func loadMoreIfNeeded() async {
        guard !isLoadingMore, !isLoading, !reachedEnd else { return }
        isLoadingMore = true
        fetchLimit += Self.pageSize
        do {
            let results = try await healthKitManager.fetchWorkouts(limit: fetchLimit)
            workouts = results
            reachedEnd = results.count < fetchLimit
        } catch {
            // Keep showing what we already have; the user can pull-to-refresh to retry.
        }
        isLoadingMore = false
    }
}

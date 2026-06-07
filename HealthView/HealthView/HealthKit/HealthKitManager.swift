//
//  HealthKitManager.swift
//  HealthView
//

import HealthKit
import CoreLocation
import Observation

@Observable
final class HealthKitManager {
    enum AuthState {
        case notDetermined
        case authorized
        case denied
    }

    private let healthStore = HKHealthStore()

    private(set) var authState: AuthState = .notDetermined

    private let readTypes: Set<HKObjectType> = [
        HKObjectType.workoutType(),
        HKQuantityType(.heartRate),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.distanceCycling),
        HKQuantityType(.activeEnergyBurned),
        HKSeriesType.workoutRoute()
    ]

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    @MainActor
    func requestAuthorization() async {
        guard isHealthDataAvailable else {
            authState = .denied
            return
        }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            // HealthKit doesn't expose granular read-authorization status for privacy
            // reasons; a successful request means the user has made a choice and the
            // app can proceed to query (queries simply return nothing for denied types).
            authState = .authorized
        } catch {
            authState = .denied
        }
    }

    func fetchWorkouts(limit: Int = 50) async throws -> [WorkoutSummary] {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout()],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: limit
        )
        let workouts = try await descriptor.result(for: healthStore)
        return workouts.map { WorkoutSummary(workout: $0) }
    }

    func fetchHeartRateSamples(for workout: HKWorkout) async throws -> [HeartRateSample] {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKSamplePredicate.quantitySample(
            type: heartRateType,
            predicate: HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate)
        )
        let descriptor = HKSampleQueryDescriptor(
            predicates: [predicate],
            sortDescriptors: [SortDescriptor(\.startDate, order: .forward)]
        )
        let samples = try await descriptor.result(for: healthStore)
        let unit = HKUnit.count().unitDivided(by: .minute())
        return samples.map { sample in
            HeartRateSample(date: sample.startDate, bpm: sample.quantity.doubleValue(for: unit))
        }
    }

    func fetchRoute(for workout: HKWorkout) async throws -> [RoutePoint] {
        let routePredicate = HKSamplePredicate.sample(
            type: HKSeriesType.workoutRoute(),
            predicate: HKQuery.predicateForObjects(from: workout)
        )
        let routeDescriptor = HKSampleQueryDescriptor(
            predicates: [routePredicate],
            sortDescriptors: []
        )
        let routes = try await routeDescriptor.result(for: healthStore)
        guard let route = routes.first as? HKWorkoutRoute else { return [] }

        return try await withCheckedThrowingContinuation { continuation in
            var points: [RoutePoint] = []
            var didResume = false
            let query = HKWorkoutRouteQuery(route: route) { _, locationsOrNil, done, errorOrNil in
                guard !didResume else { return }
                if let error = errorOrNil {
                    didResume = true
                    continuation.resume(throwing: error)
                    return
                }
                if let locations = locationsOrNil {
                    points.append(contentsOf: locations.map {
                        RoutePoint(coordinate: $0.coordinate, altitude: $0.altitude, timestamp: $0.timestamp)
                    })
                }
                if done {
                    didResume = true
                    continuation.resume(returning: points)
                }
            }
            healthStore.execute(query)
        }
    }
}

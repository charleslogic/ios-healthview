//
//  WorkoutSummary.swift
//  HealthView
//

import HealthKit
import Foundation

struct WorkoutSummary: Identifiable, Hashable {
    let workout: HKWorkout

    static func == (lhs: WorkoutSummary, rhs: WorkoutSummary) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: UUID { workout.uuid }
    var activityType: HKWorkoutActivityType { workout.workoutActivityType }
    var startDate: Date { workout.startDate }
    var endDate: Date { workout.endDate }
    var duration: TimeInterval { workout.duration }

    var totalDistanceMeters: Double? {
        workout.statistics(for: HKQuantityType(.distanceWalkingRunning))?
            .sumQuantity()?.doubleValue(for: .meter())
            ?? workout.statistics(for: HKQuantityType(.distanceCycling))?
            .sumQuantity()?.doubleValue(for: .meter())
    }

    var totalEnergyBurnedKilocalories: Double? {
        workout.statistics(for: HKQuantityType(.activeEnergyBurned))?
            .sumQuantity()?.doubleValue(for: .kilocalorie())
    }

    var displayName: String {
        switch activityType {
        case .running: return "Run"
        case .walking: return "Walk"
        case .cycling: return "Ride"
        case .swimming: return "Swim"
        case .hiking: return "Hike"
        case .traditionalStrengthTraining, .functionalStrengthTraining: return "Strength"
        case .yoga: return "Yoga"
        case .elliptical: return "Elliptical"
        case .rowing: return "Rowing"
        case .coreTraining: return "Core Training"
        case .highIntensityIntervalTraining: return "HIIT"
        default: return "Workout"
        }
    }

    var formattedDistance: String? {
        guard let meters = totalDistanceMeters, meters > 0 else { return nil }
        let miles = meters / 1609.344
        return String(format: "%.2f mi", miles)
    }

    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = duration >= 3600 ? [.hour, .minute] : [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }

    var formattedPace: String? {
        guard let meters = totalDistanceMeters, meters > 0 else { return nil }
        let miles = meters / 1609.344
        let secondsPerMile = duration / miles
        let minutes = Int(secondsPerMile) / 60
        let seconds = Int(secondsPerMile) % 60
        return String(format: "%d:%02d /mi", minutes, seconds)
    }
}

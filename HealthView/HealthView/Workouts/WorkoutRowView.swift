//
//  WorkoutRowView.swift
//  HealthView
//

import SwiftUI
import HealthKit

struct WorkoutRowView: View {
    let summary: WorkoutSummary

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .imageScale(.large)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(summary.displayName)
                    .font(.headline)
                Text(summary.startDate, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(summary.formattedDuration)
                    .font(.subheadline)
                if let distance = summary.formattedDistance {
                    Text(distance)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch summary.activityType {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .hiking: return "figure.hiking"
        case .traditionalStrengthTraining, .functionalStrengthTraining: return "dumbbell"
        case .yoga: return "figure.yoga"
        case .elliptical: return "figure.elliptical"
        case .rowing: return "figure.rower"
        case .coreTraining: return "figure.core.training"
        case .highIntensityIntervalTraining: return "figure.highintensity.intervaltraining"
        default: return "figure.mixed.cardio"
        }
    }
}

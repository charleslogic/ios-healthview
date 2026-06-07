//
//  ContentView.swift
//  HealthView
//

import SwiftUI

struct ContentView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @State private var isRequestingAccess = false

    var body: some View {
        Group {
            switch healthKitManager.authState {
            case .authorized:
                WorkoutListView()
            case .notDetermined, .denied:
                connectPromptView
            }
        }
        .task {
            await healthKitManager.requestAuthorization()
        }
    }

    private var connectPromptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .imageScale(.large)
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Connect to Health")
                .font(.title2)
                .bold()

            Text("HealthView reads your workouts, heart rate, and routes from the Health app to show your activity history.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if healthKitManager.authState == .denied {
                Text("Access wasn't granted. You can change this in Settings → Privacy & Security → Health → HealthView.")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                isRequestingAccess = true
                Task {
                    await healthKitManager.requestAuthorization()
                    isRequestingAccess = false
                }
            } label: {
                if isRequestingAccess {
                    ProgressView()
                } else {
                    Text("Connect")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRequestingAccess)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(HealthKitManager())
}

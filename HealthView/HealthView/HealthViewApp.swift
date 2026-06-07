//
//  HealthViewApp.swift
//  HealthView
//
//  Created by Charles on 6/7/26.
//

import SwiftUI

@main
struct HealthViewApp: App {
    @State private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(healthKitManager)
        }
    }
}

//
//  StatCardView.swift
//  HealthView
//

import SwiftUI

struct StatCardView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

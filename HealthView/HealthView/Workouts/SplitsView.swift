//
//  SplitsView.swift
//  HealthView
//

import SwiftUI

struct SplitsView: View {
    let splits: [Split]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Splits")
                .font(.headline)

            ForEach(splits) { split in
                HStack {
                    Text("Mile \(split.index)")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(split.formattedPace)
                }
                .font(.subheadline)
            }
        }
    }
}

//
//  EmptyStateView.swift
//  lernig
//
//  Created by Furkan Gönel on 4.08.2025.
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(title)
                .font(.custom("SFProRounded-Medium", size: 20))
                .foregroundColor(.secondary)

            Text(subtitle)
                .font(.custom("SFProRounded-Medium", size: 14))
                .foregroundColor(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

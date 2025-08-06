//
//  PrimaryButtonStyle.swift
//  lernig
//
//  Created by Furkan Gönel on 30.07.2025.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    let color: String
    //let font: String
    //let fontSize: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            //.font(.custom(font, size: fontSize))
            .foregroundColor(.black)
            .background(Color(color))
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

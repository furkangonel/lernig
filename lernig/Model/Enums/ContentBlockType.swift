//
//  ContentBlockType.swift
//  lernig
//
//  Created by Furkan Gönel on 5.08.2025.
//


import Foundation

enum ContentBlockType {
    case markdown(String)
    case inlineMath(String)
    case blockMath(String)
}

struct ContentBlock: Identifiable {
    let id = UUID()
    let type: ContentBlockType
}
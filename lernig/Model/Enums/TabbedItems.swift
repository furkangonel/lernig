//
//  TabbedItems.swift
//  lernig
//
//  Created by Furkan Gönel on 3.08.2025.
//

import Foundation


enum TabbedItems: Int, CaseIterable {
    
    case statistics = 0
    case lessons
    case profile
    
    
    var title: String {
        switch self {
        case .statistics:
            return "Statistics"
        case .lessons:
            return "Lessons"
        case .profile:
            return "Profile"
        }
    }
    
    
    var iconName: String {
        switch self {
        case .statistics:
            return "statistic_icon"
        case .lessons:
            return "lesson_icon"
        case .profile:
            return "profile_icon"
        }
    }
    
    
}

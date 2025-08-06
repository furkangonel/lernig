//
//  CustomTabView.swift
//  lernig
//
//  Created by Furkan Gönel on 3.08.2025.
//

import SwiftUI

struct CustomTabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var lessonViewModel: LessonViewModel
    @State private var selectedTab = 1
    
    init() {
        self._lessonViewModel = StateObject(wrappedValue: LessonViewModel(currentUserId: ""))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                StatisticPage()
                    .tag(0)
                
                LessonsPage(lessonViewModel: lessonViewModel)
                    .tag(1)
                
                ProfilePage()
                    .tag(2)
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    lessonViewModel.currentUserId = userId
                }
                
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.clear
                appearance.shadowImage = nil
                appearance.shadowColor = nil
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }

            ZStack {
                HStack {
                    ForEach((TabbedItems.allCases), id: \.self) { item in
                        Button {
                            selectedTab = item.rawValue
                        } label: {
                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                        }
                    }
                }
                .padding(6)
            }
            .frame(height: 60)
            .background(Color("c_3").opacity(0.2))
            .cornerRadius(35)
            .padding(.horizontal, 26)
            .transition(.move(edge: .bottom))
    }
}

extension CustomTabBarView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color("b_w"))
                    .bold()
            }
            Spacer()
        }
        .frame(width: isActive ? 150 : 60, height: 50)
        .background(isActive ? Color("c_3").opacity(09) : .clear)
        .cornerRadius(30)
    }
}



#Preview {
    CustomTabBarView()
        .environmentObject(AuthViewModel())
}

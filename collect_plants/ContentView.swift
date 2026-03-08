//
//  ContentView.swift
//  collect_plants
//
//  Created by 中島さくら on 2026/03/08.
//

import SwiftUI

struct ContentView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.95, green: 0.99, blue: 0.93, alpha: 1.0)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(red: 0.25, green: 0.50, blue: 0.28, alpha: 1.0)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.25, green: 0.50, blue: 0.28, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        itemAppearance.selected.iconColor = UIColor(red: 0.18, green: 0.48, blue: 0.22, alpha: 1.0)
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.18, green: 0.48, blue: 0.22, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 11, weight: .bold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = UIColor(red: 0.18, green: 0.48, blue: 0.22, alpha: 1.0)

    }

    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("探す", systemImage: "camera.fill")
                }

            DictionaryView()
                .tabItem {
                    Label("図鑑", systemImage: "book.fill")
                }

            PlantMapView()
                .tabItem {
                    Label("マップ", systemImage: "map.fill")
                }

            GardenView()
                .tabItem {
                    Label("植物園", systemImage: "tree.fill")
                }
        }
        .tint(AppTheme.tabBarTint)
    }
}

#Preview {
    ContentView()
}

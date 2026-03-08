//
//  collect_plantsApp.swift
//  collect_plants
//
//  Created by 中島さくら on 2026/03/08.
//

import SwiftUI

@main
struct collect_plantsApp: App {
    let coreDataService = CoreDataService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataService.context)
                .preferredColorScheme(.light)
        }
    }
}

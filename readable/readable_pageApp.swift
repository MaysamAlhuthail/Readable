//
//  readable_pageApp.swift
//  readable page
//
//  Created by Najd Alsabi on 09/06/1447 AH.
//

import SwiftUI

@main
struct readable_App: App {
    
    @StateObject var settings = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainSettingsView()
                .environmentObject(settings)
                .preferredColorScheme(.light)
        }
    }
}

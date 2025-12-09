//
//  readable_pageApp.swift
//  readable page
//
//  Created by Najd Alsabi on 09/06/1447 AH.
//

import SwiftUI

@main
struct YourAppNameApp: App {
    @StateObject var settings = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplashView()
            }
            .environmentObject(settings)
        }
    }
}

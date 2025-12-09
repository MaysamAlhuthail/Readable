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
    @StateObject var vm = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                //
                SplashView()}
                    .environmentObject(settings)
                    .environmentObject(vm)
                    .preferredColorScheme(.light)
            }
        }
    }


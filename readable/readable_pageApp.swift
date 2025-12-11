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
    @State private var isSheet = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                //
                SplashView(isSheet: $isSheet)
            }
            .environmentObject(settings)
            .environmentObject(vm)
            .preferredColorScheme(.light)
        }
    }
}

//
//  splash.swift
//  Readable
//
//  Created by Aseel Basalama on 02/12/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var goToSettings = false

    var body: some View {
        ZStack {
            // Background color (light beige)
            Color(red: 0.98, green: 0.95, blue: 0.90)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App icon
                Image("logoImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 250)
                    .cornerRadius(40)
                    .shadow(radius: 12)

                // Title
                Text("Welcome !")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color("dbroun"))

                // Button navigates to MainSettingsView
                Button(action: {
                    goToSettings = true
                }) {
                    Text("Let’s start reading your way")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color("dblue"))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                }
                .background(Color.white.opacity(0.7))
                .cornerRadius(20)
                .padding(.horizontal, 40)
                .shadow(radius: 4, y: 2)

                Spacer()
            }
        }
        .navigationDestination(isPresented: $goToSettings) {
            MainSettingsView()
                // Remove this environmentObject(...) if you already provided it in the App file
                .environmentObject(SettingsViewModel())
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SplashView()
                .environmentObject(SettingsViewModel())
        }
    }
}

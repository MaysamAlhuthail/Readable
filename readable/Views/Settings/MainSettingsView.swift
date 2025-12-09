//
//  MainSettingsView.swift
//  readable page
//
//  Created by Najd Alsabi on 09/06/1447 AH.
//

import SwiftUI

struct MainSettingsView: View {

    @EnvironmentObject var settings: SettingsViewModel
    @State private var selectedTab = 0
    @State private var goToHome = false

    var body: some View {
        ZStack {
            // Using a named color asset "background" (fallback to system background if you prefer)
            Color("background")
                .ignoresSafeArea()

            VStack {
                // MARK: - Segmented Tabs
                HStack(spacing: 0) {
                    Text("Text")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(selectedTab == 0 ? Color.white : Color.clear)
                        .cornerRadius(12)
                        .foregroundColor(Color("dblue"))
                        .onTapGesture { selectedTab = 0 }

                    Text("Colors")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(selectedTab == 1 ? Color.white : Color.clear)
                        .cornerRadius(12)
                        .foregroundColor(Color("dblue"))
                        .onTapGesture { selectedTab = 1 }
                }
                .padding(6)
                .background(Color.black.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)

                // MARK: - Content
                if selectedTab == 0 {
                    TextSettingsView()
                } else {
                    ColorSettingsView()
                }

                Spacer()

                // Bottom button
                Button {
                    if selectedTab == 0 {
                        // Go to Colors tab
                        selectedTab = 1
                    } else {
                        // Go to HomePage
                        goToHome = true
                    }
                } label: {
                    Text(selectedTab == 0 ? "Next" : "Done")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 95, height: 50)
                        .background(Color("dblue"))
                        .cornerRadius(25)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .navigationDestination(isPresented: $goToHome) {
            HomePage()
        }
    }
}

struct MainSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MainSettingsView()
                .environmentObject(SettingsViewModel())
        }
    }
}

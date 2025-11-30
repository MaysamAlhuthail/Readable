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
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                // MARK: - Segmented Tabs
                HStack(spacing: 0) {
                    Text("Text")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(selectedTab == 0 ? Color.white : Color.clear)
                        .cornerRadius(12)
                        .foregroundColor(.black)
                        .onTapGesture { selectedTab = 0 }

                    Text("Colors")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(selectedTab == 1 ? Color.white : Color.clear)
                        .cornerRadius(12)
                        .foregroundColor(.black)
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
                    // Next / Done action
                } label: {
                    Text(selectedTab == 0 ? "Next" : "Done")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.background)
                        .frame(width: 95, height: 50)
                        .background(Color("Dblue"))
                        .cornerRadius(25)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
}

struct MainSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MainSettingsView()
            .environmentObject(SettingsViewModel())
    }
}

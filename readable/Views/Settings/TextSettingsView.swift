//
//  TextSettingsView.swift
//  readable page
//
//  Created by Najd Alsabi on 09/06/1447 AH.
//

import SwiftUI

struct TextSettingsView: View {
    
    @EnvironmentObject var settings: SettingsViewModel
    
    var body: some View {
        VStack {
            // MARK: - White Text Box
            VStack(spacing: 16) {
                
                if settings.isBionic,
                   let attributed = try? AttributedString(markdown: sampleText()) {
                    Text(attributed)
                        .font(.custom(settings.fonts[settings.fontIndex],
                                      size: settings.fontSize))
                        .kerning(settings.wordSpacing)
                        .lineSpacing(settings.lineSpacing)
                        .multilineTextAlignment(.center)
                        .padding()
                        .animation(.easeInOut, value: settings.fontIndex)
                } else {
                    Text(sampleText())
                        .font(.custom(settings.fonts[settings.fontIndex],
                                      size: settings.fontSize))
                        .kerning(settings.wordSpacing)
                        .lineSpacing(settings.lineSpacing)
                        .multilineTextAlignment(.center)
                        .padding()
                        .animation(.easeInOut, value: settings.fontIndex)
                }
                // 👆 باقي الإعدادات نفسها ما تغيّرت
                
                // MARK: - Font Picker Arrows
                HStack {
                    Text("fonts")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.dbroun)
                    
                    Spacer()
                    
                    Button {
                        if settings.fontIndex > 0 { settings.fontIndex -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.dblue)
                            .padding(.horizontal)
                    }
                    
                    Text(settings.fonts[settings.fontIndex])
                        .foregroundColor(Color.dbroun)
                    
                    Button {
                        if settings.fontIndex < settings.fonts.count - 1 {
                            settings.fontIndex += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.dblue)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .padding(.horizontal)
            .padding(.top, 10)
            
            // MARK: - Controls Section
            VStack(alignment: .leading, spacing: 20) {
                SettingRow(title: "Size",
                           value: $settings.fontSize,
                           step: 1,
                           range: 10...40)
                
                SettingRow(title: "Word Spacing",
                           value: $settings.wordSpacing,
                           step: 1,
                           range: 0...10)
                
                SettingRow(title: "Line Spacing",
                           value: $settings.lineSpacing,
                           step: 1,
                           range: 0...30)
                
                HStack {
                    Text("Bionic")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.dbroun)
                    Spacer()
                    Toggle("", isOn: $settings.isBionic)
                        .labelsHidden()
                }
            }
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(25)
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    private func sampleText() -> String {
        let text = """
        This is a text sample to try different fonts, sizes, word spacing, line spacing and even bionic font to get the most comfortable with our app!
        """
        return settings.formatted(text)
    }
}

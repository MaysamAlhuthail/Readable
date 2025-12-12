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
                SettingRowWithValue(title: "Size",
                                   value: $settings.fontSize,
                                   step: 1,
                                   range: 10...72)
                
                SettingRowWithValue(title: "Word Spacing",
                                   value: $settings.wordSpacing,
                                   step: 1,
                                   range: 0...10)
                
                SettingRowWithValue(title: "Line Spacing",
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

// MARK: - SettingRow الجديد مع عرض القيمة
struct SettingRowWithValue: View {
    let title: String
    @Binding var value: CGFloat
    let step: CGFloat
    let range: ClosedRange<CGFloat>
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color.dbroun)
            
            Spacer()
            
            // زر الناقص
            Button {
                if value > range.lowerBound {
                    value -= step
                }
            } label: {
                Image(systemName: "minus")
                    .foregroundColor(Color.dblue)
                    .frame(width: 30, height: 30)
            }
            
            // عرض القيمة الحالية
            Text("\(Int(value))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.dbroun)
                .frame(minWidth: 40)
            
            // زر الزائد
            Button {
                if value < range.upperBound {
                    value += step
                }
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(Color.dblue)
                    .frame(width: 30, height: 30)
            }
        }
    }
}

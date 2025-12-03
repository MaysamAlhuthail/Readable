//
//  ColorSettingsView.swift
//  readable page
//
//  Created by Najd Alsabi on 09/06/1447 AH.
//

import SwiftUI

struct ColorSettingsView: View {
    
    @EnvironmentObject var settings: SettingsViewModel
    
    // Base colors (the ones you had before)
    private let baseBackgrounds: [Color] = [
        Color.white,
        Color(red: 0.97, green: 0.95, blue: 0.93),
        Color(red: 0.94, green: 0.90, blue: 0.86),
        Color(red: 0.90, green: 0.86, blue: 0.82),
        Color(red: 0.86, green: 0.82, blue: 0.78),
        Color(red: 0.82, green: 0.78, blue: 0.72),
        Color(red: 0.80, green: 0.76, blue: 0.70),
        Color(red: 0.76, green: 0.72, blue: 0.66)
    ]
    
    private let baseTextColors: [Color] = [
        .black,
        Color(red: 0.37, green: 0.27, blue: 0.17),
        .gray,
        Color(red: 0.45, green: 0.36, blue: 0.29),
        Color(red: 0.60, green: 0.50, blue: 0.43),
        Color(red: 0.25, green: 0.20, blue: 0.15),
        Color(red: 0.15, green: 0.15, blue: 0.20),
        Color(red: 0.55, green: 0.40, blue: 0.35)
    ]
    
    // Custom (wheel) colors
    @State private var customBackgroundColor: Color = .white
    @State private var customTextColor: Color = .black
    
    // Computed arrays that include the custom color as the last item
    private var backgrounds: [Color] {
        baseBackgrounds + [customBackgroundColor]
    }
    
    private var textColors: [Color] {
        baseTextColors + [customTextColor]
    }
    
    // Indices for the custom (wheel) colors
    private var customBackgroundIndex: Int {
        backgrounds.count - 1
    }
    
    private var customTextIndex: Int {
        textColors.count - 1
    }
    
    private let colorsPerPage = 5
    @State private var bgPage = 0
    @State private var textPage = 0
    
    var body: some View {
        VStack {
            // MARK: - Preview
            VStack {
                Text(sampleText())
                    .font(.custom(settings.fonts[settings.fontIndex],
                                  size: settings.fontSize))
                    .kerning(settings.wordSpacing)
                    .lineSpacing(settings.lineSpacing)
                    .multilineTextAlignment(.center)
                    .foregroundColor(textColors[safe: settings.textColorIndex] ?? .black)
                    .padding()
            }
            .padding()
            .background(backgrounds[safe: settings.backgroundColorIndex] ?? Color.white)
            .cornerRadius(25)
            .padding(.horizontal)
            .padding(.top, 10)
            
            // MARK: - Color Pickers
            VStack(alignment: .leading, spacing: 24) {
                
                // Background color
                VStack(alignment: .leading, spacing: 12) {
                    Text("Background Color")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.dbroun)
                    
                    HStack(spacing: 18) {
                        ForEach(backgroundIndicesForCurrentPage(), id: \.self) { i in
                            if i == customBackgroundIndex {
                                // ✅ Custom color wheel circle
                                ColorPicker("",
                                            selection: $customBackgroundColor,
                                            supportsOpacity: false)
                                    .labelsHidden()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.dblue,
                                                    lineWidth: settings.backgroundColorIndex == i ? 3 : 0)
                                    )
                                    // Whenever user picks a color, select this circle
                                    .onChange(of: customBackgroundColor) { _ in
                                        settings.backgroundColorIndex = customBackgroundIndex
                                    }
                            } else {
                                Button {
                                    settings.backgroundColorIndex = i
                                } label: {
                                    Circle()
                                        .fill(backgrounds[i])
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.dblue,
                                                        lineWidth: settings.backgroundColorIndex == i ? 3 : 0)
                                        )
                                }
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button {
                                if bgPage > 0 { bgPage -= 1 }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color.dblue)
                                    .opacity(bgPage > 0 ? 1 : 0.3)
                            }
                            .disabled(bgPage == 0)
                            
                            Button {
                                if (bgPage + 1) * colorsPerPage < backgrounds.count {
                                    bgPage += 1
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.dblue)
                                    .opacity((bgPage + 1) * colorsPerPage < backgrounds.count ? 1 : 0.3)
                            }
                            .disabled((bgPage + 1) * colorsPerPage >= backgrounds.count)
                        }
                    }
                }
                
                Divider()
                
                // Text color
                VStack(alignment: .leading, spacing: 12) {
                    Text("Text Color")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.dbroun)
                    
                    HStack(spacing: 18) {
                        ForEach(textIndicesForCurrentPage(), id: \.self) { i in
                            if i == customTextIndex {
                                // ✅ Custom text color wheel circle
                                ColorPicker("",
                                            selection: $customTextColor,
                                            supportsOpacity: false)
                                    .labelsHidden()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.dblue,
                                                    lineWidth: settings.textColorIndex == i ? 3 : 0)
                                    )
                                    .onChange(of: customTextColor) { _ in
                                        settings.textColorIndex = customTextIndex
                                    }
                            } else {
                                Button {
                                    settings.textColorIndex = i
                                } label: {
                                    Circle()
                                        .fill(textColors[i])
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.dblue,
                                                        lineWidth: settings.textColorIndex == i ? 3 : 0)
                                        )
                                }
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button {
                                if textPage > 0 { textPage -= 1 }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color.dblue)
                                    .opacity(textPage > 0 ? 1 : 0.3)
                            }
                            .disabled(textPage == 0)
                            
                            Button {
                                if (textPage + 1) * colorsPerPage < textColors.count {
                                    textPage += 1
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.dblue)
                                    .opacity((textPage + 1) * colorsPerPage < textColors.count ? 1 : 0.3)
                            }
                            .disabled((textPage + 1) * colorsPerPage >= textColors.count)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.6))
            .cornerRadius(25)
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    // MARK: - Helpers
    
    private func sampleText() -> String {
        let text = """
        This is a text sample to try the different colors that are available for the background and text to get the most comfortable with our app!
        """
        return settings.formatted(text)
    }
    
    private func backgroundIndicesForCurrentPage() -> [Int] {
        let start = bgPage * colorsPerPage
        let end = min(start + colorsPerPage, backgrounds.count)
        return Array(start..<end)
    }
    
    private func textIndicesForCurrentPage() -> [Int] {
        let start = textPage * colorsPerPage
        let end = min(start + colorsPerPage, textColors.count)
        return Array(start..<end)
    }
}

// Safe indexing
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

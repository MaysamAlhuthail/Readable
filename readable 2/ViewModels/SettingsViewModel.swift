//
//  SettingsViewModel.swift
//  readable page
//
//  Created by Najd Alsabi on 09/06/1447 AH.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    
    // MARK: - Published settings (shared across app + persisted)
    @Published var fontIndex: Int {
        didSet { save() }
    }
    @Published var fontSize: CGFloat {
        didSet { save() }
    }
    @Published var wordSpacing: CGFloat {
        didSet { save() }
    }
    @Published var lineSpacing: CGFloat {
        didSet { save() }
    }
    @Published var isBionic: Bool {
        didSet { save() }
    }
    @Published var backgroundColorIndex: Int {
        didSet { save() }
    }
    @Published var textColorIndex: Int {
        didSet { save() }
    }
    
    // Fonts used everywhere
    let fonts = ["Comic Sans MS", "Arial Rounded MT Bold", "Helvetica Neue"]
    
    // MARK: - Keys
    private struct Keys {
        static let fontIndex = "fontIndex"
        static let fontSize = "fontSize"
        static let wordSpacing = "wordSpacing"
        static let lineSpacing = "lineSpacing"
        static let isBionic = "isBionic"
        static let backgroundColorIndex = "backgroundColorIndex"
        static let textColorIndex = "textColorIndex"
    }
    
    // MARK: - Init (load from UserDefaults)
    init() {
        let defaults = UserDefaults.standard
        
        self.fontIndex = defaults.integer(forKey: Keys.fontIndex)
        
        let savedFontSize = defaults.double(forKey: Keys.fontSize)
        self.fontSize = savedFontSize == 0 ? 18 : CGFloat(savedFontSize)
        
        let savedWordSpacing = defaults.double(forKey: Keys.wordSpacing)
        self.wordSpacing = CGFloat(savedWordSpacing)
        
        let savedLineSpacing = defaults.double(forKey: Keys.lineSpacing)
        self.lineSpacing = savedLineSpacing == 0 ? 5 : CGFloat(savedLineSpacing)
        
        self.isBionic = defaults.bool(forKey: Keys.isBionic)
        
        self.backgroundColorIndex = defaults.integer(forKey: Keys.backgroundColorIndex)
        self.textColorIndex = defaults.integer(forKey: Keys.textColorIndex)
    }
    
    // MARK: - Save to UserDefaults
    private func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(fontIndex, forKey: Keys.fontIndex)
        defaults.set(Double(fontSize), forKey: Keys.fontSize)
        defaults.set(Double(wordSpacing), forKey: Keys.wordSpacing)
        defaults.set(Double(lineSpacing), forKey: Keys.lineSpacing)
        defaults.set(isBionic, forKey: Keys.isBionic)
        defaults.set(backgroundColorIndex, forKey: Keys.backgroundColorIndex)
        defaults.set(textColorIndex, forKey: Keys.textColorIndex)
    }
    
    // MARK: - Bionic helper
    func formatted(_ text: String) -> String {
        guard isBionic else { return text }
        return applyBionic(to: text)
    }
    
    private func applyBionic(to text: String) -> String {
        let words = text.split(separator: " ")
        return words
            .map {
                let w = String($0)
                let cut = max(1, w.count / 2)
                return "**\(w.prefix(cut))**\(w.dropFirst(cut))"
            }
            .joined(separator: " ")
    }
}

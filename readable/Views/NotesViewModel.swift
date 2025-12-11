//
//  NotesViewModel.swift
//  Readable
//
//  Created by Ghala Alsalem on 11/12/2025.
//


import Foundation
import SwiftUI
import UIKit
import Combine

class NotesViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }
    
    private let storageKey = "notes_storage_v1"
    
    init() {
        loadNotes()
    }
    
    var filteredNotes: [Note] {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let base: [Note]
        
        if text.isEmpty {
            base = notes
        } else {
            base = notes.filter { $0.title.localizedCaseInsensitiveContains(text) }
        }
        
        return base.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func createNote(withTitle title: String) -> Note {
        let newNote = Note(title: title)
        notes.insert(newNote, at: 0)
        return newNote
    }
    
    func rename(_ note: Note, to newTitle: String) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].title = newTitle
        notes[index].updatedAt = Date()
    }
    
    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
    }
    
    func updateColor(_ note: Note, to color: Color) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].color = color
        notes[index].updatedAt = Date()
    }
    
    private struct StoredNote: Codable {
        let id: UUID
        let title: String
        let content: String
        let r: Double
        let g: Double
        let b: Double
        let a: Double
        let updatedAt: Date
    }
    
    private func saveNotes() {
        let stored: [StoredNote] = notes.map { note in
            let uiColor = UIColor(note.color)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            return StoredNote(
                id: note.id,
                title: note.title,
                content: note.content,
                r: Double(r),
                g: Double(g),
                b: Double(b),
                a: Double(a),
                updatedAt: note.updatedAt
            )
        }
        
        if let data = try? JSONEncoder().encode(stored) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let stored = try? JSONDecoder().decode([StoredNote].self, from: data) else {
            return
        }
        
        notes = stored.map { item in
            let color = Color(
                .sRGB,
                red: item.r,
                green: item.g,
                blue: item.b,
                opacity: item.a
            )
            return Note(
                id: item.id,
                title: item.title,
                content: item.content,
                color: color,
                updatedAt: item.updatedAt
            )
        }
    }
}

enum PendingNameAction {
    case new
    case rename(Note)
    
    var alertTitle: String {
        switch self {
        case .new:
            return "New note"
        case .rename:
            return "Rename note"
        }
    }
}

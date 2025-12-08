// MARK: - Note.swift (MODEL)

import Foundation

struct Note: Identifiable, Hashable {
    let id: UUID
    var title: String
    var content: String

    init(id: UUID = UUID(), title: String, content: String = "") {
        self.id = id
        self.title = title
        self.content = content
    }
}
// MARK: - NotesViewModel.swift (VIEW MODEL)

import Foundation
import Combine

class NotesViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    @Published var notes: [Note] = [
        Note(title: "Oct to do list"),
        Note(title: "Study plan"),
        Note(title: "Groceries"),
        Note(title: "Ideas"),
        Note(title: "Reading notes"),
        Note(title: "Random thoughts")
    ]
    
    var filteredNotes: [Note] {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return notes
        } else {
            return notes.filter { $0.title.localizedCaseInsensitiveContains(text) }
        }
    }
    
    func createNote(withTitle title: String) -> Note {
        let newNote = Note(title: title)
        notes.insert(newNote, at: 0)
        return newNote
    }
    
    func rename(_ note: Note, to newTitle: String) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else { return }
        notes[index].title = newTitle
    }
    
    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }
    }
    
    func duplicate(_ note: Note) {
        let copy = Note(title: note.title, content: note.content)
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.insert(copy, at: index + 1)
        } else {
            notes.append(copy)
        }
    }
}
// MARK: - NotesView.swift (VIEW - NOTES LIST)

import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var path = NavigationPath()
    
    @State private var isNamingAlertPresented = false
    @State private var nameText = ""
    @State private var pendingNameAction: PendingNameAction?
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color("background").ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    header
                    searchBar

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.filteredNotes) { note in
                                NavigationLink(value: note) {
                                    NoteCard(note: note)
                                }
                                .contextMenu {
                                    Button("Rename") {
                                        pendingNameAction = .rename(note)
                                        nameText = note.title
                                        isNamingAlertPresented = true
                                    }
                                    Button("Duplicate") {
                                        viewModel.duplicate(note)
                                    }
                                    Button("Delete", role: .destructive) {
                                        viewModel.delete(note)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .navigationDestination(for: Note.self) { note in
                if let binding = binding(for: note) {
                    NoteDetailView(note: binding)
                } else {
                    Text("Note not found")
                }
            }
            .alert(pendingNameAction?.alertTitle ?? "", isPresented: $isNamingAlertPresented) {
                TextField("Note name", text: $nameText)
                Button("Cancel", role: .cancel) {
                    nameText = ""
                    pendingNameAction = nil
                }
                Button("Done") {
                    let trimmed = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty, let action = pendingNameAction else { return }
                    
                    switch action {
                    case .new:
                        let newNote = viewModel.createNote(withTitle: trimmed)
                        path.append(newNote)
                    case .rename(let note):
                        viewModel.rename(note, to: trimmed)
                    }
                    
                    nameText = ""
                    pendingNameAction = nil
                }
            } message: {
                if let action = pendingNameAction, case .rename(_) = action {
                    Text("Enter a new name for this note.")
                } else {
                    Text("Enter a name for your new note.")
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Notes")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(Color("dblue"))
            
            Spacer()
            
            Button {
                pendingNameAction = .new
                nameText = ""
                isNamingAlertPresented = true
            } label: {
                Image("addnotesicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search notes", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            Button {} label: {
                Image(systemName: "mic.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color("background"))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
        )
    }
    
    private func binding(for note: Note) -> Binding<Note>? {
        guard let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) else {
            return nil
        }
        return $viewModel.notes[index]
    }
}

struct NoteCard: View {
    let note: Note
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("default"))
            
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("background"))
                    .frame(height: 150)
                
                Text(note.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(16)
        }
        .frame(height: 230)
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
 // MARK: - NoteDetailView.swift (VIEW - NOTE DETAIL)

import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFocused: Bool

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                TextEditor(text: $note.content)
                    .focused($isTextFocused)
                    .padding(.horizontal, 16)
                    .scrollContentBackground(.hidden)
                    .background(Color("background"))
            }
        }
        .onAppear {
            isTextFocused = true
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("dblue"))
            }
            
            Text(note.title.isEmpty ? "Note name" : note.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("dblue"))
                .padding(.leading, 4)
            
            Spacer()
            
            Button {} label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("dblue"))
            }
            .padding(.trailing, 12)
            
            Button {} label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("dblue"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    NoteDetailView(
        note: .constant(
            Note(title: "Note name", content: "Sample content")
        )
    )
}

//
//  NotesView.swift
//  Readable
//
//  Created by Ghala Alsalem on 11/12/2025.
//


import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var isNamingAlertPresented = false
    @State private var nameText = ""
    @State private var pendingNameAction: PendingNameAction?
    
    @State private var isColorSheetPresented = false
    @State private var colorSheetNote: Note?
    @State private var colorSheetColor: Color = Color(hex: "6C93A3")
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    header
                    searchBar

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.filteredNotes) { note in
                                if let binding = binding(for: note) {
                                    NavigationLink {
                                        NoteDetailView(note: binding)
                                    } label: {
                                        NoteCard(note: note)
                                    }
                                    .contextMenu {
                                        Button("Change color") {
                                            colorSheetNote = note
                                            colorSheetColor = note.color
                                            isColorSheetPresented = true
                                        }
                                        Button("Rename") {
                                            pendingNameAction = .rename(note)
                                            nameText = note.title
                                            isNamingAlertPresented = true
                                        }
                                        Button("Delete", role: .destructive) {
                                            viewModel.delete(note)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .sheet(isPresented: $isColorSheetPresented) {
                ColorPickerSheet(selectedColor: $colorSheetColor)
                    .onDisappear {
                        if let note = colorSheetNote {
                            viewModel.updateColor(note, to: colorSheetColor)
                        }
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
                        _ = viewModel.createNote(withTitle: trimmed)
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
                Image("note")
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
                .fill(note.color)
            
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("background"))
                    .frame(height: 150)
                    .overlay(
                        Text(previewText)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                            .multilineTextAlignment(.leading)
                    )
                
                Text(note.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black.opacity(0.85))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
        .frame(height: 230)
    }
    
    private var previewText: String {
        if note.content.isEmpty {
            return "No content yet"
        } else if note.content.count > 80 {
            let prefix = note.content.prefix(80)
            return "\(prefix)…"
        } else {
            return note.content
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) var dismiss
    
    let presetColors: [Color] = [
        Color(hex: "6C93A3"),
        Color(hex: "A3C993"),
        Color(hex: "E8B4A3"),
        Color(hex: "B4A3D6"),
        Color(hex: "F4C2C2"),
        Color(hex: "FFD93D"),
        Color(hex: "6BCB77"),
        Color(hex: "FF6B6B"),
        Color(hex: "4ECDC4"),
        Color(hex: "95E1D3")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Choose a color for your file card")
                    .font(.headline)
                    .padding(.top)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(presetColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.black.opacity(0.2),
                                        lineWidth: selectedColor == color ? 3 : 0
                                    )
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
                .padding()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom Color")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    ColorPicker("", selection: $selectedColor)
                        .labelsHidden()
                }
                .padding()
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "17374F"))
                .cornerRadius(12)
                .padding()
            }
            .navigationTitle("Card Color")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NotesView()
}
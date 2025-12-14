//
//  NotesView.swift
//  Readable
//
//  Created by Ghala Alsalem on 11/12/2025.
//
import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @EnvironmentObject var settings: SettingsViewModel

    @State private var isNamingAlertPresented = false
    @State private var nameText = ""
    @State private var pendingNameAction: PendingNameAction?

    @State private var isColorSheetPresented = false
    @State private var colorSheetNote: Note?
    @State private var colorSheetColor: Color = Color(hex: "6C93A3")

    @State private var showSettings = false
    @State private var isSheet = false

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
                        if viewModel.filteredNotes.isEmpty {
                            VStack(spacing: 8) {
                                Text("No notes yet")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color("dblue"))

                                Text("Tap the plus button to create your first note.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding(.top, 40)
                        } else {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(viewModel.filteredNotes, id: \.id) { note in
                                    if let binding = binding(for: note) {
                                        NavigationLink {
                                            NoteDetailView(
                                                note: binding,
                                                showSettings: $showSettings,
                                                isSheet: $isSheet
                                            )
                                            .environmentObject(settings)
                                        } label: {
                                            NoteCard(note: note)
                                                .environmentObject(settings)
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .sheet(isPresented: $isColorSheetPresented) {
                NoteColorPickerSheet(selectedColor: $colorSheetColor)
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
                if let action = pendingNameAction, case .rename = action {
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
    @EnvironmentObject var settings: SettingsViewModel

    private let textColors: [Color] = [
        .black,
        Color(red: 0.37, green: 0.27, blue: 0.17),
        .gray,
        Color(red: 0.45, green: 0.36, blue: 0.29),
        Color(red: 0.60, green: 0.50, blue: 0.43),
        Color(red: 0.25, green: 0.20, blue: 0.15),
        Color(red: 0.15, green: 0.15, blue: 0.20),
        Color(red: 0.55, green: 0.40, blue: 0.35)
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(note.color)

            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.75))
                    .frame(height: 150)
                    .overlay(
                        previewTextView
                            .padding(.horizontal, 10)
                    )

                Text(note.title)
                    .font(.custom(settings.fonts[settings.fontIndex], size: 18))
                    .foregroundColor((textColors[safe: settings.textColorIndex] ?? .black).opacity(0.9))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
        .frame(height: 230)
    }

    @ViewBuilder
    private var previewTextView: some View {
        let text = previewText
        let c = (textColors[safe: settings.textColorIndex] ?? .gray).opacity(0.75)

        if settings.isBionic,
           let attributed = try? AttributedString(markdown: settings.formatted(text)) {
            Text(attributed)
                .font(.custom(settings.fonts[settings.fontIndex], size: 13))
                .foregroundColor(c)
                .multilineTextAlignment(.leading)
        } else {
            Text(text)
                .font(.custom(settings.fonts[settings.fontIndex], size: 13))
                .foregroundColor(c)
                .multilineTextAlignment(.leading)
        }
    }

    private var previewText: String {
        if note.content.isEmpty { return "No content yet" }
        if note.content.count > 80 { return "\(note.content.prefix(80))…" }
        return note.content
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


struct NoteColorPickerSheet: View {
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

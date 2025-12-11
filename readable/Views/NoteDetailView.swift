//
//  NoteDetailView.swift
//  Readable
//
//  Created by Ghala Alsalem on 11/12/2025.
//


//
import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @EnvironmentObject var settings: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFocused: Bool

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $note.content)
                        .font(.custom(settings.fonts[settings.fontIndex],
                                      size: settings.fontSize))
                        .kerning(settings.wordSpacing)
                        .lineSpacing(settings.lineSpacing)
                        .focused($isTextFocused)
                        .padding(.horizontal, 16)
                        .scrollContentBackground(.hidden)
                        .background(Color("background"))
                        .opacity(settings.isBionic ? 0.02 : 1)
                    
                    if settings.isBionic,
                       let attributed = try? AttributedString(
                            markdown: settings.formatted(note.content)
                       ) {
                        ScrollView {
                            Text(attributed)
                                .font(.custom(settings.fonts[settings.fontIndex],
                                              size: settings.fontSize))
                                .kerning(settings.wordSpacing)
                                .lineSpacing(settings.lineSpacing)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }
                        .allowsHitTesting(false)
                    }
                }
            }
        }
        .onAppear {
            isTextFocused = true
        }
        .onChange(of: note.content) {
            note.updatedAt = Date()
        }
        .navigationBarBackButtonHidden(true)
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
    .environmentObject(SettingsViewModel())
}

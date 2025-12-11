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
}

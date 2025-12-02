//
//  HomePage.swift
//  Readable
//
//  Created by Aseel Basalama on 02/12/2025.
//

import SwiftUI

// MARK: - HEX Color Support

//extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex)
//        _ = scanner.scanString("#")
//
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//
//        let r = Double((rgb >> 16) & 0xFF) / 255
//        let g = Double((rgb >> 8) & 0xFF) / 255
//        let b = Double(rgb & 0xFF) / 255
//
//        self.init(red: r, green: g, blue: b)
//    }
//}

// MARK: - App Colors

extension Color {
    static let appBackground = Color(hex: "FAEDE3") // background
    static let appBlue       = Color(hex: "6C93A3") // border / cards
    static let appNavy       = Color(hex: "17374F") // text / icons
}

// MARK: - MODEL

struct DocumentItem: Identifiable {
    let id = UUID()
    let title: String
    let snippet: String
    let isNote: Bool
}

// MARK: - VIEW MODEL (MVVM)

final class HomeViewModel: ObservableObject {
    // input from the view
    @Published var searchText: String = ""
    
    // underlying data (could come from network / DB later)
    @Published private(set) var files: [DocumentItem] = []
    @Published private(set) var notes: [DocumentItem] = []
    
    init() {
        // sample data (previous hard-coded values)
        let fileSnippet =
        "When I wake up, the other side of the bed is cold. My fingers stretch out, seeking Prim's warmth but finding only the rough canvas cover of the mattress. She must have had bad dreams and climbed in with our mother. Of course, she did."
        
        let noteSnippet =
        "Groceries, school assignments, and meetings. Water plants, Clean Bedroom, Do the Laundry..."
        
        files = [
            DocumentItem(title: "The Hunger Games", snippet: fileSnippet, isNote: false),
            DocumentItem(title: "Harry Potter", snippet: fileSnippet, isNote: false),
            DocumentItem(title: "The Great Gatsby", snippet: fileSnippet, isNote: false)
        ]
        
        notes = [
            DocumentItem(title: "Oct to do list", snippet: noteSnippet, isNote: true),
            DocumentItem(title: "Nov to do list", snippet: noteSnippet, isNote: true),
            DocumentItem(title: "Dec to do list", snippet: noteSnippet, isNote: true)
        ]
    }
    
    // filtered outputs for the view (reactive to searchText)
    var filteredFiles: [DocumentItem] {
        guard !searchText.isEmpty else { return files }
        return files.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredNotes: [DocumentItem] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - MAIN VIEW (uses ViewModel)

struct HomePage: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Search bar
                    SearchBar(text: $viewModel.searchText)
                        .padding(.top, 24)
                    
                    // FILES
                    SectionHeader(title: "Files")
                    HorizontalCardList(items: viewModel.filteredFiles)
                    
                    // NOTES
                    SectionHeader(title: "Notes")
                    HorizontalCardList(items: viewModel.filteredNotes)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appNavy.opacity(0.6))
            
            TextField("Search", text: $text)
                .textFieldStyle(.plain)
                .foregroundColor(.appNavy)
                .submitLabel(.search)
            
            Spacer()
            
            Button {
            } label: {
                Image(systemName: "mic.fill")
                    .foregroundColor(.appNavy)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
        )
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.appNavy)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appNavy)
            
            Spacer()
        }
    }
}

// MARK: - Horizontal Card List

struct HorizontalCardList: View {
    let items: [DocumentItem]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(items) { item in
                    FileCard(title: item.title,
                             snippet: item.snippet,
                             isNote: item.isNote)
                }
            }
        }
    }
}

// MARK: - File Card

struct FileCard: View {
    let title: String
    let snippet: String
    let isNote: Bool
    
    private let cardWidth: CGFloat  = 140
    private let cardHeight: CGFloat = 190
    private let footerHeight: CGFloat = 30
    private let borderInset: CGFloat = 7
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // OUTER BLUE CARD
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appBlue)
                .frame(width: cardWidth, height: cardHeight)
            
            // INNER WHITE PREVIEW PANEL
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .padding(.horizontal, borderInset)
                .padding(.top, borderInset)
                .padding(.bottom, footerHeight + borderInset)
                .overlay(
                    // PREVIEW TEXT INSIDE THE WHITE AREA
                    Text(snippet)
                        .font(.system(size: 10))
                        .foregroundColor(Color.gray.opacity(0.9))
                        .lineLimit(7)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 12)
                        .padding(.top, 40),
                    alignment: .topLeading
                )
            
            // BLUE FOOTER BAR (TITLE) INSIDE THE CARD
            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.appBlue)
                    
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appNavy)
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                }
                .frame(height: footerHeight)
                .padding(.horizontal, borderInset)
                .padding(.bottom, borderInset)
            }
            .frame(width: cardWidth, height: cardHeight)
            
            // ICON: BLUE SQUARE + NAVY OUTLINE, TOP-LEFT
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.appBlue)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isNote ? "list.bullet.rectangle" : "doc.text")
                        .font(.system(size: 27))
                        .foregroundColor(.appNavy)
                )
                .padding(.leading, 6)
                .padding(.top, 5)
        }
        .frame(width: cardWidth, height: cardHeight)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .previewDevice("iPhone 16 Pro")
    }
}


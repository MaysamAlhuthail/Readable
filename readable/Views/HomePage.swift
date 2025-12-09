//
//  HomePage.swift
//  Readable
//
//  Created by Aseel Basalama on 02/12/2025.
//

import SwiftUI

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

// MARK: - VIEW MODEL
final class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""

    @Published private(set) var files: [DocumentItem] = []
    @Published private(set) var notes: [DocumentItem] = []

    init() {
        let fileSnippet =
        "When I wake up, the other side of the bed is cold. My fingers stretch out, seeking Prim's warmth..."

        let noteSnippet =
        "Groceries, school assignments, and meetings. Water plants, Clean Bedroom, Laundry..."

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

    var filteredFiles: [DocumentItem] {
        guard !searchText.isEmpty else { return files }
        return files.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var filteredNotes: [DocumentItem] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - MAIN VIEW
struct HomePage: View {

    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var vm: AppViewModel
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // UPDATED Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding(.top, 24)

                    NavigationLink {
                        filesPage()
                            
                    } label: {
                        SectionHeader(title: "Files")
                    }
                    .buttonStyle(.plain)
                    HorizontalCardList(items: viewModel.filteredFiles)

                    NavigationLink{
                                            NotesView()}
                                        label:{
                                            SectionHeader(title: "Notes")
                                        } .buttonStyle(.plain)
                    HorizontalCardList(items: viewModel.filteredNotes)


                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - UPDATED SEARCH BAR (final)
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundColor(Color("Gray")) // icon color

            TextField("Search", text: $text)
                .textFieldStyle(.plain)
                .foregroundColor(Color("Gray")) // text color
                .font(.system(size: 20, weight: .medium))

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(hex: "767680").opacity(0.12)) // darker bar, 12% opacity
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

            RoundedRectangle(cornerRadius: 24)
                .fill(Color.appBlue)
                .frame(width: cardWidth, height: cardHeight)

            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .padding(.horizontal, borderInset)
                .padding(.top, borderInset)
                .padding(.bottom, footerHeight + borderInset)
                .overlay(
                    Text(snippet)
                        .font(.system(size: 10))
                        .foregroundColor(Color.gray.opacity(0.9))
                        .lineLimit(7)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 12)
                        .padding(.top, 40),
                    alignment: .topLeading
                )

            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.appBlue)
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

            RoundedRectangle(cornerRadius: 10)
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

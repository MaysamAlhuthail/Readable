//
//  HomePage.swift
//  Readable
//
//  Created by Aseel Basalama on 02/12/2025.
//
import SwiftUI

extension Color {
    static let appBackground = Color(hex: "FAEDE3")
    static let appBlue = Color(hex: "6C93A3")
    static let appNavy = Color(hex: "17374F")
}

struct DocumentItem: Identifiable {
    let id = UUID()
    let fileURL: URL
    let title: String
    let snippet: String
    let isNote: Bool
    let lastOpened: Date
    let color: Color
}

final class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var files: [DocumentItem] = []
    @Published private(set) var notes: [DocumentItem] = []

    init() {
        loadRecentFiles()
        loadRecentNotes()
    }
    
    func loadRecentFiles() {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: [.creationDateKey],
                options: []
            ).filter { $0.pathExtension == "txt" }
            
            let recentlyOpened = getRecentlyOpenedFiles()
            var documentItems: [DocumentItem] = []
            
            for fileURL in fileURLs {
                let title = fileURL.deletingPathExtension().lastPathComponent
                let content = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
                let snippet = String(content.prefix(100))
                let lastOpened = recentlyOpened[fileURL.path] ?? Date(timeIntervalSince1970: 0)
                
                documentItems.append(
                    DocumentItem(
                        fileURL: fileURL,
                        title: title,
                        snippet: snippet,
                        isNote: false,
                        lastOpened: lastOpened,
                        color: .appBlue
                    )
                )
            }
            
            files = documentItems
                .sorted { $0.lastOpened > $1.lastOpened }
                .prefix(3)
                .map { $0 }
            
        } catch {
            files = []
        }
    }
    
    func loadRecentNotes() {
        let storageKey = "notes_storage_v2"
        
        struct StoredNote: Codable {
            let id: UUID
            let title: String
            let content: String
            let r: Double
            let g: Double
            let b: Double
            let a: Double
            let updatedAt: Date
        }
        
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let stored = try? JSONDecoder().decode([StoredNote].self, from: data) else {
            notes = []
            return
        }
        
        notes = stored
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(3)
            .map { s in
                let noteColor = Color(
                    .sRGB,
                    red: s.r,
                    green: s.g,
                    blue: s.b,
                    opacity: s.a
                )
                
                let snippet = s.content.isEmpty ? "" : String(s.content.prefix(100))
                
                return DocumentItem(
                    fileURL: URL(fileURLWithPath: ""),
                    title: s.title,
                    snippet: snippet,
                    isNote: true,
                    lastOpened: s.updatedAt,
                    color: noteColor
                )
            }
    }
    
    private func getRecentlyOpenedFiles() -> [String: Date] {
        guard let data = UserDefaults.standard.data(forKey: "recentlyOpenedFiles"),
              let dict = try? JSONDecoder().decode([String: TimeInterval].self, from: data) else {
            return [:]
        }
        
        return dict.mapValues { Date(timeIntervalSince1970: $0) }
    }
    
    static func markFileAsOpened(_ fileURL: URL) {
        var recentFiles = UserDefaults.standard.data(forKey: "recentlyOpenedFiles")
            .flatMap { try? JSONDecoder().decode([String: TimeInterval].self, from: $0) } ?? [:]
        
        recentFiles[fileURL.path] = Date().timeIntervalSince1970
        
        if let encoded = try? JSONEncoder().encode(recentFiles) {
            UserDefaults.standard.set(encoded, forKey: "recentlyOpenedFiles")
        }
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

struct HomePage: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    SearchBar(text: $viewModel.searchText)
                        .padding(.top, 24)

                    NavigationLink {
                        filesPage()
                    } label: {
                        SectionHeader(title: "Files")
                    }
                    .buttonStyle(.plain)
                    
                    if !viewModel.filteredFiles.isEmpty {
                        HorizontalCardList(items: viewModel.filteredFiles)
                    }

                    NavigationLink {
                        NotesView()
                    } label: {
                        SectionHeader(title: "Notes")
                    }
                    .buttonStyle(.plain)
                    
                    if !viewModel.filteredNotes.isEmpty {
                        HorizontalCardList(items: viewModel.filteredNotes)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.loadRecentFiles()
            viewModel.loadRecentNotes()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundColor(Color("Gray"))

            TextField("Search", text: $text)
                .textFieldStyle(.plain)
                .foregroundColor(Color("Gray"))
                .font(.system(size: 20, weight: .medium))

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(hex: "767680").opacity(0.12))
        )
    }
}

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

struct HorizontalCardList: View {
    let items: [DocumentItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(items) { item in
                    if item.isNote {
                        FileCard(title: item.title, snippet: item.snippet, isNote: item.isNote, color: item.color)
                    } else {
                        NavigationLink(destination: FileDetailViewFromHome(fileURL: item.fileURL)) {
                            FileCard(title: item.title, snippet: item.snippet, isNote: item.isNote, color: item.color)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct FileCard: View {
    let title: String
    let snippet: String
    let isNote: Bool
    let color: Color

    private let cardWidth: CGFloat = 140
    private let cardHeight: CGFloat = 190
    private let footerHeight: CGFloat = 30
    private let borderInset: CGFloat = 7

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(color)
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
                    Rectangle().fill(color)
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
                .fill(color)
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

struct FileDetailViewFromHome: View {
    let fileURL: URL
    @State private var content: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @EnvironmentObject var settings: SettingsViewModel
    
    private let backgrounds: [Color] = [
        Color.white,
        Color(red: 0.97, green: 0.95, blue: 0.93),
        Color(red: 0.94, green: 0.90, blue: 0.86),
        Color(red: 0.90, green: 0.86, blue: 0.82),
        Color(red: 0.86, green: 0.82, blue: 0.78),
        Color(red: 0.82, green: 0.78, blue: 0.72),
        Color(red: 0.80, green: 0.76, blue: 0.70),
        Color(red: 0.76, green: 0.72, blue: 0.66)
    ]
    
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
            (backgrounds[safe: settings.backgroundColorIndex] ?? Color.white)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading file...")
            } else if let error = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Error Loading File")
                        .font(.headline)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            } else if content.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("File is empty")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if settings.isBionic,
                           let attributed = try? AttributedString(markdown: settings.formatted(content)) {
                            Text(attributed)
                                .font(.custom(settings.fonts[settings.fontIndex], size: settings.fontSize))
                                .kerning(settings.wordSpacing)
                                .lineSpacing(settings.lineSpacing)
                                .foregroundColor(textColors[safe: settings.textColorIndex] ?? .black)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text(content)
                                .font(.custom(settings.fonts[settings.fontIndex], size: settings.fontSize))
                                .kerning(settings.wordSpacing)
                                .lineSpacing(settings.lineSpacing)
                                .foregroundColor(textColors[safe: settings.textColorIndex] ?? .black)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadFileContent()
            HomeViewModel.markFileAsOpened(fileURL)
        }
    }
    
    func loadFileContent() {
        isLoading = true
        errorMessage = nil
        
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        
        if !fileExists {
            errorMessage = "File does not exist"
            isLoading = false
            return
        }
        
        do {
            content = try String(contentsOf: fileURL, encoding: .utf8)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .previewDevice("iPhone 16 Pro")
    }
}

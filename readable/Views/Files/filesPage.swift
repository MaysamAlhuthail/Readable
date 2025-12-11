//
//  filesPage.swift
//  Readable
//
//  Created by Maysam alhuthail on 09/06/1447 AH.
//
import SwiftUI

struct filesPage: View {
    
    @State private var files: [URL] = []
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var vm: AppViewModel
    @State private var searchText = ""
    @State private var showAddPopup = false
    @State private var showScanner = false
    @State private var selectedFile: URL? = nil
    @State private var navigateToFile = false
    
    // For rename functionality
    @State private var showRenameAlert = false
    @State private var fileToRename: URL?
    @State private var newFileName = ""
    
    // Grid layout
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {

                // Top Bar
                HStack {
                    Text("Files")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "17374F"))

                    Spacer()

                    // Add Button
                    Button(action: {
                        showAddPopup = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "17374F"))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                .padding(.horizontal)

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search File", text: $searchText)
                        .foregroundColor(.primary)

                    Image(systemName: "mic.fill")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(15)
                .padding(.horizontal)

                // Grid of File Cards
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredFiles, id: \.self) { file in
                            FileCardView(
                                fileURL: file,
                                onTap: {
                                    selectedFile = file
                                    navigateToFile = true
                                },
                                onRename: {
                                    fileToRename = file
                                    newFileName = file.deletingPathExtension().lastPathComponent
                                    showRenameAlert = true
                                },
                                onDelete: {
                                    deleteFile(file)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .navigationDestination(isPresented: $navigateToFile) {
                    if let file = selectedFile {
                        FileDetailView(fileURL: file)
                            .environmentObject(settingsViewModel)
                    }
                }
                .onAppear {
                    files = loadTextFiles()
                }
                .onChange(of: showScanner) { isShowing in
                    if !isShowing {
                        files = loadTextFiles()
                    }
                }
            }
        }
        // Rename Alert
        .alert("Rename File", isPresented: $showRenameAlert) {
            TextField("File name", text: $newFileName)
            Button("Cancel", role: .cancel) {
                fileToRename = nil
                newFileName = ""
            }
            Button("Rename") {
                if let file = fileToRename {
                    renameFile(file, to: newFileName)
                }
                fileToRename = nil
                newFileName = ""
            }
        } message: {
            Text("Enter a new name for this file.")
        }
        // Pop-up
        .sheet(isPresented: $showAddPopup) {
            VStack(spacing: 20) {
                Text("Add New File")
                    .font(.title)
                    .bold()

                Text("Add your options or UI here…")

                Button(action: {
                    showAddPopup = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        showScanner = true
                    }
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Scan Text")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "17374F"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Button("Close") {
                    showAddPopup = false
                }
                .padding()
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showScanner) {
            ContentViewCam(isPresented: $showScanner)
                .environmentObject(vm)
                .ignoresSafeArea()
        }
    }
 
    var filteredFiles: [URL] {
        if searchText.isEmpty {
            return files
        } else {
            return files.filter {
                $0.lastPathComponent.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func loadTextFiles() -> [URL] {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: [.creationDateKey],
                options: []
            )
            
            // Filter for .txt files and sort by creation date (newest first)
            return files
                .filter { $0.pathExtension == "txt" }
                .sorted { file1, file2 in
                    guard let date1 = try? file1.resourceValues(forKeys: [.creationDateKey]).creationDate,
                          let date2 = try? file2.resourceValues(forKeys: [.creationDateKey]).creationDate else {
                        return false
                    }
                    return date1 > date2 // Newest first
                }
        } catch {
            print("Error loading files: \(error)")
            return []
        }
    }
    
    func renameFile(_ file: URL, to newName: String) {
        let folder = file.deletingLastPathComponent()
        let newURL = folder.appendingPathComponent(newName + ".txt")
        
        do {
            try FileManager.default.moveItem(at: file, to: newURL)
            files = loadTextFiles()
            print("✅ Renamed file to: \(newName)")
        } catch {
            print("❌ Failed to rename file: \(error)")
        }
    }
    
    func deleteFile(_ file: URL) {
        do {
            try FileManager.default.removeItem(at: file)
            files = loadTextFiles()
            print("✅ Deleted file: \(file.lastPathComponent)")
        } catch {
            print("❌ Failed to delete file: \(error)")
        }
    }
}

// MARK: - File Card View
struct FileCardView: View {
    let fileURL: URL
    let onTap: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    
    @State private var content: String = ""
    @State private var cardColor: Color = Color(hex: "6C93A3") // Default blue
    @State private var showColorPicker = false
    
    private let cardWidth: CGFloat = 160
    private let cardHeight: CGFloat = 220
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Outer colored border/background
            RoundedRectangle(cornerRadius: 24)
                .fill(cardColor)
                .frame(width: cardWidth, height: cardHeight)
            
            // Inner white content area
            VStack(spacing: 0) {
                // White content area
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .overlay(
                        VStack(alignment: .leading, spacing: 8) {
                            // File icon
                            Image(systemName: "doc.text")
                                .font(.system(size: 28))
                                .foregroundColor(Color(hex: "17374F"))
                            
                            // Preview text
                            Text(content.isEmpty ? "Loading..." : content)
                                .font(.system(size: 10))
                                .foregroundColor(Color.gray.opacity(0.8))
                                .lineLimit(6)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    )
                    .padding(.horizontal, 7)
                    .padding(.top, 7)
                    .padding(.bottom, 37)
                
                Spacer()
            }
            .frame(width: cardWidth, height: cardHeight)
            
            // Bottom title bar
            VStack {
                Spacer()
                ZStack {
                    Rectangle()
                        .fill(cardColor)
                        .frame(height: 30)
                    
                    Text(fileURL.deletingPathExtension().lastPathComponent)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "17374F"))
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                }
                .padding(.horizontal, 7)
                .padding(.bottom, 7)
            }
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(width: cardWidth, height: cardHeight)
        .onTapGesture {
            // Mark file as recently opened
            HomeViewModel.markFileAsOpened(fileURL)
            onTap()
        }
        .contextMenu {
            Button {
                showColorPicker = true
            } label: {
                Label("Change Color", systemImage: "paintpalette")
            }
            
            Button {
                onRename()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(selectedColor: $cardColor)
        }
        .onAppear {
            loadPreview()
            loadSavedColor()
        }
        .onChange(of: cardColor) { _ in
            saveColor()
        }
    }
    
    func loadPreview() {
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            content = text
        } catch {
            content = ""
        }
    }
    
    func saveColor() {
        let key = "fileColor_\(fileURL.lastPathComponent)"
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(cardColor), requiringSecureCoding: false) {
            UserDefaults.standard.set(colorData, forKey: key)
        }
    }
    
    func loadSavedColor() {
        let key = "fileColor_\(fileURL.lastPathComponent)"
        if let colorData = UserDefaults.standard.data(forKey: key),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            cardColor = Color(uiColor)
        }
    }
}

// MARK: - Color Picker Sheet
struct ColorPickerSheet: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) var dismiss
    
    let presetColors: [Color] = [
        Color(hex: "6C93A3"), // Default blue
        Color(hex: "A3C993"), // Green
        Color(hex: "E8B4A3"), // Peach
        Color(hex: "B4A3D6"), // Purple
        Color(hex: "F4C2C2"), // Pink
        Color(hex: "FFD93D"), // Yellow
        Color(hex: "6BCB77"), // Light green
        Color(hex: "FF6B6B"), // Red
        Color(hex: "4ECDC4"), // Teal
        Color(hex: "95E1D3"), // Mint
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Choose a color for your file card")
                    .font(.headline)
                    .padding(.top)
                
                // Preset colors grid
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
                                    .stroke(Color.black.opacity(0.2), lineWidth: selectedColor == color ? 3 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
                .padding()
                
                Divider()
                
                // Custom color picker
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

// MARK: - File Detail View
struct FileDetailView: View {
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

// MARK: - Extensions
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

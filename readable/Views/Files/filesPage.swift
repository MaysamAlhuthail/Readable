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

                Spacer()
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(filteredFiles, id: \.self) { file in
                            Button(action: {
                                selectedFile = file
                                navigateToFile = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(Color(hex: "17374F"))
                                        .font(.system(size: 24))
                                    
                                    Text(file.lastPathComponent)
                                        .foregroundColor(.primary)
                                        .font(.system(size: 18))

                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                            .buttonStyle(FileButtonStyle())
                        }
                    }
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
            let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "txt" }
        } catch {
            print("Error loading files: \(error)")
            return []
        }
    }
}

// ✅ UPDATED FileDetailView with Settings Applied
struct FileDetailView: View {
    let fileURL: URL
    @State private var content: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @EnvironmentObject var settings: SettingsViewModel
    
    // Colors from ColorSettingsView
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
            // Apply background color from settings
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
                    
                    Text("File path: \(fileURL.path)")
                        .font(.caption)
                        .foregroundColor(.gray)
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
                        // Display the text with all settings applied
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
        
        // Check if file exists
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        print("📁 File exists: \(fileExists)")
        print("📁 File path: \(fileURL.path)")
        
        if !fileExists {
            errorMessage = "File does not exist at path"
            isLoading = false
            return
        }
        
        do {
            content = try String(contentsOf: fileURL, encoding: .utf8)
            print("✅ Successfully loaded file: \(fileURL.lastPathComponent)")
            print("📄 Content length: \(content.count) characters")
            print("📄 First 100 chars: \(content.prefix(100))")
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load file: \(error)")
            isLoading = false
        }
    }
}

// Safe array indexing
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

// Button style for file items
struct FileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

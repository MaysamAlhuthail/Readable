//
//  File.swift
//  readable page
//
//  Created by Maysam alhuthail on 11/06/1447 AH.
//

import Foundation
import AVKit
import Foundation
import SwiftUI
import VisionKit

enum ScanType: String {
    case barcode, text
}

enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class AppViewModel: ObservableObject {
    
    @Published var shouldRefreshFiles = false
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems = true

    // Optional: so UI can react after saving
    @Published var lastSavedFileURL: URL?
    @Published var lastSaveError: String?

    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }

    // Combine all recognized text into one string
    var recognizedText: String {
        recognizedItems.compactMap { item in
            if case .text(let text) = item {
                return text.transcript
            } else {
                return nil
            }
        }
        .joined(separator: "\n")
    }

    // ✅ NEW: Extract first three words from text
    private func getFirstThreeWords(from text: String) -> String {
        // Clean the text: remove extra whitespace and newlines
        let cleanedText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        // Get first 3 words
        let firstThreeWords = cleanedText.prefix(3).joined(separator: " ")
        
        // If we have words, return them, otherwise return a default
        if firstThreeWords.isEmpty {
            return "Untitled"
        }
        
        // Clean the string to make it safe for filename (remove special characters)
        let safeFileName = firstThreeWords
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "*", with: "-")
            .replacingOccurrences(of: "?", with: "-")
            .replacingOccurrences(of: "\"", with: "-")
            .replacingOccurrences(of: "<", with: "-")
            .replacingOccurrences(of: ">", with: "-")
            .replacingOccurrences(of: "|", with: "-")
        
        return safeFileName
    }

    // ✅ UPDATED: save with automatic naming based on content
    func saveRecognizedTextToFile(fileName: String? = nil) {
        let textToSave = recognizedText
        guard !textToSave.isEmpty else {
            lastSaveError = "There is no text to save."
            return
        }

        // Use provided name, or generate from first 3 words, or use timestamp
        let baseName: String
        if let fileName = fileName, !fileName.isEmpty {
            baseName = fileName
        } else {
            // Generate name from first 3 words
            let autoName = getFirstThreeWords(from: textToSave)
            baseName = autoName
        }
        
        let finalFileName = baseName + ".txt"

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(finalFileName)
        
        // If file already exists, add a number
        var uniqueFileURL = fileURL
        var counter = 1
        while FileManager.default.fileExists(atPath: uniqueFileURL.path) {
            let nameWithCounter = baseName + " \(counter)"
            uniqueFileURL = documentsURL.appendingPathComponent(nameWithCounter + ".txt")
            counter += 1
        }

        do {
            try textToSave.write(to: uniqueFileURL, atomically: true, encoding: .utf8)
            lastSavedFileURL = uniqueFileURL
            lastSaveError = nil
            print("✅ Saved scanned text to: \(uniqueFileURL)")
        } catch {
            lastSaveError = error.localizedDescription
            print("❌ Failed to save file: \(error)")
        }
    }

    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized \(recognizedItems.count) item(s)"
        }
    }
    
      var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
        
        default: break
            
        }
    }
    
    
}

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

    // 👇 NEW: combine all recognized text into one string
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

    // 👇 NEW: save the recognized text into a .txt file in Documents folder
    func saveRecognizedTextToFile(fileName: String? = nil) {
        let textToSave = recognizedText
        guard !textToSave.isEmpty else {
            lastSaveError = "There is no text to save."
            return
        }

        let baseName = (fileName?.isEmpty == false ? fileName! : "Scan-\(Date().timeIntervalSince1970)")
        let finalFileName = baseName + ".txt"

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(finalFileName)

        do {
            try textToSave.write(to: fileURL, atomically: true, encoding: .utf8)
            lastSavedFileURL = fileURL
            lastSaveError = nil
            print("✅ Saved scanned text to: \(fileURL)")
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

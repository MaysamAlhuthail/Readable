// MARK: - Note.swift (MODEL)

import SwiftUI

struct Note: Identifiable {
    let id: UUID
    var title: String
    var content: String
    var color: Color
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        color: Color = Color(hex: "6C93A3"),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.color = color
        self.updatedAt = updatedAt
    }
}


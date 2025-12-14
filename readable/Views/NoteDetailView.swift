//
//  NoteDetailView.swift
//  Readable
//
//  Created by Ghala Alsalem on 11/12/2025.
//


//
import SwiftUI
import UIKit

struct NoteDetailView: View {
    @Binding var note: Note
    @EnvironmentObject var settings: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var showSettings: Bool
    @Binding var isSheet: Bool

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

    private var bg: Color {
        backgrounds[safe: settings.backgroundColorIndex] ?? .white
    }

    private var fg: Color {
        textColors[safe: settings.textColorIndex] ?? .black
    }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                BionicTextView(
                    text: $note.content,
                    fontName: settings.fonts[settings.fontIndex],
                    fontSize: CGFloat(settings.fontSize),
                    kerning: CGFloat(settings.wordSpacing),
                    lineSpacing: CGFloat(settings.lineSpacing),
                    textColor: UIColor(fg),
                    backgroundColor: UIColor(bg),
                    isBionic: settings.isBionic
                )
                .onChange(of: note.content) {
                    note.updatedAt = Date()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
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

            Button {
                isSheet = true
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(Color("dblue"))
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    MainSettingsView(isSheet: $isSheet)
                        .environmentObject(settings)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct BionicTextView: UIViewRepresentable {
    @Binding var text: String
    let fontName: String
    let fontSize: CGFloat
    let kerning: CGFloat
    let lineSpacing: CGFloat
    let textColor: UIColor
    let backgroundColor: UIColor
    let isBionic: Bool

    func makeUIView(context: Context) -> UITextView {
        let v = UITextView()
        v.backgroundColor = backgroundColor
        v.isScrollEnabled = true
        v.alwaysBounceVertical = true
        v.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        v.textContainer.lineFragmentPadding = 16
        v.delegate = context.coordinator
        v.keyboardDismissMode = .interactive
        return v
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.backgroundColor = backgroundColor

        if uiView.text != text {
            uiView.text = text
        }

        let baseFont = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let boldFont = UIFont(descriptor: baseFont.fontDescriptor.withSymbolicTraits(.traitBold) ?? baseFont.fontDescriptor,
                              size: baseFont.pointSize)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = lineSpacing

        let baseAttrs: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: textColor,
            .kern: kerning,
            .paragraphStyle: paragraph
        ]

        let typingAttrs: [NSAttributedString.Key: Any] = [
            .font: isBionic ? boldFont : baseFont,
            .foregroundColor: textColor,
            .kern: kerning,
            .paragraphStyle: paragraph
        ]

        uiView.typingAttributes = typingAttrs

        let selected = uiView.selectedRange
        let rendered = makeRenderedAttributedString(
            text: uiView.text ?? "",
            baseAttrs: baseAttrs,
            baseFont: baseFont,
            boldFont: boldFont,
            isBionic: isBionic
        )

        if uiView.attributedText != rendered {
            uiView.attributedText = rendered
            uiView.selectedRange = selected
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    private func makeRenderedAttributedString(
        text: String,
        baseAttrs: [NSAttributedString.Key: Any],
        baseFont: UIFont,
        boldFont: UIFont,
        isBionic: Bool
    ) -> NSAttributedString {
        let result = NSMutableAttributedString(string: text, attributes: baseAttrs)
        guard isBionic, !text.isEmpty else { return result }

        let ns = text as NSString
        let fullRange = NSRange(location: 0, length: ns.length)

        ns.enumerateSubstrings(in: fullRange, options: [.byWords, .substringNotRequired]) { _, range, _, _ in
            guard range.length > 0 else { return }
            let word = ns.substring(with: range)
            guard let firstChar = word.first else { return }
            let firstLen = String(firstChar).utf16.count
            let boldRange = NSRange(location: range.location, length: min(firstLen, range.length))
            result.addAttribute(.font, value: boldFont, range: boldRange)
        
        }

        return result
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            let newText = textView.text ?? ""
            DispatchQueue.main.async {
                self.text = newText
            }
        }

    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

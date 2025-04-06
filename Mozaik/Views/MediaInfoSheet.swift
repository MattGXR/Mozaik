//
//  MediaInfoSheet.swift
//  Mozaik
//
//  Created by Mattia Meligeni on 06/04/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct MediaInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    var jsonOutput: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("MediaInfo Output")
                    .font(.title2)
                    .bold()
                Spacer()
                // Pulsante per salvare il JSON
                Button(action: {
                    saveJson()
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.blue)
                        .padding(4)
                }
                .buttonStyle(.plain)
                // Pulsante per chiudere la finestra
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .padding(4)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 10)

            ScrollView {
                Text(jsonOutput)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .padding()

            Spacer()
        }
        .padding()
        .frame(minWidth: 600, minHeight: 400)
    }
    
    private func saveJson() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.json]
        panel.nameFieldStringValue = "MediaInfoOutput.json"
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    try jsonOutput.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Errore durante il salvataggio: \(error)")
                }
            }
        }
    }
}

struct SectionView: View {
    var title: String
    var track: Track

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ForEach(Mirror(reflecting: track).children.compactMap { $0 }, id: \.label) { child in
                if let label = child.label,
                   let value = child.value as? String, !value.isEmpty {
                    HStack(alignment: .top) {
                        Text(label.replacingOccurrences(of: "_", with: " "))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 150, alignment: .leading)
                        Text(value)
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: NSColor(calibratedWhite: 0.95, alpha: 1.0)))
        .cornerRadius(8)
    }
}

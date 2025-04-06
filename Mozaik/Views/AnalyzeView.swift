//
//  AnalyzeView.swift
//  Mozaik
//
//  Created by Mattia Meligeni on 06/04/25.
//

import SwiftUI

struct AnalyzeView: View {
    @State private var selectedFile: URL?
    @State private var isShowingMediaInfoSheet = false
    @State private var showAllAudioTracks = false
    @State private var showAllSubtitleTracks = false
    @State private var mediaInfo: MediaInfo?
    // Nuova variabile per salvare il JSON originale
    @State private var jsonOutput: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // File selection
            HStack {
                Button {
                    selectFile()
                } label: {
                    Label("Select File", systemImage: "doc")
                }

                if let selectedFile = selectedFile {
                    Text(selectedFile.lastPathComponent)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Divider()

            // Overview section
            VStack(alignment: .leading, spacing: 8) {
                Text("📄 Overview")
                    .font(.title3)
                    .bold()

                if let general = mediaInfo?.media.general {
                    if let format = general.format {
                        Label("Container: \(format)", systemImage: "shippingbox")
                    }
                    if let duration = general.duration {
                        Label("Duration: \(formatDuration(duration))", systemImage: "clock")
                    }
                    if let muxer = general.writingApplication {
                        Label("Muxed with: \(muxer)", systemImage: "hammer")
                    }
                    if let title = general.title ?? general.movie {
                        Label("Title: \(title)", systemImage: "text.book.closed")
                    }
                    if let date = general.encodedDate {
                        Label("Date: \(date)", systemImage: "calendar")
                    }
                    if let fileSize = general.fileSize, let formattedSize = formatFileSize(fileSize) {
                        Label("File size: \(formattedSize)", systemImage: "externaldrive")
                    }
                    if let frameRate = general.frameRate {
                        Label("Frame rate: \(frameRate) fps", systemImage: "speedometer")
                    }
                    if let imdbID = general.resolvedIMDB, !imdbID.isEmpty {
                        Button {
                            if let url = URL(string: "https://www.imdb.com/title/\(imdbID)/") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Label("Open on IMDb", systemImage: "link")
                        }
                    }
                }
            }
            .font(.subheadline)

            Divider()

            // Track table (dynamic)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tracks")
                        .font(.headline)

                    // Video
                    ForEach(Array((mediaInfo?.media.videoTracks ?? []).enumerated()), id: \.offset) { index, track in
                        TrackRow(icon: "film", label: "Video", detail: trackDescription(for: track))
                    }

                    // Audio
                    let audioTracks = mediaInfo?.media.audioTracks ?? []
                    ForEach(Array((showAllAudioTracks ? audioTracks : Array(audioTracks.prefix(2))).enumerated()), id: \.offset) { _, track in
                        TrackRow(icon: "speaker.wave.2", label: "Audio", detail: trackDescription(for: track))
                    }
                    if audioTracks.count > 2 {
                        Button(showAllAudioTracks ? "Hide audio tracks" : "Show \(audioTracks.count - 2) more audio track\(audioTracks.count - 2 > 1 ? "s" : "")") {
                            showAllAudioTracks.toggle()
                        }.buttonStyle(.link)
                    }

                    // Subtitle
                    let subtitleTracks = mediaInfo?.media.subtitleTracks ?? []
                    ForEach(Array((showAllSubtitleTracks ? subtitleTracks : Array(subtitleTracks.prefix(1))).enumerated()), id: \.offset) { _, track in
                        TrackRow(icon: "captions.bubble", label: "Subtitle", detail: trackDescription(for: track))
                    }
                    if subtitleTracks.count > 1 {
                        Button(showAllSubtitleTracks ? "Hide subtitles" : "Show \(subtitleTracks.count - 1) more subtitle track\(subtitleTracks.count - 1 > 1 ? "s" : "")") {
                            showAllSubtitleTracks.toggle()
                        }.buttonStyle(.link)
                    }
                }
            }

            Divider()

            // Show full MediaInfo button
            Button {
                isShowingMediaInfoSheet = true
            } label: {
                Label("Show full MediaInfo", systemImage: "terminal")
            }

            Spacer()
        }
        .padding()
        // Modifica qui per passare jsonOutput invece della descrizione di mediaInfo
        .sheet(isPresented: $isShowingMediaInfoSheet) {
            MediaInfoSheet(jsonOutput: jsonOutput)
        }
    }

    func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK {
            selectedFile = panel.url
            if let file = selectedFile {
                runMediaInfo(for: file)
            }
        }
    }

    func runMediaInfo(for file: URL) {
        guard let executable = Bundle.main.url(forResource: "mediainfo-static", withExtension: nil) else {
            print("mediainfo binary not found")
            return
        }

        let task = Process()
        task.executableURL = executable
        task.arguments = ["--Output=JSON", file.path]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard !data.isEmpty else {
                print("No output from mediainfo")
                return
            }
            // Converti i dati in una stringa JSON originale
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("Failed to convert data to string")
                return
            }
            DispatchQueue.main.async {
                self.jsonOutput = jsonString
                // Decodifica come prima
                do {
                    let decoded = try JSONDecoder().decode(MediaInfo.self, from: data)
                    self.mediaInfo = decoded
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        } catch {
            print("Failed to run mediainfo: \(error)")
        }
    }

    func formatDuration(_ raw: String) -> String {
        if let seconds = Double(raw) {
            let hours = Int(seconds) / 3600
            let minutes = (Int(seconds) % 3600) / 60
            return "\(hours)h \(minutes)m"
        }
        return raw
    }
    
    func formatFileSize(_ raw: String) -> String? {
        if let bytes = Double(raw) {
            let gib = bytes / 1073741824.0
            return String(format: "%.1f GiB", gib)
        }
        return nil
    }

    func trackDescription(for track: Track) -> String {
        var parts: [String] = []
        if track.type == "Video" {
            if let format = track.format {
                parts.append(format)
            }
            if let bitRate = track.bitRate ?? mediaInfo?.media.general?.overallBitRate {
                if let mbps = Double(bitRate.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "bps", with: "")) {
                    parts.append(String(format: "%.1f Mbps", mbps / 1_000_000))
                } else {
                    parts.append("\(bitRate)bps")
                }
            }
            if let width = track.width, let height = track.height {
                parts.append("\(width)x\(height)")
            }
            var hdrTags: [String] = []
            if let hdrCompat = track.hdrCompatibility {
                let hdr10 = hdrCompat.components(separatedBy: "/").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !hdr10.isEmpty {
                    hdrTags.append(hdr10)
                }
            }
            if let hdrFormat = track.hdrFormat {
                let dolby = hdrFormat.components(separatedBy: "/").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !dolby.isEmpty {
                    hdrTags.append(dolby)
                }
            }
            if !hdrTags.isEmpty {
                parts.append(hdrTags.joined(separator: ", "))
            }
        }
        if track.type == "Audio" {
            var audioInfo = ""
            if let format = track.format {
                audioInfo = format
            }
            if let commercialName = track.commercialName, !commercialName.isEmpty {
                if !audioInfo.isEmpty {
                    audioInfo += " (\(commercialName))"
                } else {
                    audioInfo = commercialName
                }
            }
            if !audioInfo.isEmpty {
                parts.append(audioInfo)
            }
            if let audioTitle = track.title, !audioTitle.isEmpty {
                parts.append(audioTitle)
            }
            if let bitRate = track.bitRate {
                if let kbps = Double(bitRate.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "bps", with: "")) {
                    parts.append(String(format: "%.0f kbps", kbps / 1000))
                } else {
                    parts.append("\(bitRate)bps")
                }
            }
            if let compression = track.compressionMode ?? track.bitRateMode {
                parts.append(compression)
            }
            if let defaultFlag = track.defaultFlag?.lowercased(), defaultFlag == "yes" {
                parts.append("✅ Default")
            }
            if let lang = track.language {
                let fullLang = Locale.current.localizedString(forLanguageCode: lang) ?? lang.capitalized
                parts.append(fullLang)
            }
        }
        if track.type == "Text" {
            if let format = track.format {
                parts.append(format)
            }
            if let title = track.title {
                parts.append(title)
            } else if let language = track.language {
                let fullLang = Locale.current.localizedString(forLanguageCode: language) ?? language.capitalized
                parts.append(fullLang)
            }
            if let forced = track.forcedFlag?.lowercased(), forced == "yes" {
                parts.append("⚠️ Forced")
            }
        }
        return parts.joined(separator: " • ")
    }
}

struct TrackRow: View {
    let icon: String
    let label: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .bold()
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .alignmentGuide(.leading) { d in d[.leading] }
    }
}

#Preview {
    AnalyzeView()
}

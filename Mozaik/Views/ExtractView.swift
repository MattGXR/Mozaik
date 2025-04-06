//
//  ExtractView.swift
//  Mozaik
//
//  Created by Mattia Meligeni on 06/04/25.
//

import SwiftUI

struct ExtractView: View {
    @State private var selectedFile: URL?
    @State private var mkvInfo: MKVMergeInfo?
    @State private var selectedTracks: Set<Int> = []
    @State private var isExtracting = false
    @State private var showCompletionAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // File selection
            HStack {
                Button {
                    selectFile()
                } label: {
                    Label("Select MKV File", systemImage: "doc")
                }

                if let file = selectedFile {
                    Text(file.lastPathComponent)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Divider()

            if let tracks = mkvInfo?.tracks {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tracks").font(.title3).bold()

                        // Video Tracks
                        ForEach(tracks.filter { $0.type == "video" }, id: \.id) { track in
                            TrackSelectionRow(track: track, isSelected: selectedTracks.contains(track.id)) {
                                toggleTrackSelection(id: track.id)
                            }
                        }

                        // Audio Tracks
                        ForEach(tracks.filter { $0.type == "audio" }, id: \.id) { track in
                            TrackSelectionRow(track: track, isSelected: selectedTracks.contains(track.id)) {
                                toggleTrackSelection(id: track.id)
                            }
                        }

                        // Subtitle Tracks
                        ForEach(tracks.filter { $0.type == "subtitles" }, id: \.id) { track in
                            TrackSelectionRow(track: track, isSelected: selectedTracks.contains(track.id)) {
                                toggleTrackSelection(id: track.id)
                            }
                        }
                    }
                }
            }

            if !selectedTracks.isEmpty {
                Button {
                    extractSelectedTracks()
                } label: {
                    Label("Extract Selected Tracks", systemImage: "arrow.down.to.line")
                }

                if isExtracting {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                        .padding(.vertical)
                }
            }

            Spacer()
        }
        .padding()
        .alert("Extraction Completed", isPresented: $showCompletionAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    func toggleTrackSelection(id: Int) {
        if selectedTracks.contains(id) {
            selectedTracks.remove(id)
        } else {
            selectedTracks.insert(id)
        }
    }

    func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            selectedFile = url
            runMKVMerge(file: url)
        }
    }

    func runMKVMerge(file: URL) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/mkvmerge")
        task.arguments = ["-J", file.path]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let decoded = try JSONDecoder().decode(MKVMergeInfo.self, from: data)
            DispatchQueue.main.async {
                self.mkvInfo = decoded
            }
        } catch {
            print("❌ Failed to run mkvmerge -J: \(error)")
        }
    }

    func extractSelectedTracks() {
        guard let inputFile = selectedFile else { return }

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"

        if panel.runModal() == .OK, let outputDirectory = panel.url {
            isExtracting = true

            // Build arguments: mkvextract input.mkv tracks 0:out1 1:out2 ...
            var arguments: [String] = ["tracks", inputFile.path]

            for trackID in selectedTracks {
                guard let track = mkvInfo?.tracks.first(where: { $0.id == trackID }) else { continue }

                let filename: String
                let lang = track.properties?.language ?? "und"

                switch track.type {
                case "video":
                    if let codec = track.codec?.lowercased() {
                        if codec.contains("h.264") || codec.contains("avc") {
                            filename = "track_\(trackID).\(lang).mp4"
                        } else if codec.contains("h.265") || codec.contains("hevc") {
                            filename = "track_\(trackID).\(lang).mkv"
                        } else {
                            filename = "track_\(trackID).\(lang).video.mkv"
                        }
                    } else {
                        filename = "track_\(trackID).\(lang).video"
                    }
                case "audio":
                    if let codec = track.codec?.lowercased() {
                        if codec.contains("aac") {
                            filename = "track_\(trackID).\(lang).m4a"
                        } else if codec.contains("ac-3") {
                            filename = "track_\(trackID).\(lang).ac3"
                        } else if codec.contains("truehd") {
                            filename = "track_\(trackID).\(lang).thd"
                        } else {
                            filename = "track_\(trackID).\(lang).audio"
                        }
                    } else {
                        filename = "track_\(trackID).\(lang).audio"
                    }
                case "subtitles":
                    filename = "track_\(trackID).\(lang).srt"
                default:
                    filename = "track_\(trackID).\(lang).bin"
                }

                let outputPath = outputDirectory.appendingPathComponent(filename).path
                arguments.append("\(trackID):\(outputPath)")
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/mkvextract")
                task.arguments = arguments

                let pipe = Pipe()
                task.standardOutput = pipe
                task.standardError = pipe

                let outputHandle = pipe.fileHandleForReading

                outputHandle.readabilityHandler = { handle in
                    if let line = String(data: handle.availableData, encoding: .utf8), !line.isEmpty {
                        print("📤 \(line.trimmingCharacters(in: .whitespacesAndNewlines))")
                    }
                }

                do {
                    try task.run()
                    task.waitUntilExit()
                } catch {
                    print("❌ Failed to run mkvextract: \(error)")
                }

                outputHandle.readabilityHandler = nil

                DispatchQueue.main.async {
                    isExtracting = false
                    showCompletionAlert = true
                }
            }
        }
    }
}

struct TrackSelectionRow: View {
    let track: MKVTrack
    let isSelected: Bool
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square" : "square")
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(track.type.capitalized) Track #\(track.id)").bold()

                    Text(description(for: track))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }.buttonStyle(.plain)
    }

    func description(for track: MKVTrack) -> String {
        var components: [String] = []
        switch track.type {
        case "video":
            if let codec = track.codec {
                components.append(codec)
            }
            if let px = track.properties?.pixel_dimensions {
                components.append(px)
            }
            if let bps = track.properties?.tag_bps,
               let bpsValue = Double(bps) {
                components.append(String(format: "%.1f Mbps", bpsValue / 1_000_000))
            }
        case "audio":
            if let name = track.properties?.track_name {
                components.append(name)
            }
            if let lang = track.properties?.language {
                components.append(lang.uppercased())
            }
            if track.properties?.default_track == true {
                components.append("✅ Default")
            }
        case "subtitles":
            if let name = track.properties?.track_name {
                components.append(name)
            }
            if let lang = track.properties?.language {
                components.append(lang.uppercased())
            }
            if track.properties?.default_track == true {
                components.append("✅ Default")
            }
            if track.properties?.forced_track == true {
                components.append("⚠️ Forced")
            }
        default:
            break
        }
        return components.joined(separator: " • ")
    }
}

// MARK: - Model

struct MKVMergeInfo: Codable {
    let tracks: [MKVTrack]
}

struct MKVTrack: Codable {
    let id: Int
    let type: String
    let codec: String?
    let properties: MKVTrackProperties?
}

struct MKVTrackProperties: Codable {
    let pixel_dimensions: String?
    let tag_bps: String?
    let track_name: String?
    let language: String?
    let default_track: Bool?
    let forced_track: Bool?
}

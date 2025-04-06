# 🎬 Mozaik — Native MKV & MP4 Toolkit for macOS

![Platform](https://img.shields.io/badge/platform-macOS%20Apple%20Silicon-lightgrey?logo=apple)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-orange?logo=swift)
![License](https://img.shields.io/github/license/tuo-username/mozaik)

**Mozaik** is a modern, native macOS application (optimized for Apple Silicon) that allows you to **analyze**, **extract**, **compress**, and **merge** video files like `.mkv` and `.mp4` with a clean SwiftUI interface and high-performance engine.

> Think MKVToolNix and HandBrake, reimagined for the macOS ecosystem.

---

## ✨ Features

- **Track Analysis (MKV & MP4)**
  - Parses media info, codecs, flags (default/forced), languages
  - Advanced technical breakdown via `MediaInfo` and `mkvinfo`

- **Track Extraction from MKV**
  - Extract video, audio, and subtitle tracks with `mkvextract`

- **Hardware-accelerated Compression**
  - Re-encode `.mkv` or `.mp4` to H.264 or H.265 via AVFoundation / VideoToolbox
  - Presets: "Compatible", "High Quality", "Target Size", etc.

- **Smart Muxing (Track Merging)**
  - Combine separate tracks into a single `.mkv` using `mkvmerge`
  - Customize track order, language, flags

- **Native macOS Experience**
  - Built with SwiftUI
  - Universal binary for Apple Silicon
  - Drag & drop, system notifications, and Dark Mode support

---

## 🛠 Requirements

- macOS 13.0 or newer
- Apple Silicon (M1/M2/M3)

No external installation is required — all CLI tools are bundled within the app.

---

## 🧪 Developer Setup (Optional)

All required command-line tools (`mkvmerge`, `mkvextract`, `mkvinfo`, `mp4box`, `mediainfo`) are already bundled inside the app for distribution.

If you want to update these tools or contribute to development, install them locally via [Homebrew](https://brew.sh):

```bash
brew install mkvtoolnix gpac media-info
```

Then copy the actual binaries (not symlinks) to:
_Mozaik/Resources/Binaries/_

Make them executable:
```bash
chmod +x Mozaik/Resources/Binaries/*
```

## 📁 Project Structure

```plaintext
Mozaik/
├── App/                   # App entry point (SwiftUI lifecycle)
├── Views/                 # SwiftUI screens and navigation
├── Models/                # Data models (e.g., MuxTrack, MediaFileInfo)
├── Controllers/           # Logic to run CLI tools (mkvmerge, mp4box, AVFoundation, etc.)
├── Helpers/               # Utilities for file handling, process execution
└── Resources/
    └── Binaries/          # Embedded command-line tools used by the app
```


## 🧠 Architecture Overview

| Module         | CLI Tool(s) Used                     | Purpose                                      |
|----------------|--------------------------------------|----------------------------------------------|
| Analyze        | `mkvmerge -J`, `AVFoundation`, `mediainfo` | Read metadata, languages, codecs, flags     |
| Extract        | `mkvextract`                         | Extract individual tracks from `.mkv`        |
| Compress       | `AVFoundation`, `MP4Box`             | Re-encode video via VideoToolbox             |
| Merge (Mux)    | `mkvmerge`                           | Combine video/audio/subtitle tracks into `.mkv` |
| Technical Info | `mkvinfo`, `mediainfo`               | Show advanced container and codec structure  |

---

## 🛣️ Roadmap

### 🔹 Phase 1 – Core architecture & foundation
- [x] Create SwiftUI app structure with `NavigationSplitView`
- [x] Add support for local embedded CLI binaries (mkvmerge, mp4box, etc.)
- [ ] Implement file drag & drop and import system
- [ ] Create `TempJobManager` for temporary file handling

### 🔹 Phase 2 – Track analysis & metadata parsing
- [ ] Basic MKV track parser using `mkvmerge -J`
- [ ] Basic MP4 info extraction via `AVAsset`
- [ ] Implement `MediaInfo (Standard)` view (friendly, simplified info)
- [ ] Implement `MediaInfo (Advanced)` view (full raw output / expert mode)

### 🔹 Phase 3 – Extraction & muxing
- [ ] `Extract` section (audio, video, subtitle) using `mkvextract`
- [ ] `Mux` section (merge multiple tracks into `.mkv`) using `mkvmerge`
- [ ] Add ability to reorder, relabel, and flag tracks (default/forced)

### 🔹 Phase 4 – Compression & re-encoding
- [ ] Direct MP4 compression using AVFoundation + VideoToolbox
- [ ] MKV compression pipeline:
  - [ ] Extract video
  - [ ] Remux to MP4 (`MP4Box`)
  - [ ] Compress with AVFoundation
  - [ ] Optional re-mux to MKV with original tracks
- [ ] Add compression presets: Compatible, High Quality, Target Size
- [ ] Add bitrate calculator (estimate size from duration and bitrate)

### 🔹 Phase 5 – UX improvements
- [ ] Allow saving/loading of custom compression presets
- [ ] Add progress bars and estimated time for each operation
- [ ] Implement notifications (e.g., file ready / job done)
- [ ] Ask user whether to keep/exclude extra audio/subtitle tracks before muxing

### 🔹 Phase 6 – Extra features & polish
- [ ] Batch jobs (multiple files queued)
- [ ] In-app video preview (optional)
- [ ] Add settings view (e.g. default output format, preferred languages)
- [ ] Localize UI (English / Italian)
- [ ] Export job logs / metadata to `.json`

---

✅ This roadmap will be updated continuously as the project evolves.  
Feel free to suggest or vote on features by opening an issue!


## 📖 License

This project is released under the [MIT License](LICENSE).  
All embedded tools (`mkvtoolnix`, `gpac`, `MediaInfo`) retain their respective open-source licenses.

> Mozaik includes no GPL code.

---

## 🤝 Contributing

Pull requests are welcome!  
If you’d like to help with development, design, presets, testing or documentation:

- Fork the repository
- Create a branch
- Submit your PR or open an issue

---

## © Mozaik — Created with care for creators, archivists, and film nerds.
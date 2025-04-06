//
//  MediaInfo.swift
//  Mozaik
//
//  Created by Mattia Meligeni on 06/04/25.
//

import Foundation

struct MediaInfoResponse: Decodable {
    let media: Media
}

struct Media: Decodable {
    let ref: String?
    let tracks: [Track]

    enum CodingKeys: String, CodingKey {
        case ref = "@ref"
        case tracks = "track"
    }

    // Helpers per filtrare i track per tipo
    var general: Track? {
        tracks.first(where: { $0.type == "General" })
    }

    var videoTracks: [Track] {
        tracks.filter { $0.type == "Video" }
    }

    var audioTracks: [Track] {
        tracks.filter { $0.type == "Audio" }
    }

    var subtitleTracks: [Track] {
        tracks.filter { $0.type == "Text" }
    }

    var menu: Track? {
        tracks.first(where: { $0.type == "Menu" })
    }
}

struct Track: Decodable {
    let type: String

    let title: String?
    let duration: String?
    let format: String?
    let formatVersion: String?
    let formatProfile: String?
    let codecID: String?
    let bitRate: String?
    let bitRateMode: String?
    let width: String?
    let height: String?
    let displayAspectRatio: String?
    let frameRate: String?
    let frameRateMode: String?
    let colorSpace: String?
    let chromaSubsampling: String?
    let bitDepth: String?
    let channelLayout: String?
    let channels: String?
    let samplingRate: String?
    let language: String?
    let serviceKind: String?
    let defaultFlag: String?
    let forcedFlag: String?
    let encodedDate: String?
    let writingApplication: String?
    let writingLibrary: String?
    let fileSize: String?
    let overallBitRate: String?
    let movie: String?
    let streamSize: String?
    let fileExtension: String?
    let IMDB: String?
    let TMDB: String?
    let commercialName: String?
    let hdrFormat: String?
    let hdrCompatibility: String?
    let languageMore: String?
    let compressionMode: String?
    
    // Nuova proprietà per estrarre i dati extra
    let extra: [String: String]?

    enum CodingKeys: String, CodingKey {
        case type = "@type"
        case title = "Title"
        case duration = "Duration"
        case format = "Format"
        case formatVersion = "Format_Version"
        case formatProfile = "Format_Profile"
        case codecID = "CodecID"
        case bitRate = "BitRate"
        case bitRateMode = "BitRate_Mode"
        case width = "Width"
        case height = "Height"
        case displayAspectRatio = "DisplayAspectRatio"
        case frameRate = "FrameRate"
        case frameRateMode = "FrameRate_Mode"
        case colorSpace = "ColorSpace"
        case chromaSubsampling = "ChromaSubsampling"
        case bitDepth = "BitDepth"
        case channelLayout = "ChannelLayout"
        case channels = "Channel(s)"
        case samplingRate = "SamplingRate"
        case language = "Language"
        case serviceKind = "ServiceKind"
        case defaultFlag = "Default"
        case forcedFlag = "Forced"
        case encodedDate = "Encoded_Date"
        case writingApplication = "Encoded_Application"
        case writingLibrary = "Encoded_Library"
        case fileSize = "FileSize"
        case overallBitRate = "OverallBitRate"
        case movie = "Movie"
        case streamSize = "StreamSize"
        case fileExtension = "FileExtension"
        case IMDB = "IMDB"
        case TMDB = "TMDB"
        case commercialName = "Format_Commercial_IfAny"
        case hdrFormat = "HDR_Format"
        case hdrCompatibility = "HDR_Format_Compatibility"
        case languageMore = "Language_More"
        case compressionMode = "Compression_Mode"
        case extra = "extra"
    }
    
    // Computed property per ottenere l'ID IMDb da IMDB o da extra["IMDB"]
    var resolvedIMDB: String? {
        if let imdb = IMDB, !imdb.isEmpty {
            return imdb
        }
        if let extra = extra, let imdbExtra = extra["IMDB"], !imdbExtra.isEmpty {
            return imdbExtra
        }
        return nil
    }
}

typealias MediaInfo = MediaInfoResponse

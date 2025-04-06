//
//  ContentView.swift
//  Mozaik
//
//  Created by Mattia Meligeni on 06/04/25.
//

import SwiftUI

enum Section: String, CaseIterable, Identifiable {
    case analyze = "Analyze"
    case extract = "Extract"
    case compress = "Compress"
    case merge = "Merge"

    var id: Self { self }

    var iconName: String {
        switch self {
        case .analyze: return "doc.text.magnifyingglass"
        case .extract: return "square.and.arrow.up"
        case .compress: return "books.vertical"
        case .merge: return "rectangle.3.offgrid"
        }
    }
}

import SwiftUI

struct ContentView: View {
    @State private var selectedSection: Section? = .extract

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                ForEach(Section.allCases) { section in
                    NavigationLink(value: section) {
                        Label(section.rawValue, systemImage: section.iconName)
                    }
                }
            }
            .navigationTitle("Mozaik")
        } detail: {
            Group {
                switch selectedSection {
                case .analyze:
                    AnalyzeView()
                case .extract:
                    ExtractView()
                case .compress:
                    Text("Compress View")
                case .merge:
                    Text("Merge View")
                case .none:
                    Text("Select a section")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}

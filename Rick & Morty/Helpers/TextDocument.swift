//
//  TextDocument.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 20/06/2025.
//
/// Used to create and edit document to be saved as files
/// using the SwiftUI Document document based app functionality.

import SwiftUI
import UniformTypeIdentifiers

struct TextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var text: String
    
    init(text: String = "") {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.text = String(decoding: data, as: UTF8.self)
        } else {
            self.text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}


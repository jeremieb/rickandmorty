//
//  CharacterDetailRow.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 20/06/2025.
//

import SwiftUI

struct CharacterDetailRow: View {
    
    var label: String
    var value: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .fontWidth(.condensed)
            Spacer()
            Text(value)
                .fontWidth(.expanded)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
    }
}

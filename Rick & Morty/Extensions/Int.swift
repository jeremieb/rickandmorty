//
//  Int.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 20/06/2025.
//

import Foundation

extension Int: @retroactive Identifiable {
    public var id: Int { return self }
}

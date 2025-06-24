//
//  Int.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 20/06/2025.
//

/// To be able to pass an Episode ID in the navigation view,
/// we need to make it compatible to Identifiable protocol.
/// We use @retroactive:
/// Extension declares a conformance of imported type 'Int' to imported protocol 'Identifiable';
/// this will not behave correctly if the owners of 'Swift' introduce this conformance in the future.
/// Looking forward for the future...

import Foundation

extension Int: @retroactive Identifiable {
    public var id: Int { return self }
}

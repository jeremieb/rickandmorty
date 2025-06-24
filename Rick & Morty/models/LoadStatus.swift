//
//  LoadStatus.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

/// Used to know where we're at with the viewmodels
/// Used to give feedback to the user like a progress view when loading

import Foundation

enum LoadingState<T>: Equatable {
    
    case idle
    case loading
    case loaded(T)
    case failed(Error?)
    
    static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        return true
    }
}


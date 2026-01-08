//
//  CoEquipNavigationRouter.swift
//  iKisanApp
//
//  Centralized Navigation Manager for Co-Equip Flow
//

import SwiftUI

/// Navigation Router for Co-Equip flow using NavigationPath
@MainActor
class CoEquipNavigationRouter: ObservableObject {
    /// Navigation path for the stack
    @Published var path = NavigationPath()
    
    /// Navigate to a specific destination
    func navigate<T: Hashable>(to destination: T) {
        path.append(destination)
    }
    
    /// Pop back one level
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Pop back to root (clear entire stack)
    func popToRoot() {
        print("🔙 CoEquipNavigationRouter: Popping to root")
        path.removeLast(path.count)
    }
    
    /// Reset navigation (alternative to popToRoot)
    func reset() {
        print("🔄 CoEquipNavigationRouter: Resetting navigation stack")
        path = NavigationPath()
    }
}

/// Navigation destinations for Co-Equip flow
enum CoEquipDestination: Hashable {
    case selectEquipment
    case equipmentDetail(Equipment)
    case createGroup(Equipment)
}

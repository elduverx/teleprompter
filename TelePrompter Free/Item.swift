//
//  Item.swift
//  TelePrompter Free
//
//  Created by duverney muriel on 3/3/26.
//

import Foundation

// Este archivo ya no usa SwiftData para mantener la compatibilidad con iOS 14.
final class Item: Identifiable {
    var id = UUID()
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

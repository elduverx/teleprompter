//
//  Item.swift
//  TelePrompter Free
//
//  Created by duverney muriel on 3/3/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

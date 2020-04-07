//
//  Card.swift
//  FlashZila
//
//  Created by dominator on 07/04/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import Foundation

struct Card: Codable {
    let prompt: String
    let answer: String
    
    static var example: Card {
        Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
    }
}

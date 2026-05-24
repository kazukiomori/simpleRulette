//
//  RuletteModel.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/17.
//

import Foundation

struct Rulette: Codable, Equatable {
    var id: String = UUID().uuidString
    var title: String = ""
    var ruletteItems: [RuletteItem] = []
}

struct RuletteItem: Codable, Equatable {
    var item: String = ""
}

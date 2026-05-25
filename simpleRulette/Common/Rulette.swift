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
    var weight: Int = 0

    init(item: String = "", weight: Int = 0) {
        self.item = item
        self.weight = weight
    }

    private enum CodingKeys: String, CodingKey {
        case item
        case weight
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        item = try container.decodeIfPresent(String.self, forKey: .item) ?? ""
        weight = try container.decodeIfPresent(Int.self, forKey: .weight) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(item, forKey: .item)
        try container.encode(weight, forKey: .weight)
    }
}

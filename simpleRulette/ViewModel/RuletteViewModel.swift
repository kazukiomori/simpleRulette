//
//  RuletteViewModel.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/20.
//

import Foundation

class RuletteViewModel {
    
    let model = RuletteModel()
    
    // viewで入力した値をRulette型にまとめて保存する
    func addData(title: String, items: [String], weights: [Int]? = nil){
        let rulette = Rulette()
        var savedRulette = rulette
        savedRulette.title = title
        for (index, item) in items.enumerated() {
            let weight = weights?[safe: index] ?? 0
            savedRulette.ruletteItems.append(RuletteItem(item: item, weight: weight))
        }
        model.addData(rulette: savedRulette)
    }

    func saveCurrentData(title: String, items: [String], weights: [Int]) {
        let rulette = buildRulette(id: UUID().uuidString, title: title, items: items, weights: weights)
        model.saveCurrentData(rulette: rulette)
    }

    // 保存済みデータをviewに渡す
    func fetchAllData() -> [Rulette] {
        model.getAllRuletteData()
    }

    func fetchCurrentData() -> Rulette? {
        model.getCurrentRuletteData()
    }

    func updateRuletteData(rulette: Rulette, title: String, items: [String], weights: [Int]) {
        let updatedRulette = buildRulette(id: rulette.id, title: title, items: items, weights: weights)
        model.updateData(rulette: updatedRulette)
    }
    
    func deleteRuletteData(rulette: Rulette) {
        model.deleteData(rulette: rulette)
    }

    private func buildRulette(id: String, title: String, items: [String], weights: [Int]) -> Rulette {
        Rulette(
            id: id,
            title: title,
            ruletteItems: items.enumerated().map { index, item in
                RuletteItem(item: item, weight: weights[safe: index] ?? 0)
            }
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

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
        let rulette = Rulette(
            title: title,
            ruletteItems: items.enumerated().map { index, item in
                RuletteItem(item: item, weight: weights[safe: index] ?? 0)
            }
        )
        model.saveCurrentData(rulette: rulette)
    }

    // 保存済みデータをviewに渡す
    func fetchAllData() -> [Rulette] {
        model.getAllRuletteData()
    }

    func fetchCurrentData() -> Rulette? {
        model.getCurrentRuletteData()
    }
    
    func deleteRuletteData(rulette: Rulette) {
        model.deleteData(rulette: rulette)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

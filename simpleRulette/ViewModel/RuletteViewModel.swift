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
    func addData(title: String, items: [String]){
        let rulette = Rulette()
        var savedRulette = rulette
        savedRulette.title = title
        for item in items {
            savedRulette.ruletteItems.append(RuletteItem(item: item))
        }
        model.addData(rulette: savedRulette)
    }

    // 保存済みデータをviewに渡す
    func fetchAllData() -> [Rulette] {
        model.getAllRuletteData()
    }
    
    func deleteRuletteData(rulette: Rulette) {
        model.deleteData(rulette: rulette)
    }
}

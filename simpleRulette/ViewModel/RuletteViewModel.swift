//
//  RuletteViewModel.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/20.
//

import Foundation
import RealmSwift

class RuletteViewModel {
    
    let model = RuletteModel()
    
    // viewで入力した値をWeight型の変数にまとめて、RuletteModelでrealmに保存する
    func addData(title: String, items: [String]){
        let rulette = Rulette()
        let ruletteItem = ruletteItem()
        rulette.title = title
        for item in items {
            ruletteItem.item = item
            rulette.ruletteItems.append(ruletteItem)
        }
        model.addData(rulette: rulette)
    }
    
    // RuletteModelでrealmから取り出したデータをRulette型の配列にしてviewに渡す
    func fetchAllData() -> [Rulette] {
        var ruletteList: [Rulette] = []
        let results = model.getAllRuletteData()
        for result in results {
            let rulette = Rulette()
            rulette.title = result.title
            rulette.ruletteItems = result.ruletteItems
            ruletteList.append(rulette)
        }
        return ruletteList
    }
    
    func deleteRuletteData(rulette: Rulette) {
        model.deleteData(rulette: rulette)
    }
}

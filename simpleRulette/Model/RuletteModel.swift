//
//  RuletteModel.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/20.
//

import Foundation
import RealmSwift

class RuletteModel {
    
    // realmにデータを保存
    func addData(rulette: Rulette) {
        let realm = try! Realm()
        try! realm.write{
            realm.add(rulette)
        }
    }
    
    // realmからデータを取得
    func getAllRuletteData() -> Results<Rulette> {
        let realm = try! Realm()
        var results: Results<Rulette>
        results = realm.objects(Rulette.self)
        return results
    }
}

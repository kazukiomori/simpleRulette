//
//  RuletteModel.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/20.
//

import Foundation

class RuletteModel {
  private let storageKey = "savedRulettes"
  private let currentStorageKey = "currentRoulette"
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let userDefaults = UserDefaults.standard
    
  // UserDefaultsにデータを保存
    func addData(rulette: Rulette) {
    var rulettes = getAllRuletteData()
    rulettes.append(rulette)
    save(rulettes)
  }

  // UserDefaultsからデータを取得
  func getAllRuletteData() -> [Rulette] {
    guard let data = userDefaults.data(forKey: storageKey) else {
      return []
        }

    do {
      return try decoder.decode([Rulette].self, from: data)
    } catch {
      print("Error \(error)")
      return []
    }
    }

  func saveCurrentData(rulette: Rulette) {
    do {
      let data = try encoder.encode(rulette)
      userDefaults.set(data, forKey: currentStorageKey)
    } catch {
      print("Error \(error)")
    }
  }

  func getCurrentRuletteData() -> Rulette? {
    guard let data = userDefaults.data(forKey: currentStorageKey) else {
      return nil
    }

    do {
      return try decoder.decode(Rulette.self, from: data)
    } catch {
      print("Error \(error)")
      return nil
    }
  }

    func deleteData(rulette: Rulette) {
    let filteredRulettes = getAllRuletteData().filter { $0.id != rulette.id }
    save(filteredRulettes)
  }

  private func save(_ rulettes: [Rulette]) {
    do {
      let data = try encoder.encode(rulettes)
      userDefaults.set(data, forKey: storageKey)
    } catch {
      print("Error \(error)")
        }
    }
}

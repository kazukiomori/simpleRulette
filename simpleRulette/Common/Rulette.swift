//
//  RuletteModel.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/17.
//

import Foundation
import UIKit
import RealmSwift

@objcMembers

class Rulette: Object {
    @objc dynamic var title: String = ""
    var ruletteItems = List<ruletteItem>()
}

class ruletteItem: Object {
    @objc dynamic var item: String = ""
}

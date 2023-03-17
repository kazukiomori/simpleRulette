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
    @objc dynamic var date: String = ""
    @objc dynamic var time: String = ""
    @objc dynamic var menu: String = ""
    @objc dynamic var calorie: Int = 0
    @objc dynamic var memo: String = ""
    
}


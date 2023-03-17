//
//  RuletteTableViewCell.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/17.
//

import UIKit

class RuletteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

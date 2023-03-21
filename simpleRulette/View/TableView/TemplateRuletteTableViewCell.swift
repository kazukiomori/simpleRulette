//
//  TemplateRuletteTableViewCell.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/21.
//

import UIKit

class TemplateRuletteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
    }
    
}

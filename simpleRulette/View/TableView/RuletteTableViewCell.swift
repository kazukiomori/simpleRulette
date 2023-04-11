//
//  RuletteTableViewCell.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/17.
//

import UIKit

protocol RuletteTableViewCellDelegate: AnyObject {
    func textViewDidEndEditing(text: String, forCell cell: RuletteTableViewCell)
}

class RuletteTableViewCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate {
    
    weak var delegate: RuletteTableViewCellDelegate?
    
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        textView.placeholder = NSLocalizedString("placeholder", comment: "")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        textView.delegate = self
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            // デリゲートメソッドを呼び出す
            delegate?.textViewDidEndEditing(text: text, forCell: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textView.text {
            // デリゲートメソッドを呼び出す
            delegate?.textViewDidEndEditing(text: text, forCell: self)
        }
      return true
    }
}

//
//  NewRuletteViewController.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/17.
//

import Foundation
import UIKit
import GoogleMobileAds

class NewRuletteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, RuletteTableViewCellDelegate {
    
    // MARK: プロパティ
    @IBOutlet weak var tableView: UITableView!
    var dataItems: [String] = []
    var dataColors: [UIColor] = []
    var isSaved = false
    var titleString = ""
    @IBOutlet weak var templateSwitch: UISwitch!
    let titleTextField = UITextField(frame: CGRect(x: 30, y: 0, width: 300, height: 30))
    
    @IBOutlet weak var bannerView: GADBannerView!
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        titleTextField.delegate = self
        navigationItemSet()
        templateSwitch.isOn = false
        bannerView.adUnitID = "ca-app-pub-3293568654583905/5620314493"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    // MARK: 関数
    @IBAction func tapAddData(_ sender: Any) {
        dataItems.append("")
        dataColors.append(UIColor.rand)
        self.tableView.reloadData()
    }
    
    func navigationItemSet() {
        var addBarButtonItem = UIBarButtonItem(title: NSLocalizedString("save", comment: ""), style: .done, target: self, action: #selector(addButtonTapped))
        addBarButtonItem.tintColor = .black
        self.navigationItem.rightBarButtonItems = [addBarButtonItem]
        
        titleTextField.placeholder = NSLocalizedString("titlePlaceholder", comment: "")
        titleString = titleTextField.text!
        self.navigationItem.titleView = titleTextField
    }
    
    @objc func addButtonTapped() {
        if titleTextField.text == "" {
            messageAlert.shared.showErrorMessage(title: NSLocalizedString("error", comment: ""), body: NSLocalizedString("rouletteTitleNotEntered", comment: ""))
            return
        }
        
        if dataItems.count == 0 {
            messageAlert.shared.showErrorMessage(title: NSLocalizedString("error", comment: ""), body: NSLocalizedString("pleaseAddARouletteItem", comment: ""))
            return
        }
        
        if dataItems.count == 1 {
            messageAlert.shared.showErrorMessage(title: NSLocalizedString("error", comment: ""), body: NSLocalizedString("thereIsOnlyOneRouletteItem", comment: ""))
            return
        }
        
        if dataItems.contains("") {
            messageAlert.shared.showErrorMessage(title: NSLocalizedString("error", comment: ""), body: NSLocalizedString("pleaseEnterTheRouletteItemsCorrectly", comment: ""))
            return
        }
        
        if isSaved {
            //テンプレートに保存する場合
            //realmに保存
            let ruletteViewModel = RuletteViewModel()
            ruletteViewModel.addData(title: titleTextField.text!, items: dataItems)
        } else {
            //テンプレートに保存しない場合
            //こっちのルートはおそらくいらない
        }
        //前の画面にルーレットの値の入ったモデルを渡す
        if let previousViewController = navigationController?.viewControllers[0] as? RuletteViewController {
            previousViewController.titleString = self.titleString
            previousViewController.items = self.dataItems
        }
        //前の画面に戻る
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func pushSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.isSaved = true
        } else {
            self.isSaved = false
        }
    }
    // MARK: tableView関連
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ruletteTableViewCell", for: indexPath) as? RuletteTableViewCell else {return UITableViewCell()}
        cell.colorView.layer.cornerRadius = cell.colorView.frame.height / 2
        cell.colorView.backgroundColor = dataColors[indexPath.row]
        cell.delegate = self
        cell.textView.text = dataItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("delete", comment: "")) { (action, view, completionHandler) in
            self.dataItems.remove(at: indexPath.row)
            self.dataColors.remove(at: indexPath.row)
            tableView.reloadData()
              // 実行結果に関わらず記述
              completionHandler(true)
            }
            // 定義したアクションをセット
            return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleTextField {
            titleString = titleTextField.text!
            return
        }
        if let text = textField.text {
            dataItems.append(text)
        }
    }
    
    // MARK: RuletteTableViewCellデリゲート
    func textViewDidEndEditing(text: String, forCell cell: RuletteTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            dataItems[indexPath.row] = text
        }
    }
    
    // MARK: textFieldデリゲート
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

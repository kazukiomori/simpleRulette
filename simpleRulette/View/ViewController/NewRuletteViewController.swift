//
//  NewRuletteViewController.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/17.
//

import Foundation
import UIKit

class NewRuletteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: プロパティ
    @IBOutlet weak var tableView: UITableView!
    var dataItems: [String] = []
    var dataColors: [UIColor] = []
    var isSaved = false
    @IBOutlet weak var templateSwitch: UISwitch!
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItemSet()
        templateSwitch.isOn = false
    }
    
    // MARK: 関数
    @IBAction func tapAddData(_ sender: Any) {
        dataItems.append("未設定")
        dataColors.append(UIColor.rand)
        self.tableView.reloadData()
    }
    
    func navigationItemSet() {
        var addBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(addButtonTapped))
        addBarButtonItem.tintColor = .black
        self.navigationItem.rightBarButtonItems = [addBarButtonItem]
    }
    
    @objc func addButtonTapped() {
        if isSaved {
            //テンプレートに保存する場合
            //realmに保存
        } else {
            //テンプレートに保存しない場合
            //こっちのルートはおそらくいらない
        }
        //前の画面にルーレットの値の入ったモデルを渡す
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
        cell.textView.text = dataItems[indexPath.row]
        cell.colorView.layer.cornerRadius = cell.colorView.frame.height / 2
        cell.colorView.backgroundColor = dataColors[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
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
}

//
//  TemplateViewController.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/17.
//

import Foundation
import UIKit

class TemplateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: プロパティ
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: UIView!
    var ruletteList: [Rulette] = []
    let ruletteViewModel = RuletteViewModel()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = "テンプレート"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ruletteList = ruletteViewModel.fetchAllData()
    }
    
    // MARK: tableView関連
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ruletteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateRuletteTableViewCell", for: indexPath) as? TemplateRuletteTableViewCell else {return UITableViewCell()}
        cell.titleLabel.text = ruletteList[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
            self.ruletteViewModel.deleteRuletteData(rulette: self.ruletteList[indexPath.item])
            self.ruletteList.remove(at: indexPath.row)
            tableView.reloadData()
              // 実行結果に関わらず記述
              completionHandler(true)
            }
            // 定義したアクションをセット
            return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

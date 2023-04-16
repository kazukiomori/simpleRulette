//
//  TemplateViewController.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/17.
//

import Foundation
import UIKit
import GoogleMobileAds

class TemplateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: プロパティ
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    var ruletteList: [Rulette] = []
    let ruletteViewModel = RuletteViewModel()
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = NSLocalizedString("templates", comment: "")
        bannerView.adUnitID = "ca-app-pub-3293568654583905/5620314493"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
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
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("delete", comment: "") ) { (action, view, completionHandler) in
            self.ruletteViewModel.deleteRuletteData(rulette: self.ruletteList[indexPath.item])
            self.ruletteList.remove(at: indexPath.row)
            tableView.reloadData()
              // 実行結果に関わらず記述
              completionHandler(true)
            }
            // 定義したアクションをセット
            return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if let previousViewController = navigationController?.viewControllers[0] as? RuletteViewController {
            previousViewController.titleString = ruletteList[indexPath.row].title
            var items: [String] = []
            for item in ruletteList[indexPath.row].ruletteItems {
                items.append(item.item)
            }
            previousViewController.items = items
        }
        //前の画面に戻る
        self.navigationController?.popViewController(animated: false)
    }
}

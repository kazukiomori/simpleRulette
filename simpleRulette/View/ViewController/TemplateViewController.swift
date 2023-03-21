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
    
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: tableView関連
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell else {return UITableViewCell()}
        return cell
    }
    
}

//
//  ViewController.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/15.
//

import UIKit
import Charts

class RuletteViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: プロパティ
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var triangleImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var bannerView: UIView!
    var buttonStartFlg = true
    var titleString = "タイトル"
    var items: [String] = [""]
    
    var dataEntries = [
        PieChartDataEntry(value: 100, label: "")
    ]
    let drum = Sound(fileNamed: "drum.wav",volume:0.5,numberOfLoops:-1)
    let roll = Sound(fileNamed: "roll.wav")
    // MARK: ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startRulette(_:)))
        pieChartView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        triangleImage.tintColor = .black
        resultLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = titleString
        if items.count == 1 {
            resultLabel.text = "データをセットしてください"
        } else {
            resultLabel.text = "ルーレットをタップしてスタート"
        }
        
        setupPieChartView()
    }
    
    // MARK: 関数
    func setupPieChartView() {
        self.pieChartView.centerText = "スタート"
        dataEntries = []
        for item in items {
            let dataEntry = PieChartDataEntry(value: Double(100 / items.count), label: item)
            dataEntries.append(dataEntry)
        }
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        // 円グラフ内に数値を表示しない
        dataSet.drawValuesEnabled = false
//        dataSet.drawValuesEnabled = false
        if dataSet.entries.count == 1 {
            dataSet.colors = [NSUIColor.gray]
        } else {
            // 色を設定
            dataSet.colors = ChartColorTemplates.material()
        }
        // グラフ上のデータラベルを非表示
        pieChartView.drawEntryLabelsEnabled = true
        // グラフの注釈を非表示
        pieChartView.legend.enabled = false
        let rouletteChartData = PieChartData(dataSet: dataSet)
        pieChartView.data = rouletteChartData
    }
    
    @objc func startRulette(_ sender : UITapGestureRecognizer) {
        if items.count == 1 {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        if buttonStartFlg {
            drum.play()
            self.pieChartView.centerText = "ストップ"
            pieChartView.layer.speed = 2.0
            animation.toValue = .pi / 2.0
            animation.duration = 0.1
            animation.repeatCount = MAXFLOAT
            animation.isCumulative = true
            pieChartView.layer.add(animation, forKey: "ImageViewRotation")
            buttonStartFlg = false
            resultLabel.text = "ルーレットをタップしてストップ"
        } else {
            drum.stop()
            roll.play()
            self.pieChartView.centerText = "スタート"
            let pausedTime = pieChartView.layer.convertTime(CACurrentMediaTime(), from: nil)
            pieChartView.layer.speed = 0.0
            pieChartView.layer.timeOffset = pausedTime
            buttonStartFlg = true
            
            // 現在の回転角度を得る
            if let transform = pieChartView.layer.presentation()?.transform {
                let angle = atan2(transform.m12, transform.m11)
                var testAngle = (angle * 180) / CGFloat.pi
                
                // 逆回転として考える（矢印の方が回転したと考える）
                if testAngle < 0 {
                    // マイナスならプラスにする
                    testAngle.negate()
                } else {
                    testAngle = 360 - testAngle
                }
                
                // 360° = 100% とした時の割合
                let per = (testAngle / 3.60)
                
                var itemValue = 0
                var count = 0
                for item in items {
                    itemValue += 100 / items.count
                    if per < Double(itemValue) || count == items.count {
                        resultLabel.text = "結果は\(item)です"
                        return
                    }
                    count += 1
                }
            }
        }
    }
    
    @IBAction func tappedAddDataButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "データをセット", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        // 表示させたいタイトル1ボタンが押された時の処理をクロージャ実装する
        let action1 = UIAlertAction(title: "新規追加", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //実際の処理
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let newViewController = storyBoard.instantiateViewController(withIdentifier: "NewRuletteViewController") as? NewRuletteViewController else { return }
            self.navigationController?.show(newViewController, sender: nil)
        })
        // 表示させたいタイトル2ボタンが押された時の処理をクロージャ実装する
        let action2 = UIAlertAction(title: "テンプレートから選ぶ", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TemplateViewController") as? TemplateViewController else { return }
            self.navigationController?.show(nextViewController, sender: nil)
        })
        
        // 閉じるボタンが押された時の処理をクロージャ実装する
        //UIAlertActionのスタイルがCancelなので赤く表示される
        let close = UIAlertAction(title: "閉じる", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) in
            //実際の処理
            
        })
        
        //UIAlertControllerにタイトル1ボタンとタイトル2ボタンと閉じるボタンをActionを追加
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(close)
        
        //実際にAlertを表示する
        self.present(actionSheet, animated: true, completion: nil)
    }
    
}


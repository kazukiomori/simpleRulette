//
//  ViewController.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/15.
//

import UIKit
import Charts

class RuletteViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var triangleImage: UIImageView!
    
    var buttonStartFlg = true

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(startRulette(_:)))
        pieChartView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        triangleImage.tintColor = .black
        setupPieChartView()
    }
    
    func setupPieChartView() {
        self.pieChartView.centerText = "スタート"

        // 仮の値
        let dataEntries = [
            PieChartDataEntry(value: 40, label: "A"),
            PieChartDataEntry(value: 35, label: "B"),
            PieChartDataEntry(value: 25, label: "C")
        ]
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        // 色を設定
        dataSet.colors = ChartColorTemplates.material()
        // グラフ上のデータラベルを非表示
        pieChartView.drawEntryLabelsEnabled = false
        // グラフの注釈を非表示
        pieChartView.legend.enabled = false
        let rouletteChartData = PieChartData(dataSet: dataSet)
        pieChartView.data = rouletteChartData
    }
    
    @objc func startRulette(_ sender : UITapGestureRecognizer) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        if buttonStartFlg {
            self.pieChartView.centerText = "ストップ"
            pieChartView.layer.speed = 2.0
            animation.toValue = .pi / 2.0
            animation.duration = 0.1
            animation.repeatCount = MAXFLOAT
            animation.isCumulative = true
            pieChartView.layer.add(animation, forKey: "ImageViewRotation")
            buttonStartFlg = false
        } else {
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
                
                // 矢印の位置
                print("final: (testAngle)º")
                
                // 360° = 100% とした時の割合
                let per = Int((testAngle) / 3.60)
                print("per: (per)")
                
                // 40:35:25 のグラフであれば、
                // 0..<40 -> A
                // 40..<75 -> B
                // 75...100 -> C
                // 一般化するにはもう一工夫必要
                if per < 40 {
                    print("A")
                } else if per < 40 + 35 {
                    print("B")
                } else {
                    print("C")
                }
            }
        }
    }
}


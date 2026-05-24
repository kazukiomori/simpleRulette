//
//  ViewController.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/15.
//

import UIKit
import GoogleMobileAds

final class RuletteWheelView: UIView {

    private struct Segment {
        let title: String
        let color: UIColor
    }

    private let centerLabel = UILabel()
    private var segments: [Segment] = []
    private var segmentLayers: [CAShapeLayer] = []
    private var titleLabels: [UILabel] = []

    var centerText: String = "" {
        didSet {
            centerLabel.text = centerText
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawSegments()
        layoutTitleLabels()
        layoutCenterLabel()
    }

    func configure(withTitles titles: [String]) {
        let colors = titles.count == 1 ? [.systemGray] : Self.defaultColors(for: titles.count)
        segments = zip(titles, colors).map { Segment(title: $0.0, color: $0.1) }
        setNeedsLayout()
    }

    func resetRotation() {
        layer.removeAnimation(forKey: "ImageViewRotation")
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        layer.transform = CATransform3DIdentity
    }

    private func commonInit() {
        isOpaque = false
        centerLabel.textAlignment = .center
        centerLabel.adjustsFontSizeToFitWidth = true
        centerLabel.minimumScaleFactor = 0.6
        centerLabel.font = .boldSystemFont(ofSize: 24)
        centerLabel.numberOfLines = 2
        centerLabel.backgroundColor = .systemBackground
        centerLabel.textColor = .label
        addSubview(centerLabel)
    }

    private func drawSegments() {
        segmentLayers.forEach { $0.removeFromSuperlayer() }
        segmentLayers.removeAll()

        guard !segments.isEmpty else {
            return
        }

        let radius = min(bounds.width, bounds.height) / 2.0
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let angleStep = (CGFloat.pi * 2.0) / CGFloat(segments.count)
        var startAngle = -CGFloat.pi / 2.0

        for segment in segments {
            let endAngle = startAngle + angleStep
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()

            let segmentLayer = CAShapeLayer()
            segmentLayer.path = path.cgPath
            segmentLayer.fillColor = segment.color.cgColor
            segmentLayer.strokeColor = UIColor.systemBackground.cgColor
            segmentLayer.lineWidth = 2
            layer.insertSublayer(segmentLayer, at: 0)
            segmentLayers.append(segmentLayer)

            startAngle = endAngle
        }
    }

    private func layoutTitleLabels() {
        titleLabels.forEach { $0.removeFromSuperview() }
        titleLabels.removeAll()

        guard !segments.isEmpty else {
            return
        }

        let radius = min(bounds.width, bounds.height) / 2.0
        let labelRadius = radius * 0.67
        let angleStep = (CGFloat.pi * 2.0) / CGFloat(segments.count)
        var currentAngle = -CGFloat.pi / 2.0 + (angleStep / 2.0)

        for segment in segments {
            let label = UILabel()
            label.text = segment.title
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.textColor = .white
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.6
            label.textAlignment = .center
            label.numberOfLines = 2

            let labelSize = CGSize(width: radius * 0.6, height: 40)
            let x = bounds.midX + cos(currentAngle) * labelRadius - (labelSize.width / 2.0)
            let y = bounds.midY + sin(currentAngle) * labelRadius - (labelSize.height / 2.0)
            label.frame = CGRect(origin: CGPoint(x: x, y: y), size: labelSize)
            addSubview(label)
            titleLabels.append(label)

            currentAngle += angleStep
        }
    }

    private func layoutCenterLabel() {
        let diameter = min(bounds.width, bounds.height) * 0.35
        centerLabel.frame = CGRect(
            x: bounds.midX - (diameter / 2.0),
            y: bounds.midY - (diameter / 2.0),
            width: diameter,
            height: diameter
        )
        centerLabel.layer.cornerRadius = diameter / 2.0
        centerLabel.layer.masksToBounds = true
    }

    private static func defaultColors(for count: Int) -> [UIColor] {
        let palette: [UIColor] = [
            .systemRed,
            .systemOrange,
            .systemYellow,
            .systemGreen,
            .systemMint,
            .systemTeal,
            .systemBlue,
            .systemIndigo,
            .systemPink
        ]

        guard count > 0 else {
            return []
        }

        return (0..<count).map { palette[$0 % palette.count] }
    }
}

class RuletteViewController: UIViewController, UIGestureRecognizerDelegate {

    static func selectedIndex(forDegrees degrees: CGFloat, itemCount: Int) -> Int? {
        guard itemCount > 0 else {
            return nil
        }

        let normalizedDegrees = Double(degrees).truncatingRemainder(dividingBy: 360)
        let positiveDegrees = normalizedDegrees >= 0 ? normalizedDegrees : normalizedDegrees + 360
        let sectorSize = 360.0 / Double(itemCount)
        let index = Int(positiveDegrees / sectorSize)
        return min(index, itemCount - 1)
    }
    
    // MARK: プロパティ
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pieChartView: RuletteWheelView!
    @IBOutlet weak var triangleImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var bannerView: UIView!
    private var adBannerView: BannerView?
    var buttonStartFlg = true
    var titleString = NSLocalizedString("titleString", comment: "")
    var items: [String] = [""]

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
        if AppRuntime.isRunningTests {
            bannerView.isHidden = true
            return
        }
        configureBannerView()
    }

    private func configureBannerView() {
        let adBannerView = BannerView(adSize: AdSizeBanner)
        adBannerView.frame = bannerView.bounds
        adBannerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        adBannerView.adUnitID = "ca-app-pub-9554476195266174/5074035808"
        adBannerView.rootViewController = self
        bannerView.addSubview(adBannerView)
        adBannerView.load(Request())
        self.adBannerView = adBannerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = titleString
        if items.count == 1 {
            resultLabel.text = NSLocalizedString("setData", comment: "")
        } else {
            resultLabel.text = NSLocalizedString("tapRulette", comment: "")
        }
        
        setupPieChartView()
    }
    
    // MARK: 関数
    func setupPieChartView() {
        pieChartView.resetRotation()
        buttonStartFlg = true
        pieChartView.centerText = NSLocalizedString("start", comment: "")
        pieChartView.configure(withTitles: items)
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
            self.pieChartView.centerText = NSLocalizedString("stop", comment: "")
            pieChartView.layer.speed = 2.0
            animation.toValue = .pi / 2.0
            animation.duration = 0.1
            animation.repeatCount = MAXFLOAT
            animation.isCumulative = true
            pieChartView.layer.add(animation, forKey: "ImageViewRotation")
            buttonStartFlg = false
            resultLabel.text = NSLocalizedString("tapRuletteToStop", comment: "")
        } else {
            drum.stop()
            roll.play()
            self.pieChartView.centerText = NSLocalizedString("start", comment: "")
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
                if let selectedIndex = Self.selectedIndex(forDegrees: testAngle, itemCount: items.count) {
                    let item = items[selectedIndex]
                    resultLabel.text = String(format: NSLocalizedString("result", comment: ""), item)
                    return
                }
            }
        }
    }
    
    @IBAction func tappedAddDataButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: NSLocalizedString("setAData", comment: ""), message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        // 表示させたいタイトル1ボタンが押された時の処理をクロージャ実装する
        let action1 = UIAlertAction(title: NSLocalizedString("newAdditions", comment: ""), style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            //実際の処理
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let newViewController = storyBoard.instantiateViewController(withIdentifier: "NewRuletteViewController") as? NewRuletteViewController else { return }
            self.navigationController?.show(newViewController, sender: nil)
        })
        // 表示させたいタイトル2ボタンが押された時の処理をクロージャ実装する
        let action2 = UIAlertAction(title: NSLocalizedString("selectFromTemplates", comment: ""), style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TemplateViewController") as? TemplateViewController else { return }
            self.navigationController?.show(nextViewController, sender: nil)
        })
        
        // 閉じるボタンが押された時の処理をクロージャ実装する
        //UIAlertActionのスタイルがCancelなので赤く表示される
        let close = UIAlertAction(title: NSLocalizedString("close", comment: ""), style: UIAlertAction.Style.destructive, handler: {
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


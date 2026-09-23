//
//  BannerAdView.swift
//  simpleRulette
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = Self.rootViewController()
        // 従来はdelegateが未設定で、広告のロード成否が一切わからなかった
        // (「広告が1件も表示されない」という報告があっても原因を切り分けられない
        // 状態だった)。ロード成功/失敗をログに残すようにする。
        bannerView.delegate = context.coordinator
        bannerView.load(Self.nonPersonalizedRequest())
        return bannerView
    }

    final class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("BannerAdView: ad loaded successfully (adUnitID: \(bannerView.adUnitID ?? "-"))")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("BannerAdView: failed to load ad (adUnitID: \(bannerView.adUnitID ?? "-")) —", error.localizedDescription)
        }
    }

    // IDFA等を使ったトラッキングを行わないため、常に非パーソナライズ広告(npa=1)を
    // リクエストする。ATT許諾ダイアログを出さずに済ませる方針のための対応。
    private static func nonPersonalizedRequest() -> Request {
        let request = Request()
        let extras = Extras()
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)
        return request
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        if uiView.rootViewController == nil {
            uiView.rootViewController = Self.rootViewController()
        }
    }

    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

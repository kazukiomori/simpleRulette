//
//  Sound.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/22.
//


import AVFoundation

class Sound {

    //playerを作成。リソース読み込みや初期化に失敗した場合はnilのままとし、以降の再生系メソッドは無音で無視する(アプリ全体をクラッシュさせない)
    var player: AVAudioPlayer?

    init(fileNamed:String,volume:Float,numberOfLoops:Int){
        let fileNameStrings = fileNamed.components(separatedBy: ".")
        guard fileNameStrings.count >= 2 else {
            print("Sound: invalid fileNamed format: \(fileNamed)")
            return
        }
        let fileName = fileNameStrings[0]
        let fileType = fileNameStrings[1]
        let url = Bundle.main.url(forResource: fileName, withExtension: fileType)
        guard let url = url else {
            print("Sound: resource not found: \(fileNamed)")
            return
        }

        do {
            let loadedPlayer = try AVAudioPlayer(contentsOf: url)
            loadedPlayer.numberOfLoops = numberOfLoops/* 0なら一回、自然数ならその数だけループ、負の数なら永久ループ */
            loadedPlayer.prepareToPlay()     //再生準備 (タイミングがシビアな時のみ)
            loadedPlayer.volume = volume
            player = loadedPlayer
        } catch {
            print("Sound: failed to initialize a player for \(fileNamed): \(error)")
        }
    }

    convenience init(fileNamed:String){
        self.init(fileNamed:fileNamed,volume:1.0,numberOfLoops:0)
    }

    func playFromBeginning() {
        guard let player else { return }
        player.currentTime = 0
        player.play()
    }

    func setVolume(_ volume: Float) {
        player?.volume = volume
    }

    func reset() {
        player?.currentTime = 0
    }

    //AVAudioPlayerのメソッドを流用。これで〇〇.player.play()でなく〇〇.play()で済む
    func play(){
        player?.play()
    }

    func pause(){
        player?.pause()
    }

    func stop(){
        player?.stop()
    }
}


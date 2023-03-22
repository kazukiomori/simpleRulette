//
//  Sound.swift
//  simpleRulette
//
//  Created by Kazuki Omori on 2023/03/22.
//


import AVFoundation

class Sound {

    //playerを作成
    var player: AVAudioPlayer!

    init(fileNamed:String,volume:Float,numberOfLoops:Int){
        let fileNameStrings = fileNamed.components(separatedBy: ".")
        let fileName = fileNameStrings[0]
        let fileType = fileNameStrings[1]
        let url = Bundle.main.url(forResource: fileName, withExtension: fileType)
        if let url = url {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = numberOfLoops/* 0なら一回、自然数ならその数だけループ、負の数なら永久ループ */
                player.prepareToPlay()     //再生準備 (タイミングがシビアな時のみ)
                player.volume = volume
            } catch {
                //プレイヤー作成失敗
                fatalError("Failed to initialize a player.")
            }

        } else {
            //エラーを表示させる
            fatalError("Error loading sound resource: " + fileNamed)
        }

    }

    convenience init(fileNamed:String){
        self.init(fileNamed:fileNamed,volume:1.0,numberOfLoops:0)
    }

    //AVAudioPlayerのメソッドを流用。これで〇〇.player.play()でなく〇〇.play()で済む
    func play(){
        self.player.play()
    }

    func pause(){
        self.player.pause()
    }

    func stop(){
        self.player.stop()
    }
}


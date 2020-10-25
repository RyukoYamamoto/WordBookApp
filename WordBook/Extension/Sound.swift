//
//  Sound.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/08/30.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import AVFoundation

class Sound{

    //playerを作成
    var player: AVAudioPlayer!

    init(fileNamed:String,volume:Float,numberOfLoops:Int){
        let fileNameStrings = fileNamed.components(separatedBy: ".")
        let fileName = fileNameStrings[0]
        let fileType = fileNameStrings[1]
        let path = Bundle.main.path(forResource: fileName, ofType: fileType)!
        let url = URL(fileURLWithPath: path)
     
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = numberOfLoops/* 0なら一回、自然数ならその数だけループ、負の数なら永久ループ */
                player.prepareToPlay()     //再生準備 (タイミングがシビアな時のみ)
                player.volume = volume
            } catch {
                //プレイヤー作成失敗
                fatalError("Failed to initialize a player.")
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

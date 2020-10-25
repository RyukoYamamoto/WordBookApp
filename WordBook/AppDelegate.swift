//
//  AppDelegate.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/08/24.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // APIキーの設定とSDK初期化
        NCMB.initialize(applicationKey: "3f8331a800b353705d685c6f3d2ad8c284cddcf9d5623dfb891b9e4ee6fead30", clientKey: "97038808e519c50aa421e88f281ed5d61f36e82bd28fc8d5d67daeac3b1d0049");
        
        //初回起動判定
//        UserDefaults.standard.set(false, forKey: "firstLaunch") //リセット用
        let firstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
        if firstLaunch {
            //二回目以降
            print("二回目以降")
        } else {
            //初回アクセス
            print("初回起動")
            UserDefaults.standard.set(true, forKey: "firstLaunch")
            
            if let csvPath = Bundle.main.path(forResource: "国名", ofType: "csv") {
                do {
                    let csvStr = try String(contentsOfFile:csvPath, encoding:String.Encoding.utf8)
                    var csvArr = csvStr.components(separatedBy: .newlines)
                    csvArr = csvArr.filter({$0.isEmpty == false})
                    UserDefaults.standard.set(csvArr, forKey: "首都words")
                } catch let error as NSError {
                     print(error.localizedDescription)
                }
            }
            if let csvPath = Bundle.main.path(forResource: "首都", ofType: "csv") {
                do {
                    let csvStr = try String(contentsOfFile:csvPath, encoding:String.Encoding.utf8)
                    var csvArr = csvStr.components(separatedBy: .newlines)
                    csvArr = csvArr.filter({$0.isEmpty == false})
                    UserDefaults.standard.set(csvArr, forKey: "首都meanings")
                    
                    var results: [String] = []
                    for _ in 0..<csvArr.count {
                        results.append("")
                    }
                    UserDefaults.standard.set(results, forKey: "首都results")
                } catch let error as NSError {
                     print(error.localizedDescription)
                }
            }
            if let csvPath = Bundle.main.path(forResource: "県名", ofType: "csv") {
                do {
                    let csvStr = try String(contentsOfFile:csvPath, encoding:String.Encoding.utf8)
                    var csvArr = csvStr.components(separatedBy: .newlines)
                    csvArr = csvArr.filter({$0.isEmpty == false})
                    UserDefaults.standard.set(csvArr, forKey: "県庁所在地words")
                } catch let error as NSError {
                     print(error.localizedDescription)
                }
            }
            if let csvPath = Bundle.main.path(forResource: "県庁所在地", ofType: "csv") {
                do {
                    let csvStr = try String(contentsOfFile:csvPath, encoding:String.Encoding.utf8)
                    var csvArr = csvStr.components(separatedBy: .newlines)
                    csvArr = csvArr.filter({$0.isEmpty == false})
                    UserDefaults.standard.set(csvArr, forKey: "県庁所在地meanings")
                    
                    var results: [String] = []
                    for _ in 0..<csvArr.count {
                        results.append("")
                    }
                    UserDefaults.standard.set(results, forKey: "県庁所在地results")
                } catch let error as NSError {
                     print(error.localizedDescription)
                }
            }
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    //bgm.wavを0.5のvolumeで永久ループで再生//
    let bgm = Sound(fileNamed: "main.mp3",volume:0.25,numberOfLoops:-1)
    let trueSound = Sound(fileNamed: "true.mp3",volume:1.4,numberOfLoops:0)
    let falseSound = Sound(fileNamed: "false.mp3",volume:1.4,numberOfLoops:0)
    let effectSound = Sound(fileNamed: "effect.mp3",volume:1.2,numberOfLoops:0)
}

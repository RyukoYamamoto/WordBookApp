//
//  TestVC.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/08/27.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit
import AVFoundation

class TestViewController: UIViewController {
    
    @IBOutlet weak var emptyTestView: EmptyTestView!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var wrongBtn: UIButton!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var wrongImage: UIImageView!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let homeVC = HomeViewController()
    let wordVC = WordViewController()
    
    var indexPath = 0
    var startIndex = 0
    var category = ""
    var mode = 0
    var row = 6
    var random: Bool = false
    var orders: [Int] = []
    var getWords: [String] = []
    var getMeanings: [String] = []
    var getResults: [String] = []
    var randomGetResults: [String] = []
    var list: [Int] = [10, 20, 30, 40, 50, 100, 0]
    var setBarButtonItem: UIBarButtonItem!
    var talker = AVSpeechSynthesizer()
    
    //初回表示時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面のタイトル
        title = "テスト"
        
        //bgmの停止
        appDelegate.bgm.stop()
        
        //やめるボタンの設置
        setBarButtonItem = UIBarButtonItem(image: UIImage(named: "cross.png")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(setBarButtonItemTapped(_:)))
        setBarButtonItem.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        navigationItem.rightBarButtonItem = setBarButtonItem
        
        //モードの取得
        mode = wordVC.userDefaults.integer(forKey: "mode")
        //ランダムかの取得
        random = wordVC.userDefaults.bool(forKey: "random")
        category = (wordVC.userDefaults.string(forKey: "number") )!
            
        //配列の取得
        if random {
            orders = wordVC.userDefaults.array(forKey: "\(category)orders") as! [Int]
            getWords = wordVC.userDefaults.array(forKey: "\(category)randomWords") as! [String]
            getMeanings = wordVC.userDefaults.array(forKey: "\(category)randomMeanings") as! [String]
            getResults = wordVC.userDefaults.array(forKey: "\(category)randomResults") as! [String]
            randomGetResults = wordVC.userDefaults.array(forKey: "\(category)testResults") as! [String]
        } else {
            getWords = wordVC.userDefaults.array(forKey: "\(category)testWords") as! [String]
            getMeanings = wordVC.userDefaults.array(forKey: "\(category)testMeanings") as! [String]
            getResults = wordVC.userDefaults.array(forKey: "\(category)testResults") as! [String]
        }
        
        //問題数の取得
        if UserDefaults.standard.object(forKey: "\(category)range") != nil {
            if mode == 0 {
                row = wordVC.userDefaults.integer(forKey: "\(category)range")
            } else {
                row = wordVC.userDefaults.integer(forKey: "\(category)missRange")
            }
        }
        list[6] = getWords.count
        
        //初期値の取得
        startIndex = wordVC.userDefaults.integer(forKey: "\(category)startIndex")

        //戻るボタンを隠す
        navigationItem.hidesBackButton = true

        //testViewの設定
        emptyTestView.wordLabel.text = getWords[startIndex + indexPath]
        emptyTestView.meaningLabel.text = getMeanings[startIndex + indexPath]
        emptyTestView.meaningLabel.isHidden = true
        
        //checkBtnの設定
        checkBtn.layer.cornerRadius = 5.0
        checkBtn.layer.addShadow(direction: .bottom)
        checkBtn.isHidden = false
        
        //rightBtnの設定
        rightBtn.isEnabled = true
        rightBtn.layer.cornerRadius = 5.0
        rightBtn.layer.addShadow(direction: .bottom)
        rightBtn.isExclusiveTouch = true
        rightBtn.isHidden = true
        
        //wrongBtnの設定
        wrongBtn.isEnabled = true
        wrongBtn.layer.cornerRadius = 5.0
        wrongBtn.layer.addShadow(direction: .bottom)
        wrongBtn.isExclusiveTouch = true
        wrongBtn.isHidden = true
        
        //正解画像を隠す
        rightImage.isHidden = true
        //不正解画像を隠す
        wrongImage.isHidden = true
        
        guard let text = emptyTestView.wordLabel.text else {
            return
        }
        //テキストが英語ならば読み上げる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
            // 話す内容をセット
            let utterance = AVSpeechUtterance(string: text)
            // 言語を設定
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            //音量を設定
            utterance.volume = 1.0
            // 実行
            self.talker.speak(utterance)
        }
    }
    
    //ビュー表示時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //emptyTestViewに影をつけ角丸にする
        emptyTestView.layer.masksToBounds = true
        emptyTestView.layer.cornerRadius = 25.0
        emptyTestView.layer.addShadow(direction: .bottom)
    }
    
    //やめるボタンタップ時の呼び出しメソッド
    @objc func setBarButtonItemTapped(_ sender: UIBarButtonItem){
        //bgmの開始
        appDelegate.bgm.play()
        
        //前の画面に戻る
        navigationController?.popViewController(animated: true)
    }
    
    //checkBtnボタン押下時に呼ばれるメソッド
    @IBAction func checkBtn(_ sender: Any) {
        emptyTestView.meaningLabel.isHidden = false
        checkBtn.isHidden = true
        rightBtn.isHidden = false
        wrongBtn.isHidden = false
    }
    
    //rightBtnボタン押下時に呼ばれるメソッド
    @IBAction func rightBtn(_ sender: Any) {
        //連続して押せないようにする
        rightBtn.isEnabled = false
        
        //正解音を流す
        appDelegate.trueSound.play()
        
        getResults[startIndex + indexPath] = "◯"
        
        if random {
            randomGetResults[orders[startIndex + indexPath]] = "◯"
            wordVC.userDefaults.set(getResults,forKey: "\(category)randomResults")
            wordVC.userDefaults.set(randomGetResults,forKey: "\(category)testResults")
            if mode == 0 {
                wordVC.userDefaults.set(randomGetResults,forKey: "\(category)results")
            }

        } else {
            wordVC.userDefaults.set(getResults,forKey: "\(category)testResults")
            if mode == 0 {
                wordVC.userDefaults.set(getResults,forKey: "\(category)results")
            }
        }
        
        //正解アニメーション
        UIView.transition(with: rightImage, duration: 0.2, options: [.transitionCrossDissolve], animations: {
            self.rightImage.isHidden = false
        })
        
        if(startIndex + indexPath < getWords.count - 1) && (indexPath < list[row] - 1) {
            indexPath += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                self.viewDidLoad()
            }
        } else {
            wordVC.userDefaults.set(indexPath,forKey: "\(category)total")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                //結果画面へ
                self.performSegue(withIdentifier: "Segue", sender: nil)
            }
        }
    }
    
    //rightBtnボタン押下時に呼ばれるメソッド
    @IBAction func wrongBtn(_ sender: Any) {
        //連続で押せないようにする
        wrongBtn.isEnabled = false
        
        //不正解音
        appDelegate.falseSound.play()
        
        getResults[startIndex + indexPath] = "×"
        
        if random {
            randomGetResults[orders[startIndex + indexPath]] = "×"
            wordVC.userDefaults.set(getResults,forKey: "\(category)randomResults")
            wordVC.userDefaults.set(randomGetResults,forKey: "\(category)testResults")
            if mode == 0 {
                wordVC.userDefaults.set(randomGetResults,forKey: "\(category)results")
            }
        } else {
            wordVC.userDefaults.set(getResults,forKey: "\(category)testResults")
            if mode == 0 {
                wordVC.userDefaults.set(getResults,forKey: "\(category)results")
            }
        }
        
        //不正解のアニメーション
        UIView.transition(with: wrongImage, duration: 0.2, options: [.transitionCrossDissolve], animations: {
            self.wrongImage.isHidden = false
        })
        
        if(startIndex + indexPath < getWords.count - 1) && (indexPath < list[row] - 1) {
            indexPath += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                self.viewDidLoad()
            }
        } else {
            wordVC.userDefaults.set(indexPath,forKey: "\(category)total")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                //結果画面へ遷移
                self.performSegue(withIdentifier: "Segue", sender: nil)
            }
        }
    }
}

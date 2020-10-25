//
//  DownloadResultVC.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/09/30.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit
import GradientCircularProgress

class DownloadResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 15
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let wordVC = WordViewController()
    
    var objectId: String = ""
    var random: Bool = false
    var getWords: [String] = []
    var getMeanings: [String] = []
    var getResults: [String] = []
    var score: Double = 0.0
    var total: Int = 0
    var startIndex = 0
    
    // Progress
    let progress = GradientCircularProgress()
    var progressView: UIView?
    // Demo
    var timer: Timer?
    var v: Double = 0.0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var homeBtn: UIButton!
    
    //初回表示時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面のタイトル
        title = "結果"
        
        //bgmの再生
        appDelegate.bgm.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
            self.appDelegate.effectSound.play()
        }
        
        //viewをnavigationbarの下から始める
        navigationController?.navigationBar.isTranslucent = false
        
        //戻るボタンを非表示に
        navigationItem.hidesBackButton = true
        
        //テーブルビューの保存・設定
        tableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        //homeBtnに影を追加、角丸にする
        homeBtn.layer.cornerRadius = 5.0
        homeBtn.layer.addShadow(direction: .bottom)
        
        //objectIdの取得
        objectId = wordVC.userDefaults.string(forKey: "objectId")!
        //ランダムかの取得
        random = wordVC.userDefaults.bool(forKey: "random")
        //配列の取得
        if random {
            getWords = wordVC.userDefaults.array(forKey: "\(objectId)randomWords") as! [String]
            getMeanings = wordVC.userDefaults.array(forKey: "\(objectId)randomMeanings") as! [String]
            getResults = wordVC.userDefaults.array(forKey: "\(objectId)randomResults") as! [String]
        } else {
            getWords = wordVC.userDefaults.array(forKey: "\(objectId)words") as! [String]
            getMeanings = wordVC.userDefaults.array(forKey: "\(objectId)meanings") as! [String]
            getResults = wordVC.userDefaults.array(forKey: "\(objectId)results") as! [String]
        }
        
        //初期値の取得
        startIndex = wordVC.userDefaults.integer(forKey: "\(objectId)startIndex")
        
        //スコアの計算
        total = wordVC.userDefaults.integer(forKey: "\(objectId)total") + 1
        for i in startIndex ..< startIndex + total {
            if getResults[i] == "◯" {
                score += 1
            }
        }
        
        //subViewを表示
        showAtRatioTypeSubView()
    }
    
    //作成するセル数の指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return total
    }
        
    func  tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return 1
    }
    
    //セル同士の間隔の指定
    func  tableView(_ tableView: UITableView, heightForHeaderInSection: Int) -> CGFloat {
        guard heightForHeaderInSection != 0 else {
            return 0
        }
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection: Int) -> UIView?{
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //セルの高さ指定
    func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
        
    //セルの作成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResultCell
        
        let sliceWords = getWords[startIndex..<startIndex + total]
        let sliceMeanings = getMeanings[startIndex..<startIndex + total]
        let sliceResults = getResults[startIndex..<startIndex + total]
        
        //セルのテキスト作成
        cell.wordLabel.text = sliceWords[startIndex + indexPath.section]
        cell.meaningLabel.text = sliceMeanings[startIndex + indexPath.section]
        cell.resultLabel.text = sliceResults[startIndex + indexPath.section]
        if cell.resultLabel.text == "◯" {
            cell.resultLabel.textColor = .red
        } else {
            cell.resultLabel.textColor = .blue
        }

        //セルの色・影などの設定
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 8
        cell.layer.addShadow(direction: .bottom)
        cell.selectedBackgroundView?.layer.cornerRadius = 8
        cell.selectedBackgroundView?.clipsToBounds = true
        
        return cell
    }
    
    //セルタップ時の呼び出しメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //homeBtnボタン押下時に呼ばれるメソッド
    @IBAction func homeButtonTapped(_ sender: Any) {
        //layere_number：階層番号を表す。０がトップ画面（rootView）
        let layere_number = navigationController!.viewControllers.count
         
        navigationController?.popToViewController(navigationController!.viewControllers[layere_number-3], animated: false)
    }
}

// SubView
extension DownloadResultViewController {
    
    func showAtRatioTypeSubView() {
        
        progressView = progress.showAtRatio(frame: getRect(), display: true, style: CircularProgress())
        progressView?.layer.cornerRadius = 12.0
        view.addSubview(progressView!)
        
        startProgressAtRatio()
    }
}

// for demo
extension DownloadResultViewController {
    func startProgressAtRatio() {
        v = 0.0
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(updateProgressAtRatio),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    @objc func updateProgressAtRatio() {
        v += 0.005
        
        progress.updateRatio(CGFloat(v))
        
        if v > (score/Double(total)) {
            timer!.invalidate()
        }
    }
    
    func getRect() -> CGRect {
        let screenRect = UIScreen.main.bounds
        return CGRect(
            x: view.frame.origin.x + 15,
            y: (view.frame.size.height - view.frame.size.width) / 2 - screenRect.height / 2 + 98,
            width: view.frame.size.width - 30,
            height: view.frame.size.width - 30)
    }
}

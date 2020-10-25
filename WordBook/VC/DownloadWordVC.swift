//
//  DownloadWordVC.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/09/28.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit
import NCMB

class DownloadWordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var studyBtn: UIButton!
    
    var words: [String] = []
    var meanings: [String] = []
    var results: [String] = []
    var random = false
    var startIndex = 0
    var setBarButtonItem: UIBarButtonItem!
    var shuffleBarButtonItem: UIBarButtonItem!
    var objectId: String = ""
    var alert: UIAlertController?
    
    // 取得したデータを格納する配列
    var categories: Array<NCMBObject> = []
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 15
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let wordVC = WordViewController()
    
    //ビュー表示時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面のタイトル
        title = "ワード"
        
        //設定ボタンの作成
        setBarButtonItem = UIBarButtonItem(image: UIImage(named: "set.png")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(setBarButtonItemTapped(_:)))
        //シャッフルボタンの作成
        shuffleBarButtonItem = UIBarButtonItem(image: UIImage(named: "shuffle.png")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(shuffleBarButtonItemTapped(_:)))
        random = wordVC.userDefaults.bool(forKey: "random")
        wordVC.userDefaults.set(random,forKey: "random")
        if random {
            shuffleBarButtonItem.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        } else {
            shuffleBarButtonItem.tintColor = .gray
        }
        navigationItem.rightBarButtonItems = [setBarButtonItem, shuffleBarButtonItem]
        
        //テーブルビューの設定
        tableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        //タブバーを非表示に
        tabBarController?.tabBar.isHidden = true
        
        // testクラスへのNCMBObjectを設定
        let object : NCMBObject = NCMBObject(className: "TestClass")
        object.objectId = wordVC.userDefaults.string(forKey: "objectId")!
        objectId = wordVC.userDefaults.string(forKey: "objectId")!
        
        object.fetchInBackground(callback: { result in
            switch result {
                case .success:
                    // 取得に成功した場合の処理
                    print("取得に成功しました")
                    if let fieldB : [String] = object["fieldB"] {
                        self.words = fieldB
                    }
                    if let fieldC : [String] = object["fieldC"] {
                        self.meanings = fieldC
                    }
                    DispatchQueue.main.async {
                        self.wordVC.userDefaults.set(self.words,forKey: "\(self.objectId)words")
                        self.tableView.reloadData()
                    }
                case let .failure(error):
                    // 取得に失敗した場合の処理
                    print("取得に失敗しました: \(error)")
                    DispatchQueue.main.async {
                        //アラートの表示
                        self.alert = UIAlertController(
                            title: "エラー",
                            message: "通信に失敗しました。",
                            preferredStyle: UIAlertController.Style.alert)

                        let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)

                        self.alert?.addAction(cancelAction)

                        self.present(self.alert!, animated: true, completion: nil)
                    }
            }
        })
    }
    
    //ビュー表示時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        studyBtn.layer.cornerRadius = 5.0
        studyBtn.layer.addShadow(direction: .bottom)
    }
    
    //作成するセル数の指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return words.count
    }
    
    func  tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return 1
    }
    
    //セル同士の間隔の指定
    func  tableView(_ tableView: UITableView, heightForHeaderInSection: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection: Int) -> UIView?{
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //セルの高さ指定
    func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let horizonSizeClass = UITraitCollection(horizontalSizeClass: .regular)
        if traitCollection.containsTraits(in: horizonSizeClass) {
            return 70
        } else {
            return 50
        }
    }
    
    //セルの作成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResultCell

        //セルのテキスト作成
        cell.wordLabel.text = words[indexPath.section]
        cell.meaningLabel.text = meanings[indexPath.section]
        if indexPath.section < results.count {
            cell.resultLabel.text = results[indexPath.section]
        } else {
            cell.resultLabel.text = ""
        }
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
        //cell.clipsToBounds = true
        cell.layer.addShadow(direction: .bottom)
        cell.selectedBackgroundView?.layer.cornerRadius = 8
        cell.selectedBackgroundView?.clipsToBounds = true
        
        return cell
    }
    
    //セルタップ時の呼び出しメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard words.count != 0 else {
            return
        }
        
        //配列のシャッフル
        if random {
            var count: [Int] = []
            var randomWords: [String] = []
            var randomMeanings: [String] = []
            var randomResults: [String] = []
            for i in 0..<words.count {
                count.append(i)
                results.append("")
            }
            let order = count.shuffled()
            for i in 0..<words.count {
                randomWords.append(words[order[i]])
                randomMeanings.append(meanings[order[i]])
                randomResults.append(results[order[i]])
            }
            wordVC.userDefaults.set(randomWords,forKey: "\(objectId)randomWords")
            wordVC.userDefaults.set(randomMeanings,forKey: "\(objectId)randomMeanings")
            wordVC.userDefaults.set(randomResults,forKey: "\(objectId)randomResults")
        } else {
            for _ in 0..<words.count {
                results.append("")
            }
            wordVC.userDefaults.set(words,forKey: "\(objectId)words")
            wordVC.userDefaults.set(meanings,forKey: "\(objectId)meanings")
            wordVC.userDefaults.set(results,forKey: "\(objectId)results")
        }
        
        wordVC.userDefaults.set(indexPath.section,forKey: "\(objectId)startIndex")
        
        //ハイライトを消す
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "Segue", sender: nil)
    }
    
    //設定ボタンタップ時の呼び出しメソッド
    @objc func setBarButtonItemTapped(_ sender: UIBarButtonItem){
        performSegue(withIdentifier: "Segue2", sender: nil)
    }
    
    //シャッフルボタンタップ時の呼び出しメソッド
    @objc func shuffleBarButtonItemTapped(_ sender: UIBarButtonItem){
        random.toggle()
        wordVC.userDefaults.set(random, forKey: "random")
        if random {
            shuffleBarButtonItem.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        } else {
            shuffleBarButtonItem.tintColor = .gray
        }
    }
    
    //studyBtnボタン押下時に呼ばれるメソッド
    @IBAction func studyAction(_ sender: Any) {
        guard words.count != 0 else {
            return
        }
        
        //配列のシャッフル
        if random {
            var count: [Int] = []
            var randomWords: [String] = []
            var randomMeanings: [String] = []
            var randomResults: [String] = []
            for i in 0..<words.count {
                count.append(i)
                results.append("")
            }
            let order = count.shuffled()
            for i in 0..<words.count {
                randomWords.append(words[order[i]])
                randomMeanings.append(meanings[order[i]])
                randomResults.append(results[order[i]])
            }
            wordVC.userDefaults.set(randomWords,forKey: "\(objectId)randomWords")
            wordVC.userDefaults.set(randomMeanings,forKey: "\(objectId)randomMeanings")
            wordVC.userDefaults.set(randomResults,forKey: "\(objectId)randomResults")
        } else {
            for _ in 0..<words.count {
                results.append("")
            }
            wordVC.userDefaults.set(words,forKey: "\(objectId)words")
            wordVC.userDefaults.set(meanings,forKey: "\(objectId)meanings")
            wordVC.userDefaults.set(results,forKey: "\(objectId)results")
        }
        
        wordVC.userDefaults.set(startIndex,forKey: "\(objectId)startIndex")
        
        performSegue(withIdentifier: "Segue", sender: nil)
    }
}

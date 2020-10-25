//
//  HomeViewController.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/08/24.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit
import NCMB

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categories: [String] = ["首都", "県庁所在地"]
    var currentCategories: [String] = ["首都", "県庁所在地"]
    var words: [String] = []
    var meanings: [String] = []
    var empties: [String] = []
    var selectNumber: [Int] = []
    var alert: UIAlertController?
    var numberOfRegistration = 0
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 15
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let wordVC = WordViewController()
    
    //初回表示時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面のタイトル
        title = "ホーム"
        
        //bgmの再生
        appDelegate.bgm.play()
        
        //カテゴリー名の格納された配列の取得
        if UserDefaults.standard.object(forKey: "categories") != nil {
            categories = wordVC.userDefaults.array(forKey: "categories") as! [String]
            currentCategories = wordVC.userDefaults.array(forKey: "categories") as! [String]
        }
        //カテゴリー名の格納された配列の保存
        wordVC.userDefaults.set(categories,forKey: "categories")
        
        //ナビゲーションバーの戻るボタンの非表示
        navigationItem.hidesBackButton = true
        
        //ナビゲーションバー右にボタン設置
        editButtonItem.title = "登録"
        navigationItem.rightBarButtonItem = editButtonItem
        
        //テーブルビューの保存・設定
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        
        //選択セル確認のための配列の作成
        for _ in 0..<currentCategories.count {
            selectNumber.append(0)
        }
        
        //検索バーに何も入力されていなくてもReturnキーを押せるようにする。
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    //ビュー表示時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let screenRect = UIScreen.main.bounds
        let horizonSizeClass = UITraitCollection(horizontalSizeClass: .regular)
        
        //addBtnの大きさの設定
        if traitCollection.containsTraits(in: horizonSizeClass) {
            addBtn.layer.cornerRadius = screenRect.width/24
        } else {
            addBtn.layer.cornerRadius = screenRect.width/17
        }
        //addBtnに影を追加
        addBtn.layer.addShadow(direction: .bottom)
        
        //タブバーの表示
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //編集ボタンの押下時に呼ばれる
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        //編集モードの切り替え
        tableView.isEditing = editing
        
        //編集ボタンの文字変更
        if(self.isEditing){
            self.editButtonItem.title = "キャンセル"
        } else {
            self.editButtonItem.title = "登録"
        }
        
        //編集モード時の選択確認
        if numberOfRegistration > 0 {
            numberOfRegistration = 0
            //選択データの取得・保存
            for i in 0..<selectNumber.count {
                if selectNumber[i] == 1 {
                    selectNumber[i] = 0
                    //選択データの取得
                    if UserDefaults.standard.object(forKey: "\(currentCategories[i])words") != nil {
                        words = wordVC.userDefaults.array(forKey: "\(currentCategories[i])words") as! [String]
                    }
                    if UserDefaults.standard.object(forKey: "\(currentCategories[i])meanings") != nil {
                        meanings = wordVC.userDefaults.array(forKey: "\(currentCategories[i])meanings") as! [String]
                    }
                    
                    //保存データの作成
                    let object = NCMBObject(className: "TestClass")
                    object["fieldA"] = currentCategories[i]
                    object["fieldB"] = words
                    object["fieldC"] = meanings
                    
                    // クエリの作成
                    var query = NCMBQuery.getQuery(className: "TestClass")
                    var sameArray = 0
                    query.where(field: "fieldA", equalTo: "\(currentCategories[i])")
                    query.where(field: "fieldB", containsAllObjectsInArrayTo: words)

                    // 検索を行う
                    query.findInBackground(callback: { result in
                        switch result {
                            case let .success(array):
                                print("取得に成功しました 件数: \(array.count)")
                                sameArray = array.count
                                //同じ単語帳があるかの確認
                                guard sameArray == 0 else {
                                    return
                                }
                                //権利侵害の有無確認アラートの表示
                                DispatchQueue.main.async {
                                    self.alert = UIAlertController(
                                        title: "確認",
                                        message: "権利侵害コンテンツを含んでいませんか？",
                                        preferredStyle: UIAlertController.Style.alert)

                                    let cancelAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.destructive, handler: nil)
                                    let okAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
                                        (action:UIAlertAction!) -> Void in
                                        object.saveInBackground(callback: { result in
                                            switch result {
                                            case .success:
                                                print("保存に成功しました")
                                            case .failure(_):
                                                print("保存に失敗しました")
                                            }
                                        })
                                    })
                                                                    
                                    self.alert?.addAction(cancelAction)
                                    self.alert?.addAction(okAction)

                                    self.present(self.alert!, animated: true, completion: nil)
                                }

                            case let .failure(error):
                                print("取得に失敗しました: \(error)")
                                DispatchQueue.main.async {
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
            }
        }
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる。
        searchBar.endEditing(true)
    }
    
    //検索バーに入力があったら呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //検索情報の削除
        currentCategories.removeAll()
        selectNumber.removeAll()
        
        //入力内容が空かどうかの確認
        guard !searchText.isEmpty else {
            for i in 0..<categories.count {
                currentCategories.append("\(categories[i])")
            }
            for _ in 0..<currentCategories.count {
                selectNumber.append(0)
            }
            tableView.reloadData()
            return
        }
        
        //空でない場合、検索されたカテゴリー名を含む配列の作成
        for i in 0..<categories.count {
            if categories[i].contains("\(searchText)") {
                currentCategories.append("\(categories[i])")
            }
        }
        for _ in 0..<currentCategories.count {
            selectNumber.append(0)
        }
        tableView.reloadData()
    }
    
    //作成するセル数の指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.currentCategories.count
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
            return 90
        } else {
            return 70
        }
    }
    
    //セルの作成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
        //セルのテキスト作成
        cell.textLabel?.text = self.currentCategories[indexPath.section]
        cell.textLabel!.font = UIFont(name: "Arial", size: 22)
        
        //セルの色・影などの設定
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        cell.layer.addShadow(direction: .bottom)
        cell.selectedBackgroundView?.layer.cornerRadius = 10
        cell.selectedBackgroundView?.clipsToBounds = true
        
        return cell
    }
    
    //セルタップ時の呼び出しメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            //編集モード時
            numberOfRegistration += 1
            selectNumber[indexPath.section] += 1
            editButtonItem.title = "決定"
        } else {
            //編集モードでない場合
            wordVC.userDefaults.set(currentCategories[indexPath.section],forKey: "number")
            
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "Segue", sender: nil)
        }
    }
    
    //セルの選択解除時の呼び出しメソッド
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        numberOfRegistration -= 1
        selectNumber[indexPath.section] -= 1
        if numberOfRegistration == 0 {
            editButtonItem.title = "キャンセル"
        }
    }
    
    //アラートのテキストに入力があった場合呼ばれる
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        //アラートの保存を可能にする
        alert?.actions[1].isEnabled = sender.text!.count > 0
    }
    
    //ボタン押下時のパルスの作成
    @IBAction func pulse(_ sender: UIButton) {
        let pulse = PulseAnimation(numberOfPulses: 1, radius: addBtn.layer.cornerRadius*2.0, position: sender.center)
        pulse.animarionDuration = 1.0
        pulse.backgroundColor = UIColor.white.cgColor
        self.view.layer.insertSublayer(pulse, below: self.view.layer)
    }
    
    //addBtnボタン押下時に呼ばれるメソッド
    @IBAction func addBtn(_ sender: UIButton) {
        
        var alertTextField: UITextField?
        
        //アラートの作成
        alert = UIAlertController(
            title: "新規登録",
            message: "この項目の名称を入力してください。",
            preferredStyle: UIAlertController.Style.alert)
        
        alert?.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
                textField.placeholder = "名称"
                textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "保存", style: UIAlertAction.Style.default, handler: {
            (action:UIAlertAction!) -> Void in
            if let text = alertTextField?.text {
                for i in 0..<self.categories.count {
                    if text == self.categories[i] {
                        self.alert = UIAlertController(
                            title: "エラー",
                            message: "「\(text)」はすでに存在しています。",
                            preferredStyle: UIAlertController.Style.alert)
                        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
                        self.alert?.addAction(cancelAction)
                        self.present(self.alert!, animated: true, completion: nil)
                        break
                    } else if i == self.categories.count-1 {
                        self.categories.append("\(text)")
                        self.wordVC.userDefaults.set(self.categories,forKey: "categories")
                        self.loadView()
                        self.viewDidLoad()
                        self.viewWillAppear(true)
                    }
                }
            }
        })
        
        //アラートの保存をできなくする
        okAction.isEnabled = false
        
        alert?.addAction(cancelAction)
        alert?.addAction(okAction)
        
        self.present(alert!, animated: true, completion: nil)
    }
    
    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 削除のアクションを設定する
        let deleteAction = UIContextualAction(style: .destructive, title:"delete") {
            (ctxAction, view, completionHandler) in
            for i in 0..<self.categories.count {
                if self.categories[i] == self.currentCategories[indexPath.section] {
                    self.categories.remove(at: i)
                    break
                }
            }
            self.wordVC.userDefaults.set(self.empties,forKey: "\(self.currentCategories[indexPath.section])words")
            self.wordVC.userDefaults.set(self.empties,forKey: "\(self.currentCategories[indexPath.section])meanings")
            self.wordVC.userDefaults.set(self.empties,forKey: "\(self.currentCategories[indexPath.section])results")
            self.currentCategories.remove(at: indexPath.section)
            self.wordVC.userDefaults.set(self.categories,forKey: "categories")
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: UITableView.RowAnimation.left)
            self.viewDidLoad()
            self.viewWillAppear(true)
            completionHandler(true)
        }
        
        // 削除ボタンのデザインを設定する
        let trashImage = UIImage(systemName: "trash.fill")?.withTintColor(UIColor.white , renderingMode: .alwaysTemplate)
        deleteAction.image = trashImage
        deleteAction.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)

        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction])
        
        return swipeAction
    }
}

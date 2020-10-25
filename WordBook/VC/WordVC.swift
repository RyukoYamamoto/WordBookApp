//
//  WordViewController.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/08/26.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit

class WordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var studyBtn: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var userDefaults = UserDefaults.standard
    
    var words: [String] = []
    var meanings: [String] = []
    var results: [String] = []
    var missWords: [String] = []
    var missMeanings: [String] = []
    var missResults: [String] = []
    var random = false
    var startIndex = 0
    var category = ""
    var setBarButtonItem: UIBarButtonItem!
    var shuffleBarButtonItem: UIBarButtonItem!
    var alert: UIAlertController?
        
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 15
    
    //初回表示時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面のタイトル
        title = "ワード"
        
        //設定ボタンの作成
        setBarButtonItem = UIBarButtonItem(image: UIImage(named: "set.png")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(setBarButtonItemTapped(_:)))
        //シャッフルボタンの作成
        shuffleBarButtonItem = UIBarButtonItem(image: UIImage(named: "shuffle.png")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(shuffleBarButtonItemTapped(_:)))
        random = userDefaults.bool(forKey: "random")
        userDefaults.set(random,forKey: "random")
        if random {
            shuffleBarButtonItem.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        } else {
            shuffleBarButtonItem.tintColor = .gray
        }
        navigationItem.rightBarButtonItems = [setBarButtonItem, shuffleBarButtonItem]
        
        //配列の取得
        if UserDefaults.standard.object(forKey: "number") != nil {
            category = (userDefaults.string(forKey: "number") )!
        }
        if UserDefaults.standard.object(forKey: "\(category)words") != nil {
            words = userDefaults.array(forKey: "\(category)words") as! [String]
        }
        if UserDefaults.standard.object(forKey: "\(category)meanings") != nil {
            meanings = userDefaults.array(forKey: "\(category)meanings") as! [String]
        }
        if UserDefaults.standard.object(forKey: "\(category)results") != nil {
            results = userDefaults.array(forKey: "\(category)results") as! [String]
        }
        
        //配列の保存
        if segmentedControl.selectedSegmentIndex == 0 {
            userDefaults.set(words,forKey: "\(category)words")
            userDefaults.set(meanings,forKey: "\(category)meanings")
            userDefaults.set(results,forKey: "\(category)results")
        }
        
        //テーブルビューの保存・設定
        tableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        //タブバーの非表示
        tabBarController?.tabBar.isHidden = true
    }
    
    //ビュー表示時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let screenRect = UIScreen.main.bounds
        let horizonSizeClass = UITraitCollection(horizontalSizeClass: .regular)
        
        //セグメントコントロールを０番に戻す
        segmentedControl.selectedSegmentIndex = 0
        
        //addBtnの大きさの設定
        if traitCollection.containsTraits(in: horizonSizeClass) {
            addBtn.layer.cornerRadius = screenRect.width/24
        } else {
            addBtn.layer.cornerRadius = screenRect.width/17
        }
        //addBtnに影を追加
        addBtn.layer.addShadow(direction: .bottom)
        
        //studyBtnの角を丸に
        studyBtn.layer.cornerRadius = 5.0
        //studyBtnに影を追加
        studyBtn.layer.addShadow(direction: .bottom)
        
        //表示配列の取得
        if UserDefaults.standard.object(forKey: "\(category)words") != nil {
            words = userDefaults.array(forKey: "\(category)words") as! [String]
        }
        if UserDefaults.standard.object(forKey: "\(category)meanings") != nil {
            meanings = userDefaults.array(forKey: "\(category)meanings") as! [String]
        }
        if UserDefaults.standard.object(forKey: "\(category)results") != nil {
            results = userDefaults.array(forKey: "\(category)results") as! [String]
        }
        tableView.reloadData()
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
        guard heightForHeaderInSection != 0 else {
            return 0
        }
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection: Int) -> UIView?{
        let headerView = UIView()
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

        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResultCell
        
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
            }
            let orders = count.shuffled()
            for i in 0..<words.count {
                randomWords.append(words[orders[i]])
                randomMeanings.append(meanings[orders[i]])
                randomResults.append(results[orders[i]])
            }
            userDefaults.set(orders,forKey: "\(category)orders")
            userDefaults.set(randomWords,forKey: "\(category)randomWords")
            userDefaults.set(randomMeanings,forKey: "\(category)randomMeanings")
            userDefaults.set(randomResults,forKey: "\(category)randomResults")
        }
        
        //配列の保存
        userDefaults.set(segmentedControl.selectedSegmentIndex,forKey: "mode")
        userDefaults.set(words,forKey: "\(category)testWords")
        userDefaults.set(meanings,forKey: "\(category)testMeanings")
        userDefaults.set(results,forKey: "\(category)testResults")
        
        //ハイライトを消す
        tableView.deselectRow(at: indexPath, animated: true)
        userDefaults.set(indexPath.section,forKey: "\(category)startIndex")
        
        //テストビューへ遷移
        performSegue(withIdentifier: "Segue", sender: nil)
    }
    
    //設定ボタンタップ時の呼び出しメソッド
    @objc func setBarButtonItemTapped(_ sender: UIBarButtonItem){
        //設定画面へ遷移
        performSegue(withIdentifier: "Segue2", sender: nil)
    }
    
    //シャッフルボタンタップ時の呼び出しメソッド
    @objc func shuffleBarButtonItemTapped(_ sender: UIBarButtonItem){
        random.toggle()
        userDefaults.set(random, forKey: "random")
        if random {
            shuffleBarButtonItem.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        } else {
            shuffleBarButtonItem.tintColor = .gray
        }
    }
    
    //アラートのテキストに入力があった場合呼ばれる
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        //入力があればアラートの保存を可能にする
        if (self.alert?.textFields?.first?.text!.count)! > 0 && (self.alert?.textFields?.last?.text!.count)! > 0 {
            alert?.actions[1].isEnabled = true
        } else {alert?.actions[1].isEnabled = false}
    }
    
    //ボタン押下時のパルスの作成
    @IBAction func pulse(_ sender: UIButton) {
        let pulse = PulseAnimation(numberOfPulses: 1, radius: addBtn.layer.cornerRadius*2.0, position: sender.center)
        pulse.animarionDuration = 1.0
        pulse.backgroundColor = UIColor.white.cgColor
        self.view.layer.insertSublayer(pulse, below: self.view.layer)
    }
    
    //addBtnボタン押下時に呼ばれるメソッド
    @IBAction func addBtn(_ sender: Any) {
        
        var alertTextField: UITextField?
        var alertTextField2: UITextField?
        
        //アラートの作成
        alert = UIAlertController(
            title: "新規登録",
            message: "この単語の名称と意味を入力してください。",
            preferredStyle: UIAlertController.Style.alert)
        
        alert?.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
                textField.placeholder = "名称"
                textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        alert?.addTextField(
            configurationHandler: {(textField2: UITextField!) in
                alertTextField2 = textField2
                textField2.placeholder = "意味"
                textField2.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        
        let okAction
            = UIAlertAction(title: "保存" ,style: .default, handler: {
                (action:UIAlertAction!) -> Void in
                if let text = alertTextField?.text {
                        self.words.append("\(text)")
                        self.userDefaults.set(self.words,forKey: "\(self.category)words")
                    }
                    if let text2 = alertTextField2?.text {
                        self.meanings.append("\(text2)")
                        self.userDefaults.set(self.meanings,forKey: "\(self.category)meanings")
                    }
                        self.results.append("")
                        self.userDefaults.set(self.results,forKey: "\(self.category)results")
                        self.loadView()
                        self.viewDidLoad()
                        self.viewWillAppear(true)
            })
        //アラートの保存をできなくする
        okAction.isEnabled = false

        let cancelAction
            = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alert?.addAction(cancelAction)
        alert?.addAction(okAction)
        
        present(alert!, animated: true, completion: nil)
    }
    
    //SegmentedControl変更時に呼ばれるメソッド
    @IBAction func actionSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                //通常モード
                addBtn.isHidden = false
                viewDidLoad()
                tableView.reloadData()
            case 1:
                //復習モード
                addBtn.isHidden = true
                missWords.removeAll()
                missMeanings.removeAll()
                missResults.removeAll()
                for i in 0..<results.count {
                    if results[i] == "×" {
                        missWords.append(words[i])
                        missMeanings.append(meanings[i])
                        missResults.append(results[i])
                    }
                }
                words.removeAll()
                meanings.removeAll()
                results.removeAll()
                words = missWords
                meanings = missMeanings
                results = missResults
                tableView.reloadData()
            default:
                print("無し")
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
            }
            let orders = count.shuffled()
            for i in 0..<words.count {
                randomWords.append(words[orders[i]])
                randomMeanings.append(meanings[orders[i]])
                randomResults.append(results[orders[i]])
            }
            userDefaults.set(orders,forKey: "\(category)orders")
            userDefaults.set(randomWords,forKey: "\(category)randomWords")
            userDefaults.set(randomMeanings,forKey: "\(category)randomMeanings")
            userDefaults.set(randomResults,forKey: "\(category)randomResults")
        }
        
        //配列の保存
        userDefaults.set(segmentedControl.selectedSegmentIndex,forKey: "mode")
        userDefaults.set(words,forKey: "\(category)testWords")
        userDefaults.set(meanings,forKey: "\(category)testMeanings")
        userDefaults.set(results,forKey: "\(category)testResults")
        
        userDefaults.set(startIndex,forKey: "\(category)startIndex")
        
        //テストビューへ遷移
        performSegue(withIdentifier: "Segue", sender: nil)
    }
    
    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        // 削除のアクションを設定する
        let deleteAction = UIContextualAction(style: .destructive, title:"delete") {
            (ctxAction, view, completionHandler) in
            self.words.remove(at: indexPath.section)
            self.meanings.remove(at: indexPath.section)
            self.results.remove(at: indexPath.section)
            self.userDefaults.set(self.words,forKey: "\(self.category)words")
            self.userDefaults.set(self.meanings,forKey: "\(self.category)meanings")
            self.userDefaults.set(self.results,forKey: "\(self.category)results")
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

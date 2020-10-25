//
//  DownloadVC.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/09/27.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit
import NCMB
import MessageUI

class DownloadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
        
    var basedCategories: [String] = []
    var currentCategories: [String] = []
    var basedObjectId: [String] = []
    var currentObjectId: [String] = []
    var alert: UIAlertController?
    var reportBarButtonItem: UIBarButtonItem!
    var indicator = UIActivityIndicatorView()
    
    // 取得したデータを格納する配列
    var categories: Array<NCMBObject> = []
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 15
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let wordVC = WordViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面のタイトル
        title = "探す"
        
        //ナビゲーションバーの戻るボタンの非表示
        navigationItem.hidesBackButton = true
        //ナビゲーションバー右にボタン設置
        reportBarButtonItem = UIBarButtonItem(title: "通報", style: .plain, target: self, action: #selector(reportBarButtonItemTapped(_:)))
        navigationItem.rightBarButtonItem = reportBarButtonItem
        
        //テーブルビューの保存・設定
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        //何も入力されていなくてもReturnキーを押せるようにする。
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        
        //画面を引っ張って更新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    //ビュー表示時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // インジゲーターの設定
        indicator.center = view.center
        indicator.style = .large
        indicator.color = .gray
        view.addSubview(indicator)
        DispatchQueue.main.async {
            //インジケーターを表示
            self.indicator.startAnimating()
        }
        
        basedCategories.removeAll()
        currentCategories.removeAll()
        basedObjectId.removeAll()
        currentObjectId.removeAll()
        tableView.reloadData()
        
        //クエリの作成
        var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "TestClass")
        query.order = ["fieldA"]
        // データストアを検索
        query.findInBackground(callback: { result in
            switch result {
                case let .success(array):
                    // 検索に成功した場合の処理
                    print("検索に成功しました。")
                    DispatchQueue.main.async {
                        //インジケーターの停止
                        self.indicator.stopAnimating()
                        
                        // 取得したデータを格納
                        self.categories = array
                        for i in 0..<self.categories.count {
                            if let objectId : String = self.categories[i]["objectId"] {
                                self.basedObjectId.append("\(objectId)")
                                self.currentObjectId.append("\(objectId)")
                            }
                            if let fieldA : String = self.categories[i]["fieldA"] {
                                self.basedCategories.append("\(fieldA)")
                                self.currentCategories.append("\(fieldA)")
                            }
                        }
                        // テーブルビューをリロード
                        self.tableView.reloadData()
                    }
                case let .failure(error):
                    // 検索に失敗した場合の処理
                    print("検索に失敗しました。エラーコード：\(error)")
                    DispatchQueue.main.async {
                        //インジケーターの停止
                        self.indicator.stopAnimating()
                        
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
        tabBarController?.tabBar.isHidden = false
    }
    
    //メッセージの終了処理
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //ビューを下に引っ張って更新するメソッド
    @objc func refreshTable() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            self.basedCategories.removeAll()
            self.currentCategories.removeAll()
            self.basedObjectId.removeAll()
            self.currentObjectId.removeAll()
            self.viewWillAppear(true)
            self.tableView.reloadData()
        }
        tableView.refreshControl?.endRefreshing()
    }
    
    //通報ボタンタップ時の呼び出しメソッド
    @objc func reportBarButtonItemTapped(_ sender: UIBarButtonItem){
        //メール送信の確認
        if MFMailComposeViewController.canSendMail()==false {
            //アラートの表示
            alert = UIAlertController(
                title: "エラー",
                message: "メールの送信ができません。",
                preferredStyle: UIAlertController.Style.alert)

            let cancelAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alert?.addAction(cancelAction)

            present(self.alert!, animated: true, completion: nil)
            
            return
        }
        
        //メールビューの起動
        let mailViewController = MFMailComposeViewController()

        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("通報")
        mailViewController.setToRecipients(["yamaryukou@gmail.com"])//Toアドレス
        present(mailViewController, animated: true, completion: nil)
    }
    
    //メールを閉じる
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            switch result {
            case .cancelled:
                break
            case .saved:
                break
            case .sent:
                break
            case .failed:
                break
            default:
                break
            }
            controller.dismiss(animated: true, completion: nil)
        }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる。
        searchBar.endEditing(true)
    }
    
    //  検索バーに入力があったら呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        currentCategories.removeAll()
        currentObjectId.removeAll()
        
        //検索バーが空か確認
        guard !searchText.isEmpty else {
            for i in 0..<basedCategories.count {
                currentCategories.append("\(basedCategories[i])")
                currentObjectId.append("\(basedObjectId[i])")
            }
            tableView.reloadData()
            return
        }
        
        for i in 0..<basedCategories.count {
            if basedCategories[i].contains("\(searchText)") {
                currentCategories.append("\(basedCategories[i])")
                currentObjectId.append("\(basedObjectId[i])")
            }
        }
        tableView.reloadData()
    }
    
    //作成するセル数の指定
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentCategories.count
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
        cell.textLabel?.text = currentCategories[indexPath.section]

        //セルの色・影などの設定
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 10
        
        cell.layer.addShadow(direction: .bottom)
        cell.textLabel!.font = UIFont(name: "Arial", size: 22)
        cell.selectedBackgroundView?.layer.cornerRadius = 10
        cell.selectedBackgroundView?.clipsToBounds = true

        return cell
    }
    
    //セルタップ時の呼び出しメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // note that indexPath.section is used rather than indexPath.row
        wordVC.userDefaults.set(currentObjectId[indexPath.section],forKey: "objectId")
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "Segue", sender: nil)
    }
}

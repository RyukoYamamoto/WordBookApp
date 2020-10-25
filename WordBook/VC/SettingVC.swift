//
//  SettingVC.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/10/18.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var normalText: UITextField!
    @IBOutlet weak var missText: UITextField!
    
    let wordVC = WordViewController()
    
    var count: Int = 0
    var pickerView1: UIPickerView = UIPickerView()
    var pickerView2: UIPickerView = UIPickerView()
    var category = " "
    var objectId: String = " "
    var list: [String] = ["10", "20", "30", "40", "50", "100", "全て"]
    
    //初回表示時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画面のタイトル
        title = "出題設定"
        
        //pickerViewの設定
        pickerView1.tag = 0
        pickerView2.tag = 1
        
        pickerView1.delegate = self
        pickerView1.dataSource = self
        pickerView1.showsSelectionIndicator = true
        pickerView2.delegate = self
        pickerView2.dataSource = self
        pickerView2.showsSelectionIndicator = true

        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SettingViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        normalText.inputView = pickerView1
        normalText.inputAccessoryView = toolbar
        missText.inputView = pickerView2
        missText.inputAccessoryView = toolbar
    }
    
    //ビュー表示時に呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //配列の取得
        count = (self.navigationController?.viewControllers.count)! - 2
        if (self.navigationController?.viewControllers[count] as? WordViewController) != nil {
            category = (wordVC.userDefaults.string(forKey: "number") )!
        } else {
            objectId = wordVC.userDefaults.string(forKey: "objectId")!
        }
        
        //デフォルトのテキスト設定
        if (self.navigationController?.viewControllers[count] as? WordViewController) != nil {
            if UserDefaults.standard.object(forKey: "\(category)range") != nil {
                normalText.text = "\(list[wordVC.userDefaults.integer(forKey: "\(category)range")])問"
            } else {
                normalText.text = "全て"
            }
        } else {
            if UserDefaults.standard.object(forKey: "\(objectId)range") != nil {
                normalText.text = "\(list[wordVC.userDefaults.integer(forKey: "\(objectId)range")])問"
            } else {
                normalText.text = "全て"
            }
        }
        
        if UserDefaults.standard.object(forKey: "\(category)missRange") != nil {
            missText.text = "\(list[wordVC.userDefaults.integer(forKey: "\(category)missRange")])問"
        } else {
            missText.text = "全て"
        }
        
        // デフォルトの場所設定
        if (self.navigationController?.viewControllers[count] as? WordViewController) != nil {
            pickerView1.selectRow(wordVC.userDefaults.integer(forKey: "\(category)range"), inComponent: 0, animated: false)
            pickerView2.selectRow(wordVC.userDefaults.integer(forKey: "\(category)missRange"), inComponent: 0, animated: false)
        } else {
            pickerView1.selectRow(wordVC.userDefaults.integer(forKey: "\(objectId)range"), inComponent: 0, animated: false)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    //pickerが変わった時のメソッド
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            if row == 6 {
                normalText.text = "全て"
            } else {
                normalText.text = "\(list[row])問"
            }
            if (self.navigationController?.viewControllers[count] as? WordViewController) != nil {
                wordVC.userDefaults.set(row,forKey: "\(category)range")
            } else {
                wordVC.userDefaults.set(row,forKey: "\(objectId)range")
            }

        } else if pickerView.tag == 1 {
            if row == 6 {
                missText.text = "全て"
            } else {
                missText.text = "\(list[row])問"
            }
            if (self.navigationController?.viewControllers[count] as? WordViewController) != nil {
                wordVC.userDefaults.set(row,forKey: "\(category)missRange")
            }
        }
    }

    @objc func cancel() {
        normalText.text = "全て"
        normalText.endEditing(true)
        missText.text = "全て"
        missText.endEditing(true)
    }

    @objc func done() {
        normalText.endEditing(true)
        missText.endEditing(true)
    }

    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

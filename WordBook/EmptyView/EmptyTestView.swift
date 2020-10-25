//
//  EmptyTestView.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/08/27.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit

class EmptyTestView: UIView {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("EmptyTestView", owner: self, options: nil)?.first as? UIView
        view?.frame = self.bounds
        self.addSubview(view!)
    }
}

//
//  TouchEvent.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/09/16.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import Foundation
import UIKit

class CustomTableView: UITableView {
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEditing == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.reloadData()
            }
        }
        // touchesEndedを次のResponderへ
        super.touchesEnded(touches, with: event)
    }
}

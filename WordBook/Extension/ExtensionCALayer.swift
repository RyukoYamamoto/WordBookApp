//
//  ExtensionCALayer.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/08/24.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import Foundation
import UIKit

public extension CALayer {
    enum Direction {
        case top
        case bottom
    }

    func addShadow(direction: Direction){
        switch direction {
        case .top:
            self.shadowOffset = CGSize(width: 0.0, height: -1.5)
        case .bottom:
            self.shadowOffset = CGSize(width: 0.0, height: 1.5)
        }
        self.shadowRadius = 1.5
        self.shadowColor = UIColor.black.cgColor
        self.shadowOpacity = 0.5
    }
}

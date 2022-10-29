//
//  ViewExtension.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/30.
//

import Foundation
import UIKit

extension UIView {
    func addShadow() {
        // 影の方向（width=右方向、height=下方向、CGSize.zero=方向指定なし）
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        // 影の色
        layer.shadowColor = UIColor.black.cgColor
        // 影の濃さ
        layer.shadowOpacity = 0.5
        // 影をぼかし
        layer.shadowRadius = 4
    }
}

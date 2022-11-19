//
//  LabelExtension.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/05.
//

import Foundation
import UIKit
import CoreLocation

extension UILabel {
    func setLocationText(location: CLLocationCoordinate2D) {
        self.text = "lon: \(location.longitude) \nlat: \(location.latitude)"
    }

    func setLocationText(memo: Memo) {
        self.text = "lon: \(memo.longitude) \nlat: \(memo.latitude)"
    }
}

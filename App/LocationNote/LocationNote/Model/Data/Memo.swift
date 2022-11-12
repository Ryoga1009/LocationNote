//
//  Memo.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/12.
//

import Foundation
import CoreLocation

struct Memo: Codable {

    let title: String
    let detail: String
    let tag: String
    let latitude: Double
    let longitude: Double
}

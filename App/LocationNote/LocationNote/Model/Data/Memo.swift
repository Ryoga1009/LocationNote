//
//  Memo.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/12.
//

import Foundation
import CoreLocation

// データ保存用のメモクラス
// CLLocationCoordinate2DがCodableに対応していないためlat/lonをDoubleで保持
struct Memo: Codable {
    var title: String
    var detail: String
    let latitude: Double
    let longitude: Double
    var isSendNotice: Bool
    var lastNoticeDate: Date = Date()
    // １回目の通知を出しているかどうか(登録後は時間に関わらず出すように)
    var didsendFirstNotice: Bool = false
}

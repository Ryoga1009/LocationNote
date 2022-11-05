//
//  LocationModel.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/05.
//

import Foundation
import RxSwift
import CoreLocation

struct LocationModel {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

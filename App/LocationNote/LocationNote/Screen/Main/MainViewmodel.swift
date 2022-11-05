//
//  MainViewmodel.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/05.
//

import Foundation
import RxSwift
import CoreLocation

final class MainViewModel {

    private var disposeBag = DisposeBag()

    func onLocationButtonTapped() {

    }

    func onLocationUpdated(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        print("\(lat)  \(lon)")
    }
}

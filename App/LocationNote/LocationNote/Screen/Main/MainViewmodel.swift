//
//  MainViewmodel.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/05.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

final class MainViewModel {

    private var locationDriver = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    var locationObservable: Observable<CLLocationCoordinate2D?> {
        return locationDriver.asObservable()
    }

    func onLocationButtonTapped(location: CLLocationCoordinate2D) {
        locationDriver.accept(location)
    }

}

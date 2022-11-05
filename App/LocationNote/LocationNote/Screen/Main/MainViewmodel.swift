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

    private var disposeBag = DisposeBag()

    private var locationDriver = BehaviorRelay<LocationModel?>(value: nil)
    var locationObservable: Observable<LocationModel?> {
        return locationDriver.asObservable()
    }

    func onLocationUpdated(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        locationDriver.accept(LocationModel.init(latitude: lat, longitude: lon))
    }
}

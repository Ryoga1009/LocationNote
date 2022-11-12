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
    private let dataStore = DataStore()
    private let disposeBag = DisposeBag()

    // Input

    // Output
    private let _memoListDriver = BehaviorRelay<[Memo]>(value: [])
    var memoListObservable: Observable<[Memo]> {
        _memoListDriver.asObservable()
    }

    private var locationDriver = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    var locationObservable: Observable<CLLocationCoordinate2D?> {
        return locationDriver.asObservable()
    }

    func onLocationButtonTapped(location: CLLocationCoordinate2D) {
        locationDriver.accept(location)
    }

    func viewDidAppear(location: CLLocationCoordinate2D) {
        if location.latitude != 0 || location.longitude != 0 {
            locationDriver.accept(location)
        }

        loadMapPinList()
    }

    func onPresentationControllerDidDismiss() {
        loadMapPinList()
    }

   private func loadMapPinList() {
        _memoListDriver.accept(dataStore.loadMemo() ?? [])
    }
}

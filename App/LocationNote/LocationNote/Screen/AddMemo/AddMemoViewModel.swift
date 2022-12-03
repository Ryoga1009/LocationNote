//
//  AddMemoViewModel.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/05.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation

final class AddMemoViewModel {

    private var location: CLLocationCoordinate2D

    // Input
    private let _title = BehaviorSubject<String>(value: "")
    var title: AnyObserver<String> {
        _title.asObserver()
    }

    private let _detail = BehaviorSubject<String>(value: "")
    var detail: AnyObserver<String> {
        _detail.asObserver()
    }

    private let _isSendNotice = BehaviorSubject<Bool>(value: true)
    var isSendNotice: AnyObserver<Bool> {
        _isSendNotice.asObserver()
    }

    let isAdAllReady = PublishRelay<Bool>()

    private var adCount: Int {
        dataStore.loadCount()
    }

    // OutPut
    private let _buttonEnabled = BehaviorRelay<Bool>(value: false)
    var buttonEnabled: Observable<Bool> {
        return Observable.combineLatest(_title, isAdAllReady) { title, isAdAllReady in
            return !title.isEmpty  && isAdAllReady
        }
    }

    private let disposeBag = DisposeBag()
    private let dataStore = DataStore()

    init(location: CLLocationCoordinate2D) {
        self.location = location
    }
}

extension AddMemoViewModel {
    func isNeedShowAd() -> Bool {
        if adCount == 0 {
            dataStore.saveCount(count: adCount + 1)
            return true
        } else {
            let next = adCount + 1
            if adCount >= 2 {
                dataStore.saveCount(count: 0)
            } else {
                dataStore.saveCount(count: next)
            }
            return false
        }
    }

    func onAddButtonTapped() {
        guard let title = try? _title.value(), let detail = try? _detail.value(), let isSendNotice = try? _isSendNotice.value() else {
            return
        }

        let memo = Memo.init(title: title, detail: detail, latitude: location.latitude, longitude: location.longitude, isSendNotice: isSendNotice)

        dataStore.saveMmemo(memo: memo)
    }
}

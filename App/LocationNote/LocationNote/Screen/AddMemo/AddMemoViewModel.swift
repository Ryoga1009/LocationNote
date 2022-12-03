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

    private var _isAdLoaded = false

    // OutPut
    private let _buttonEnabled = BehaviorRelay<Bool>(value: false)
    var buttonEnabled: Driver<Bool> {
        _buttonEnabled.asDriver()
    }

    private let disposeBag = DisposeBag()
    private let dataStore = DataStore()

    init(location: CLLocationCoordinate2D) {
        self.location = location

        _title.asObserver()
            .map({!$0.isEmpty && self._isAdLoaded})
            .bind(to: _buttonEnabled)
            .disposed(by: disposeBag)
    }
}

extension AddMemoViewModel {
    func onAddButtonTapped() {
        guard let title = try? _title.value(), let detail = try? _detail.value(), let isSendNotice = try? _isSendNotice.value() else {
            return
        }

        let memo = Memo.init(title: title, detail: detail, latitude: location.latitude, longitude: location.longitude, isSendNotice: isSendNotice)

        dataStore.saveMmemo(memo: memo)
    }

    func onAdLoadEnd() {
        self._isAdLoaded = true
    }
}

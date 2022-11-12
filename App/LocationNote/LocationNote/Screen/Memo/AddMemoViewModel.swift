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

    private let _tag = BehaviorSubject<String>(value: "")
    var tag: AnyObserver<String> {
        _tag.asObserver()
    }

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
            .map({!$0.isEmpty})
            .bind(to: _buttonEnabled)
            .disposed(by: disposeBag)
    }
}

extension AddMemoViewModel {
    func onAddButtonTapped() {
        guard let title = try? _title.value(), let detail = try? _detail.value(), let tag = try? _tag.value() else {
            return
        }

        let memo = Memo.init(title: title, detail: detail, tag: tag, latitude: location.latitude, longitude: location.longitude)

        dataStore.saveMmemo(memo: memo)
    }
}

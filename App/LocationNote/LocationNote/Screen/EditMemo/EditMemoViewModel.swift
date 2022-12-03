//
//  EditMemoViewModel.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/20.
//

import Foundation
import RxSwift
import RxCocoa

final class EditMemoViewModel {
    private var memo: Memo
    private var adCount: Int {
        dataStore.loadCount()
    }

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

    // OutPut
    private let _buttonEnabled = BehaviorRelay<Bool>(value: false)
    var buttonEnabled: Observable<Bool> {
        return Observable.combineLatest(_title, isAdAllReady) { title, isAdAllReady in
            return !title.isEmpty  && isAdAllReady
        }
    }

    private let disposeBag = DisposeBag()
    private let dataStore = DataStore()

    init(memo: Memo) {
        self.memo = memo
    }
}

extension EditMemoViewModel {
    func isNeedShowAd() -> Bool {
        print(adCount)
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

    func createMemo() -> Memo? {
        guard let title = try? _title.value(), let detail = try? _detail.value(), let isSendNotice = try? _isSendNotice.value() else {
            return nil
        }

        return Memo.init(title: title, detail: detail, latitude: memo.latitude, longitude: memo.longitude, isSendNotice: isSendNotice)
    }

    func onDeleteButtonTapped() {
        guard let memo = createMemo() else {
            return
        }
        dataStore.deleteMemo(memo: memo)
    }

    func onEditButtonTapped() {
        guard let memo = createMemo() else {
            return
        }
        dataStore.editMemo(memo: memo)
    }
}

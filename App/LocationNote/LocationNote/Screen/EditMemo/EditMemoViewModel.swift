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

    // Input
    private let _title = BehaviorSubject<String>(value: "")
    var title: AnyObserver<String> {
        _title.asObserver()
    }

    private let _detail = BehaviorSubject<String>(value: "")
    var detail: AnyObserver<String> {
        _detail.asObserver()
    }

    // OutPut
    private let _buttonEnabled = BehaviorRelay<Bool>(value: false)
    var buttonEnabled: Driver<Bool> {
        _buttonEnabled.asDriver()
    }

    private let disposeBag = DisposeBag()
    private let dataStore = DataStore()

    init(memo: Memo) {
        self.memo = memo

        _title.asObserver()
            .map({!$0.isEmpty})
            .bind(to: _buttonEnabled)
            .disposed(by: disposeBag)
    }
}

extension EditMemoViewModel {
    func createMemo() -> Memo? {
        guard let title = try? _title.value(), let detail = try? _detail.value() else {
            return nil
        }

        return Memo.init(title: title, detail: detail, latitude: memo.latitude, longitude: memo.longitude)
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

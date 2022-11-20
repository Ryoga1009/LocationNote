//
//  EditMemoViewModel.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/20.
//

import Foundation

final class EditMemoViewModel {
    private let dataStore = DataStore()

    func onDeleteButtonTapped(memo: Memo) {
        dataStore.deleteMemo(memo: memo)
    }
}

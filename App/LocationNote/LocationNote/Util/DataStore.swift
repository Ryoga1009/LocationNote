//
//  DataStore.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/12.
//

import Foundation

enum DataStoreKey: String {
    case MEMO = "Memo"
}

struct DataStore {
    func saveMmemo(memo: Memo) {
        var memoList: [Memo] = loadMemo() ?? []
        memoList.append(memo)

        guard let memoList = try? JSONEncoder().encode(memoList) else { return }
        UserDefaults.standard.set(memoList, forKey: DataStoreKey.MEMO.rawValue)
    }

    func loadMemo() -> [Memo]? {
        if let data = UserDefaults.standard.data(forKey: DataStoreKey.MEMO.rawValue) {
            return try? JSONDecoder().decode([Memo].self, from: data)
        }
        return nil
    }
}

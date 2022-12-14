//
//  DataStore.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/12.
//

import Foundation
import MapKit

enum DataStoreKey: String {
    case MEMO = "Memo"
    case AD_COUNT = "AdCount"
}

struct DataStore {
    func saveMmemo(memo: Memo) {
        var memoList: [Memo] = loadMemo() ?? []
        memoList.append(memo)

        guard let memoList = try? JSONEncoder().encode(memoList) else { return }
        UserDefaults.standard.set(memoList, forKey: DataStoreKey.MEMO.rawValue)
    }

    func saveMmemoList(memoList: [Memo]) {
       clearMemo()
        guard let memoList = try? JSONEncoder().encode(memoList) else { return }
        UserDefaults.standard.set(memoList, forKey: DataStoreKey.MEMO.rawValue)
    }

    func editMemo(memo: Memo) {
        var data = loadMemo()
        if data?.count == 0 {
            return
        }
        guard let index = data?.firstIndex(where: {$0.latitude.isEqual(to: memo.latitude) && $0.longitude.isEqual(to: memo.longitude)
        }) else {
            return
        }

        data?[index].title = memo.title
        data?[index].detail = memo.detail
        data?[index].isSendNotice = memo.isSendNotice
        data?[index].lastNoticeDate = memo.lastNoticeDate

        saveMmemoList(memoList: data ?? [])
    }

    func loadMemo() -> [Memo]? {
        if let data = UserDefaults.standard.data(forKey: DataStoreKey.MEMO.rawValue) {
            return try? JSONDecoder().decode([Memo].self, from: data)
        }
        return []
    }

    func loadMemo(from: MKPointAnnotation) -> Memo? {
        var matchedMemo: Memo?
        guard let data = loadMemo() else {
            return nil
        }

        data.forEach { memo in
            if memo.latitude == from.coordinate.latitude && memo.longitude == from.coordinate.longitude {
                matchedMemo = memo
            }
        }
        return matchedMemo
    }

    func deleteMemo(memo: Memo) {
        var data = loadMemo()
        if data?.count == 0 {
            return
        }

        guard let index = data?.firstIndex(where: {$0.latitude.isEqual(to: memo.latitude) && $0.longitude.isEqual(to: memo.longitude)
        }) else {
            return
        }

        data?.remove(at: index)

        saveMmemoList(memoList: data ?? [])
    }

    func clearMemo() {
        UserDefaults.standard.set([], forKey: DataStoreKey.MEMO.rawValue)
    }
}

// MARK: show AD count
extension DataStore {
    func saveCount(count: Int) {
        UserDefaults.standard.set(count, forKey: DataStoreKey.AD_COUNT.rawValue)
    }

    func loadCount() -> Int {
        return UserDefaults.standard.integer(forKey: DataStoreKey.AD_COUNT.rawValue)
    }
}

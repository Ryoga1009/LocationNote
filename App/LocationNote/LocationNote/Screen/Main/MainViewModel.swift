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
import MapKit

final class MainViewModel {
    private let dataStore = DataStore()
    private let disposeBag = DisposeBag()
    // ピントとの距離が近いと判定する範囲
    static let DETERMINE_AREA: Double = 80.0

    // Input

    // Output
    private let _memoListDriver = BehaviorRelay<[MKPointAnnotation]>(value: [])
    var memoListObservable: Observable<[MKPointAnnotation]> {
        _memoListDriver.asObservable()
    }

    private var locationDriver = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    var locationObservable: Observable<CLLocationCoordinate2D?> {
        return locationDriver.asObservable()
    }

    private var _editMemoDriver = BehaviorRelay<Memo?>(value: nil)
    var editMemoObservable: Observable<Memo?> {
        _editMemoDriver.asObservable()
    }

    private var _notificationRequestDriver = BehaviorRelay<UNNotificationRequest?>(value: nil)
    var notificationRequestObservable: Observable<UNNotificationRequest?> {
        _notificationRequestDriver.asObservable()
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
       var annotationArray: [MKPointAnnotation] = []
       let savedMemoList = dataStore.loadMemo() ?? []

       savedMemoList.forEach { memo in
           let annotation = MKPointAnnotation()
           annotation.coordinate = CLLocationCoordinate2DMake(memo.latitude, memo.longitude)

           annotation.title = memo.title

           // タグがある場合はセパレータをつけて合体させる
           annotation.subtitle = memo.detail  + Memo.SEPARATOR + memo.tag

           annotationArray.append(annotation)
       }

       _memoListDriver.accept(annotationArray)
    }

    func onCalloutAccessoryTapped(annotation: MKAnnotation) {
        var memo: Memo
        let detailTagArray = annotation.subtitle??.components(separatedBy: Memo.SEPARATOR)

        memo = Memo(title: (annotation.title ?? "") ?? "", detail: detailTagArray?[0] ?? "", tag: detailTagArray?[1] ?? "", latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)

        _editMemoDriver.accept(memo)
    }

    // 近いピンがあるか判定を行う
    func didUpdateLocations(location: CLLocationCoordinate2D) {
        if _memoListDriver.value.isEmpty {
            return
        }

        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        _memoListDriver.value.forEach { pin in
            let pinLocation = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
            let distance = clLocation.distance(from: pinLocation)

            if distance < MainViewModel.DETERMINE_AREA {
               onDeterminedArea(pin: pin)
            }
        }
    }

    private func onDeterminedArea(pin: MKPointAnnotation) {
        guard var memo = dataStore.loadMemo(from: pin) else {
            return
        }
        // 最後に通知を出したのが12時間前であれば通知を出す
        if Date().compare(Calendar.current.date(byAdding: .hour, value: 12, to: memo.lastNoticeDate)!) == ComparisonResult.orderedDescending {
            createUserNotificationRequest(memo: memo)
            // 最終通知表示時間を更新
            memo.lastNoticeDate = Date()
            dataStore.editMemo(memo: memo)
        }
    }

     private func createUserNotificationRequest(memo: Memo) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = memo.title
         notificationContent.body = String(describing: "\(memo.detail) \(memo.tag)")
        notificationContent.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: "LocationNote", content: notificationContent, trigger: nil)

        _notificationRequestDriver.accept(request)
    }
}

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

    // Input

    // Output
    private let _memoListDriver = BehaviorRelay<[MKAnnotation]>(value: [])
    var memoListObservable: Observable<[MKAnnotation]> {
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
       var annotationArray: [MKAnnotation] = []
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
}

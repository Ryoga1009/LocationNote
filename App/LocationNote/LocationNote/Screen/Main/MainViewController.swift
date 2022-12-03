//
//  ViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/24.
//

import UIKit
import RxSwift
import MapKit
import GoogleMobileAds

class MainViewController: BaseViewController {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var locateButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var bannerView: GADBannerView!

    private var mainViewmodel = MainViewModel()
    private var locationManager = CLLocationManager()
    private var showingAnnotationList: [MKPointAnnotation] = []
    private let disposeBag = DisposeBag()

    static func initFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.main.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! MainViewController

        return viewController
    }

// MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        locateButton.addShadow()
        addButton.addShadow()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.checkLocationPermission()
        }

        bind()
        setMapLongPressRecRecognizer()
        setBannerAdSetting()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainViewmodel.viewDidAppear(location: self.mapView.userLocation.coordinate)
    }

    @IBAction func onLocateButtonTapped(_ sender: Any) {
        if self.mapView.userLocation.coordinate.longitude != -180 && self.mapView.userLocation.coordinate.latitude != -180 {
            mainViewmodel.onLocationButtonTapped(location: self.mapView.userLocation.coordinate)
        } else {
            showAleart(title: "読み込みエラー", subtitle: "マップの読み込みに失敗しました。\nアプリを再起動してください。", confirmButtonTitle: "OK", onConfirm: {})
        }
    }

    @IBAction func onAddButtonTapped(_ sender: Any) {
        navigateToAddMemoScreen(location: self.mapView.userLocation.coordinate)
    }
}

// MARK: Methods
extension MainViewController {
    func bind() {
        mainViewmodel.locationObservable.bind(onNext: { location in
            guard let location = location else {
                return
            }

            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location, span: span)
            self.mapView.region = region
        }).disposed(by: disposeBag)

        mainViewmodel.memoListObservable.bind(onNext: { memoList in
            self.addPin(mapPinList: memoList)
            self.showingAnnotationList = memoList
        }).disposed(by: disposeBag)

        mainViewmodel.editMemoObservable.bind(onNext: { memo in
            guard let memo: Memo = memo else {
                return
            }
            self.navigateToEditMemoScreen(memo: memo)
        }).disposed(by: disposeBag)

        mainViewmodel.notificationRequestObservable.bind(onNext: { request in
            guard let request = request else {
                return
            }
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }).disposed(by: disposeBag)
    }

    func setBannerAdSetting() {
        bannerView.delegate = self

        let adUnitId = Bundle.main.infoDictionary?["BannerAdUnitId"]! as! String
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }

    func checkLocationPermission() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // 距離10mごとに位置の変更を通知
        locationManager.distanceFilter = 10

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
        case .restricted:
            print("権限なし")
        case .denied:
            print("権限なし")
        @unknown default:
            print("権限なし")
        }

    }

    func setMapLongPressRecRecognizer() {
        let longPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(self.recognizeLongPress(sender:)))

        mapView.addGestureRecognizer(longPressRecognizer)
    }

    @objc func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        // 長押しの最中に何度もピンを生成しないようにする.
        if sender.state != UIGestureRecognizer.State.began {
            return
        }

        let location = sender.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)

        navigateToAddMemoScreen(location: coordinate)
    }

    func addPin(mapPinList: [MKAnnotation]) {
        mapView.removeAnnotations(showingAnnotationList)
        mapPinList.forEach({ pin in
            mapView.addAnnotation(pin)
        })
    }

    func navigateToAddMemoScreen(location: CLLocationCoordinate2D) {
        let nextView = AddMemoViewController.initFromStoryboard(location: location, parent: self)
        self.modalViewController(nextView, animated: true)
    }

    func navigateToEditMemoScreen(memo: Memo) {
        let nextView = EditMemoViewController.initFromStoryboard(memo: memo, parent: self)
        self.modalViewController(nextView, animated: true)
    }

}

// MARK: MKMapViewDelegate
extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation as? MKUserLocation != mapView.userLocation else { return nil }

        let pinIdentifier = "PinAnnotationIdentifier"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)

        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.annotation = annotation

        return pinView
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mainViewmodel.onCalloutAccessoryTapped(annotation: view.annotation!)
    }
}

// MARK: UIAdaptivePresentationControllerDelegate
extension MainViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.mainViewmodel.onPresentationControllerDidDismiss()
    }
}

// MARK: CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let horizontalAccuracy = self.mapView.userLocation.location?.horizontalAccuracy
        if horizontalAccuracy != nil && horizontalAccuracy! >= 0 {
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")

            mainViewmodel.didUpdateLocations(location: locValue)
        }

    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if status == .authorizedAlways {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: GADBannerViewDelegate
extension MainViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      bannerView.alpha = 0
      UIView.animate(withDuration: 1, animations: {
        bannerView.alpha = 1
      })
    }
}

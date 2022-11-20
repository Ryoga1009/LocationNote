//
//  ViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/24.
//

import UIKit
import RxSwift
import MapKit

class MainViewController: BaseViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    private var mainViewmodel = MainViewModel()
    private let disposeBag = DisposeBag()
    private var locationManager = CLLocationManager()
    private var showingAnnotationList: [MKPointAnnotation] = []

    static func initFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.main.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! MainViewController

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        locateButton.addShadow()
        addButton.addShadow()

        checkLocationPermission()
        bind()
        setMapLongPressRecRecognizer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainViewmodel.viewDidAppear(location: self.mapView.userLocation.coordinate)
    }

    @IBAction func onLocateButtonTapped(_ sender: Any) {
        mainViewmodel.onLocationButtonTapped(location: self.mapView.userLocation.coordinate)
    }

    @IBAction func onAddButtonTapped(_ sender: Any) {
        navigateToAddMemoScreen(location: self.mapView.userLocation.coordinate)
    }
}

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
    }

    func checkLocationPermission() {
        let status = locationManager.authorizationStatus
        if status == CLAuthorizationStatus.notDetermined {
            locationManager.requestWhenInUseAuthorization()
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

extension MainViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.mainViewmodel.onPresentationControllerDidDismiss()
    }
}

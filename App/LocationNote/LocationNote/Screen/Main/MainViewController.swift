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

    static func initFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.main.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! MainViewController

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        locateButton.addShadow()
        addButton.addShadow()

        bind()
        setMapLongPressRecRecognizer()
    }

    @IBAction func onLocateButtonTapped(_ sender: Any) {
        mainViewmodel.onLocationButtonTapped(location: self.mapView.userLocation.coordinate)
    }

    @IBAction func onAddButtonTapped(_ sender: Any) {
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

        addPin(location: coordinate)
    }

    func addPin(location: CLLocationCoordinate2D) {
        let pin: MKPointAnnotation = MKPointAnnotation()

        pin.coordinate = location
        pin.title = "タイトル"
        pin.subtitle = "サブタイトル"

        mapView.addAnnotation(pin)
    }

}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let pinIdentifier = "PinAnnotationIdentifier"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)

        pinView.animatesDrop = true
        pinView.canShowCallout = true
        pinView.annotation = annotation

        return pinView
    }
}

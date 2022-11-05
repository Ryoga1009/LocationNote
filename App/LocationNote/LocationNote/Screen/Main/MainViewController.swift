//
//  ViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/24.
//

import UIKit
import RxSwift
import CoreLocation

class MainViewController: BaseViewController {

    @IBOutlet weak var searchBar: SearchBar!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    private var mainViewmodel = MainViewModel()
    private let disposeBag = DisposeBag()
    private let locationManager = CLLocationManager()

    private var isStarted = false

    static func initFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.main.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! MainViewController

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        locateButton.addShadow()
        addButton.addShadow()

        bind()
    }

    @IBAction func onLocateButtonTapped(_ sender: Any) {
        locationManager.requestLocation()
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

            print(location)
        }).disposed(by: disposeBag)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let loc = locations.last else { return }

        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(_, error) in

            if let error = error {
                print("reverseGeocodeLocation Failed: \(error.localizedDescription)")
                return
            }

            self.mainViewmodel.onLocationUpdated(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
        })
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}

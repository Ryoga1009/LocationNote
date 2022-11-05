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
}

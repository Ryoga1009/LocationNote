//
//  AddMemoViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/05.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import GoogleMobileAds

class AddMemoViewController: BaseViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addButton: PrimaryButton!

    private var closeButtonItem: UIBarButtonItem!
    private var addMemoViewModel: AddMemoViewModel?
    private var location: CLLocationCoordinate2D?
    private var interstitial: GADInterstitialAd?

    private let disposeBag = DisposeBag()

    static func initFromStoryboard(location: CLLocationCoordinate2D, parent: UIAdaptivePresentationControllerDelegate) -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.addMemoViewController.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! AddMemoViewController
        viewController.location = location
        viewController.presentationController?.delegate = parent

        return NavigationViewController.init(rootViewController: viewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = GADRequest()
        let adUnitId = Bundle.main.infoDictionary?["AdUnitId"]! as! String
        GADInterstitialAd.load(withAdUnitID: adUnitId, request: request, completionHandler: { [self] ad, error in
            addMemoViewModel?.onAdLoadEnd()

            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        })

        title = "メモ追加"

        closeButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTapped(_:)))
        closeButtonItem.tintColor = R.color.white1()
        self.navigationItem.rightBarButtonItem = closeButtonItem

        addMemoViewModel = AddMemoViewModel.init(location: self.location!)

        setLayout()
        bind()
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        super.dismiss(animated: flag, completion: completion)
    }

}

extension AddMemoViewController {
    @objc func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    func setLayout() {
        guard let location = self.location else {
            return
        }

        locationLabel.setLocationText(location: location)

        titleTextField.layer.borderColor = R.color.white2()?.cgColor
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.cornerRadius = 4

        detailTextView.layer.borderWidth = 1
        detailTextView.layer.borderColor = R.color.white2()?.cgColor
        detailTextView.layer.cornerRadius = 4
    }

    func bind() {
        guard let addMemoViewModel = self.addMemoViewModel else {
            return
        }

        titleTextField.rx.text.orEmpty
            .asDriver()
            .drive(addMemoViewModel.title)
            .disposed(by: disposeBag)

        detailTextView.rx.text.orEmpty
            .asDriver()
            .drive(addMemoViewModel.detail)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .asDriver()
            .drive(onNext: {
                if let interstitial = self.interstitial {
                    // 広告表示
                    interstitial.present(fromRootViewController: self)
                }else{
                    // 広告が読み込まれなければ通常の動作に
                    self.addMemoViewModel?.onAddButtonTapped()
                    self.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)

        addMemoViewModel.buttonEnabled
            .drive(addButton.rx.isEnabled)
            .disposed(by: disposeBag)

    }
}

extension AddMemoViewController: GADFullScreenContentDelegate {

    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.addMemoViewModel?.onAddButtonTapped()
        self.dismiss(animated: true)
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.addMemoViewModel?.onAddButtonTapped()
        self.dismiss(animated: true)
    }
}

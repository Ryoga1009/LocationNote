//
//  EditMemoViewController.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/20.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import GoogleMobileAds

// MARK: LifeCycle
class EditMemoViewController: BaseViewController {
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var detailTextView: UITextView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var editButton: PrimaryButton!
    @IBOutlet private weak var noticeSwitch: UISwitch!
    private var interstitial: GADInterstitialAd?

    private var memo: Memo?

    private var viewModel: EditMemoViewModel?
    private let disposeBag = DisposeBag()

    static func initFromStoryboard(memo: Memo, parent: UIAdaptivePresentationControllerDelegate) -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.editMemoViewController.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! EditMemoViewController

        viewController.memo = memo
        viewController.presentationController?.delegate = parent

        return NavigationViewController.init(rootViewController: viewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = EditMemoViewModel(memo: self.memo!)

        let request = GADRequest()
        let adUnitId = Bundle.main.infoDictionary?["AdUnitId"]! as! String
        GADInterstitialAd.load(withAdUnitID: adUnitId, request: request,
            completionHandler: { [self] ad, error in
            viewModel?.isAdAllReady.accept(true)

            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        })
        title = "編集"

        setNavigationBarItem()
        setLayout()
        bind()
    }
}

// MARK: Layout
extension EditMemoViewController {

    func setNavigationBarItem() {
        let closeButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTapped(_:)))
        closeButtonItem.tintColor = R.color.white1()
        self.navigationItem.rightBarButtonItem = closeButtonItem

        let deleteButtonItem = UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(deleteButtonTapped(_:)))
        deleteButtonItem.tintColor = R.color.red1()
        self.navigationItem.leftBarButtonItem = deleteButtonItem
    }

    func setLayout() {
        locationLabel.setLocationText(memo: self.memo!)

        titleTextField.layer.borderColor = R.color.white2()?.cgColor
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.cornerRadius = 4
        titleTextField.text = memo?.title

        detailTextView.layer.borderWidth = 1
        detailTextView.layer.borderColor = R.color.white2()?.cgColor
        detailTextView.layer.cornerRadius = 4
        detailTextView.text = memo?.detail

        noticeSwitch.isOn = memo?.isSendNotice ?? true
    }
}

// MARK: Navigation View Button
extension EditMemoViewController {

    @objc func closeButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }

    @objc func deleteButtonTapped(_ sender: UIBarButtonItem) {
        self.showAleart(title: "このメモを削除しますか？", subtitle: nil, confirmButtonTitle: "削除", onConfirm: {
            self.viewModel?.onDeleteButtonTapped()
            self.dismiss(animated: true)
        })
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
        super.dismiss(animated: flag, completion: completion)
    }
}

extension EditMemoViewController {
    func bind() {
        guard let viewModel = self.viewModel else {
            return
        }

        titleTextField.rx.text.orEmpty
            .asDriver()
            .drive(viewModel.title)
            .disposed(by: disposeBag)

        detailTextView.rx.text.orEmpty
            .asDriver()
            .drive(viewModel.detail)
            .disposed(by: disposeBag)

        noticeSwitch.rx.value
            .asDriver()
            .drive(viewModel.isSendNotice)
            .disposed(by: disposeBag)

        editButton.rx.tap
            .asDriver()
            .drive(onNext: {
                if let interstitial = self.interstitial, viewModel.isNeedShowAd() {
                    // 広告表示
                    interstitial.present(fromRootViewController: self)
                } else {
                    // 広告が読み込まれなければ通常の動作に
                    self.viewModel?.onEditButtonTapped()
                    self.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)

        viewModel.buttonEnabled
            .bind(to: editButton.rx.isEnabled)
            .disposed(by: disposeBag)

    }
}

extension EditMemoViewController: GADFullScreenContentDelegate {

    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.viewModel?.onEditButtonTapped()
        self.dismiss(animated: true)
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.viewModel?.onEditButtonTapped()
        self.dismiss(animated: true)
    }
}

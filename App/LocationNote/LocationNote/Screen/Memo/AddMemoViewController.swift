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

class AddMemoViewController: BaseViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextField: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addButton: PrimaryButton!

    private var closeButtonItem: UIBarButtonItem!

    private var addMemoViewModel = AddMemoViewModel()
    private var location: CLLocationCoordinate2D?

    private let disposeBag = DisposeBag()

    static func initFromStoryboard(location: CLLocationCoordinate2D) -> UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.addMemo.name, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! AddMemoViewController
        viewController.location = location

        return NavigationViewController.init(rootViewController: viewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "メモ追加"

        closeButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTapped(_:)))
        closeButtonItem.tintColor = R.color.white1()
        self.navigationItem.rightBarButtonItem = closeButtonItem

        setLayout()
        bind()
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
    }

    func bind() {
        titleTextField.rx.text.orEmpty
            .asDriver()
            .drive(addMemoViewModel.title)
            .disposed(by: disposeBag)

        detailTextField.rx.text.orEmpty
            .asDriver()
            .drive(addMemoViewModel.detail)
            .disposed(by: disposeBag)

        tagTextField.rx.text.orEmpty
            .asDriver()
            .drive(addMemoViewModel.tag)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .asDriver()
            .drive(onNext: {
                self.addMemoViewModel.onAddButtonTapped()
            })
            .disposed(by: disposeBag)

        addMemoViewModel.buttonEnabled
            .drive(addButton.rx.isEnabled)
            .disposed(by: disposeBag)

    }
}

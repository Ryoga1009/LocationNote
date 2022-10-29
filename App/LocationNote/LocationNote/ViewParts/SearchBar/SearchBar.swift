//
//  SearchBar.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/29.
//

import UIKit

protocol SearchBarDelegate: AnyObject {
    func onSearchTextFieldChanged(searchText: String)
}

class SearchBar: UIView {

    @IBOutlet private var textField: UITextField!
    @IBOutlet private var clearButton: UIButton!

    var delegate: SearchBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }

    @IBAction func onClearButtonTapped(_ sender: Any) {
        textField.text = ""
    }

}

extension SearchBar {
    func loadView() {
        guard let view = R.nib.searchBar(owner: self) else {
            fatalError("error")
        }
        view.frame = self.bounds
        addSubview(view)

        addShadow()

        setUpView()
    }

    func setUpView() {
        layer.borderWidth = 1.0
        layer.borderColor = R.color.black2()?.cgColor
        layer.cornerRadius = 16

        textField.delegate = self
    }

    func setDefaultLayout() {
        layer.borderWidth = 1.0
        layer.borderColor = R.color.black2()?.cgColor
    }

    func setEdditingLayout() {
        layer.borderWidth = 3.0
        layer.borderColor = R.color.blue1()?.cgColor
    }
}

extension SearchBar: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        setEdditingLayout()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        setDefaultLayout()
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        clearButton.isHidden = textField.text?.isEmpty ?? true

        delegate?.onSearchTextFieldChanged(searchText: textField.text ?? "")
    }
}

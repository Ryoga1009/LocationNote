//
//  SearchBar.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/29.
//

import UIKit

class SearchBar: UIView {

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var clearButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }

}

extension SearchBar {
    func loadView() {
        guard let view = R.nib.searchBar(owner: self) else {
            fatalError("error")
        }
        view.frame = self.bounds
        addSubview(view)

        setUpView()
    }

    func setUpView() {
        stackView.layer.borderWidth = 1.0
        stackView.layer.borderColor = R.color.black2()?.cgColor
        stackView.layer.cornerRadius = 14

    }

}

//
//  SearchBar.swift
//  LocationNote
//
//  Created by k17124kk on 2022/10/29.
//

import UIKit

class SearchBar: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var clearButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }

}

extension SearchBar {
    func setUpView() {
        guard let view = R.nib.searchBar(owner: self) else {
            fatalError("error")
        }

        view.frame = self.bounds
        addSubview(view)
    }

}

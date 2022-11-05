//
//  PrimaryButton.swift
//  LocationNote
//
//  Created by k17124kk on 2022/11/05.
//

import UIKit

class PrimaryButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? R.color.blue1() : R.color.black2()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? R.color.blue1() : R.color.blue2()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
}

extension PrimaryButton {
    func setView() {
        self.layer.cornerRadius = 12
        self.isEnabled = false
    }
}

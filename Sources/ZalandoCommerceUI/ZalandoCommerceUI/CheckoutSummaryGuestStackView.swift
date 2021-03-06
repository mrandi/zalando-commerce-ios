//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation
import UIKit

class CheckoutSummaryGuestStackView: UIStackView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: UIFontWeightLight)
        label.text = Localizer.format(string: "summaryView.label.guestCheckout")
        label.textColor = .black
        return label
    }()

    let valueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 10, weight: UIFontWeightLight)
        label.textColor = UIColor(hex: 0x7F7F7F)
        label.textAlignment = .right
        return label
    }()

}

extension CheckoutSummaryGuestStackView: UIBuilder {

    func configureView() {
        addArrangedSubview(titleLabel)
        addArrangedSubview(valueLabel)
    }

}

extension CheckoutSummaryGuestStackView: UIDataBuilder {

    typealias T = String?

    func configure(viewModel: T) {
        valueLabel.text = viewModel
    }

}

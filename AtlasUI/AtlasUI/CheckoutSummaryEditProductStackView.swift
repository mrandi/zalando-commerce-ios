//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

protocol CheckoutSummaryEditProductDataSource: class {

    var checkoutContainer: CheckoutContainerView { get }
    var selectedArticle: SelectedArticle { get }

}

protocol CheckoutSummaryEditProductDelegate: class {

    func updated(selectedArticle: SelectedArticle)

}

class CheckoutSummaryEditProductStackView: UIStackView {

    let sizeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hex: 0x848484), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: UIFontWeightLight)
        return button
    }()

    let sizeQuantitySeparatorView: BorderView = {
        let view = BorderView()
        view.rightBorder = true
        view.borderColor = UIColor(hex: 0xE5E5E5)
        return view
    }()

    let quantityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hex: 0x848484), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 10, weight: UIFontWeightLight)
        return button
    }()

    weak var dataSource: CheckoutSummaryEditProductDataSource?
    weak var delegate: CheckoutSummaryEditProductDelegate?

    func displayInitialSizes() {
        guard let selectedArticle = dataSource?.selectedArticle else { return }
        dataSource?.checkoutContainer.displaySizes(selectedArticle: selectedArticle, animated: false) { [weak self] idx in
            self?.sizeSelected(at: idx, for: selectedArticle)
        }
    }

    dynamic fileprivate func sizeButtonTapped() {
        guard let selectedArticle = dataSource?.selectedArticle else { return }
        dataSource?.checkoutContainer.displaySizes(selectedArticle: selectedArticle, animated: true) { [weak self] idx in
            self?.sizeSelected(at: idx, for: selectedArticle)
        }
    }

    dynamic fileprivate func quantityButtonTapped() {
        guard let selectedArticle = dataSource?.selectedArticle else { return }
        dataSource?.checkoutContainer.displayQuantites(selectedArticle: selectedArticle, animated: true) { [weak self] idx in
            self?.quantitySelected(at: idx, for: selectedArticle)
        }
    }

    private func sizeSelected(at idx: Int, for selectedArticle: SelectedArticle) {
        let updatedArticle = SelectedArticle(changeSelectedIndex: idx, from: selectedArticle)

        guard let currentSelectedArticle = dataSource?.selectedArticle,
            dataSource?.checkoutContainer.collectionView.type == .size, updatedArticle != currentSelectedArticle else { return }

        delegate?.updated(selectedArticle: updatedArticle)
    }

    private func quantitySelected(at idx: Int, for selectedArticle: SelectedArticle) {
        let updatedArticle = SelectedArticle(changeQuantity: idx + 1, from: selectedArticle)

        guard let currentSelectedArticle = dataSource?.selectedArticle,
            dataSource?.checkoutContainer.collectionView.type == .quantity, updatedArticle != currentSelectedArticle else { return }

        delegate?.updated(selectedArticle: updatedArticle)
    }

}

extension CheckoutSummaryEditProductStackView: UIBuilder {

    func configureView() {
        addArrangedSubview(sizeButton)
        addArrangedSubview(sizeQuantitySeparatorView)
        addArrangedSubview(quantityButton)
    }

    func configureConstraints() {
        sizeButton.setWidth(equalToView: quantityButton)
        sizeQuantitySeparatorView.setWidth(equalToConstant: UIView.onePixel)
    }

}

extension CheckoutSummaryEditProductStackView: UIDataBuilder {

    typealias T = CheckoutSummaryViewModel

    func configure(viewModel: T) {
        let selectedArticle = viewModel.dataModel.selectedArticle
        if selectedArticle.isSelected {
            let sizeLabel = Localizer.format(string: "summaryView.button.size")
            let size = selectedArticle.unit.size
            sizeButton.setTitle("\(sizeLabel): \(size)", for: .normal)
        } else {
            sizeButton.setTitle(Localizer.format(string: "summaryView.title.selectSize"), for: .normal)
        }

        let quantityLabel = Localizer.format(string: "summaryView.button.quantity")
        quantityButton.setTitle("\(quantityLabel): \(selectedArticle.quantity)", for: .normal)

        sizeButton.removeTarget(self, action: nil, for: .touchUpInside)
        quantityButton.removeTarget(self, action: nil, for: .touchUpInside)
        if viewModel.layout.allowArticleRefine {
            sizeButton.addTarget(self, action: #selector(sizeButtonTapped), for: .touchUpInside)
            quantityButton.addTarget(self, action: #selector(quantityButtonTapped), for: .touchUpInside)
        }
    }

}

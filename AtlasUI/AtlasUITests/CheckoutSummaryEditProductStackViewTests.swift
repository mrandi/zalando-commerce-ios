//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import XCTest
import Nimble

@testable import AtlasUI
@testable import AtlasSDK

class CheckoutSummaryEditProductStackViewTests: UITestCase {

    var checkoutSummaryViewController: CheckoutSummaryViewController?

    func testSelectInitialSizeWhileNotLoggedIn() {
        registerAtlasUIViewController(for: "GU121D08Z-Q11")
        selectItemInCollectionView()
        expect(self.checkoutSummaryViewController?.actionHandler as? NotLoggedInSummaryActionHandler).toEventuallyNot(beNil())
    }

    func testSelectInitialSizeWhileLoggedIn() {
        AtlasAPIClient.shared?.authorize(withToken: "TestToken")
        registerAtlasUIViewController(for: "GU121D08Z-Q11")
        selectItemInCollectionView()
        expect(self.checkoutSummaryViewController?.actionHandler as? LoggedInSummaryActionHandler).toEventuallyNot(beNil())
        AtlasAPIClient.shared?.deauthorize()
    }

    func testOneSizeInitialSizeWhileNotLoggedIn() {
        registerAtlasUIViewController(for: "MK151F00E-Q11")
        expect(self.checkoutSummaryViewController?.actionHandler as? NotLoggedInSummaryActionHandler).toEventuallyNot(beNil())
    }

    func testOneSizeInitialSizeWhileLoggedIn() {
        AtlasAPIClient.shared?.authorize(withToken: "TestToken")
        registerAtlasUIViewController(for: "MK151F00E-Q11")
        expect(self.checkoutSummaryViewController?.actionHandler as? LoggedInSummaryActionHandler).toEventuallyNot(beNil())
        AtlasAPIClient.shared?.deauthorize()
    }

    func testSelectingQuantity() {
        registerAtlasUIViewController(for: "GU121D08Z-Q11")
        selectItemInCollectionView()
        tapOnRefineButton(type: .quantity)
        selectItemInCollectionView(idx: 2)
        expect(self.checkoutSummaryViewController?.dataModel.selectedArticle.quantity).toEventually(equal(3))
    }

    func testSelectingSize() {
        registerAtlasUIViewController(for: "GU121D08Z-Q11")
        selectItemInCollectionView()
        tapOnRefineButton(type: .size)
        selectItemInCollectionView(idx: 1)
        expect(self.checkoutSummaryViewController?.dataModel.selectedArticle.unitIndex).toEventually(equal(1))
    }

    func testOneSizeSelectQuantity() {
        registerAtlasUIViewController(for: "MK151F00E-Q11")
        tapOnRefineButton(type: .quantity)
        selectItemInCollectionView(idx: 2)
        expect(self.checkoutSummaryViewController?.dataModel.selectedArticle.quantity).toEventually(equal(3))
    }

    func testSelectSizeWithLessQuantity() {
        registerAtlasUIViewController(for: "AZ711M001-B11")
        selectItemInCollectionView(idx: 1)
        tapOnRefineButton(type: .quantity)
        selectItemInCollectionView(idx: 6)
        expect(self.checkoutSummaryViewController?.dataModel.selectedArticle.quantity).toEventually(equal(7))
        tapOnRefineButton(type: .size)
        selectItemInCollectionView(idx: 0)
        expect(self.checkoutSummaryViewController?.dataModel.selectedArticle.quantity).toEventually(equal(5))
        tapOnRefineButton(type: .size)
        selectItemInCollectionView(idx: 2)
        expect(self.checkoutSummaryViewController?.dataModel.selectedArticle.quantity).toEventually(equal(1))
    }

}

extension CheckoutSummaryEditProductStackViewTests {

    override func registerAtlasUIViewController(for sku: ColorSKU) {
        super.registerAtlasUIViewController(for: sku)
        configureCheckoutSummaryViewController()
    }

    fileprivate func configureCheckoutSummaryViewController() {
        expect(self.atlasUIViewController?.mainNavigationController.viewControllers.last as? CheckoutSummaryViewController).toEventuallyNot(beNil())
        guard let checkoutSummary = self.atlasUIViewController?.mainNavigationController.viewControllers.last as? CheckoutSummaryViewController else { return fail() }
        self.checkoutSummaryViewController = checkoutSummary
    }

    fileprivate func selectItemInCollectionView(idx: Int = 0) {
        guard
            let summaryView = checkoutSummaryViewController?.view,
            let collectionView: CheckoutSummaryArticleSelectCollectionView = retrieveView(inView: summaryView) else { return fail() }
        collectionView.collectionView(collectionView, didSelectItemAt: IndexPath(row: idx, section: 0))
    }

    fileprivate func tapOnRefineButton(type: CheckoutSummaryArticleRefineType) {
        guard
            let summaryView = checkoutSummaryViewController?.view,
            let editProductStackView: CheckoutSummaryEditProductStackView = retrieveView(inView: summaryView) else { return fail() }
        let button: UIButton
        switch type {
        case .size: button = editProductStackView.sizeButton
        case .quantity: button = editProductStackView.quantityButton
        }

        guard let action = button.actions(forTarget: editProductStackView, forControlEvent: .touchUpInside)?.first else { return fail() }
        UIApplication.shared.sendAction(NSSelectorFromString(action), to: editProductStackView, from: nil, for: nil)
    }

}

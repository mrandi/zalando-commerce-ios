//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import XCTest
import Nimble

@testable import ZalandoCommerceUI
@testable import ZalandoCommerceAPI

class GuestSummaryActionHandlerTests: UITestCase {

    var mockedDataSourceDelegate: GuestSummaryActionHandlerDataSourceDelegateMocked?
    var actionHandler: GuestCheckoutSummaryActionHandler?

    override func setUp() {
        super.setUp()
        actionHandler = createActionHandler()
    }

    func testSubmitButtonWithMissingAddress() {
        actionHandler?.handleSubmit()
        expect(self.errorDisplayed).toEventually(beTrue())
    }

    func testSubmitButtonWithMissingPayment() {
        guard let dataModel = mockedDataSourceDelegate?.dataModel else { return fail() }
        mockedDataSourceDelegate?.dataModel = addAddress(toDataModel: dataModel)
        actionHandler?.handleSubmit()
        expect(self.errorDisplayed).toEventually(beTrue())
    }

    func testSubmitButton() {
        selectedPaymentMethod()
        expect(self.actionHandler?.guestCheckout).toNotEventually(beNil())
        actionHandler?.handleSubmit()
        expect(self.mockedDataSourceDelegate?.layout as? GuestOrderPlacedLayout).toNotEventually(beNil())
    }

    func testPaymentButtonWithMissingAddress() {
        actionHandler?.handlePaymentSelection()
        expect(self.errorDisplayed).toEventually(beTrue())
    }

    func testPaymentButtonWithPaymentError() {
        guard let dataModel = mockedDataSourceDelegate?.dataModel else { return fail() }
        mockedDataSourceDelegate?.dataModel = addAddress(toDataModel: dataModel)
        guard let paymentViewController = showPaymentScreen() else { return fail() }
        paymentViewController.paymentCompletion?(.error)
        _ = self.defaultNavigationController?.popViewController(animated: true)
        expect(self.errorDisplayed).toEventually(beTrue())
    }

    func testPaymentButtonWithPaymentSuccess() {
        selectedPaymentMethod()
        expect(self.errorDisplayed).toEventually(beFalse())
    }

}

extension GuestSummaryActionHandlerTests {

    fileprivate func createActionHandler() -> GuestCheckoutSummaryActionHandler? {
        var guestActionHandler: GuestCheckoutSummaryActionHandler?
        waitUntil(timeout: 10) { done in
            ZalandoCommerceAPI.withLoader.article(with: self.sku) { result in
                guard let article = result.process() else { return fail() }
                let selectedArticle = SelectedArticle(article: article)
                self.mockedDataSourceDelegate = GuestSummaryActionHandlerDataSourceDelegateMocked(selectedArticle: selectedArticle)
                guestActionHandler = GuestCheckoutSummaryActionHandler(email: "john.doe@zalando.de")
                guestActionHandler?.dataSource = self.mockedDataSourceDelegate
                guestActionHandler?.delegate = self.mockedDataSourceDelegate
                done()
            }
        }
        return guestActionHandler
    }

    fileprivate func createAddress() -> GuestCheckoutAddress {
        return GuestCheckoutAddress(id: "",
                                    gender: .male,
                                    firstName: "John",
                                    lastName: "Doe",
                                    street: "Mollstr. 1",
                                    additional: nil,
                                    zip: "10178",
                                    city: "Berlin",
                                    countryCode: "DE",
                                    pickupPoint: nil)
    }

    fileprivate func addAddress(toDataModel dataModel: CheckoutSummaryDataModel) -> CheckoutSummaryDataModel {
        return CheckoutSummaryDataModel(selectedArticle: dataModel.selectedArticle,
                                        shippingAddress: createAddress(),
                                        billingAddress: createAddress(),
                                        paymentMethod: dataModel.paymentMethod,
                                        totalPrice: dataModel.totalPrice,
                                        delivery: dataModel.delivery,
                                        email: dataModel.email)
    }

    fileprivate func showPaymentScreen() -> PaymentViewController? {
        actionHandler?.handlePaymentSelection()
        expect(self.defaultNavigationController?.viewControllers.last as? PaymentViewController).toNotEventually(beNil())
        return self.defaultNavigationController?.viewControllers.last as? PaymentViewController
    }

    fileprivate func selectedPaymentMethod() {
        guard let dataModel = mockedDataSourceDelegate?.dataModel else { return fail() }
        mockedDataSourceDelegate?.dataModel = addAddress(toDataModel: dataModel)
        guard let paymentViewController = showPaymentScreen() else { return fail() }
        let guestCheckoutId = GuestCheckoutId(checkoutId: "CHECKOUT_ID", token: "TOKEN")
        paymentViewController.paymentCompletion?(.guestRedirect(guestCheckoutId: guestCheckoutId))
        _ = self.defaultNavigationController?.popViewController(animated: true)
    }

}

class GuestSummaryActionHandlerDataSourceDelegateMocked: NSObject, CheckoutSummaryActionHandlerDataSource, CheckoutSummaryActionHandlerDelegate {

    var dataModel: CheckoutSummaryDataModel
    var layout: CheckoutSummaryLayout?

    init(selectedArticle: SelectedArticle) {
        dataModel = CheckoutSummaryDataModel(selectedArticle: selectedArticle, totalPrice: Money.zero)
    }

    func updated(dataModel: CheckoutSummaryDataModel) {

    }

    func updated(layout: CheckoutSummaryLayout) {
        self.layout = layout
    }

    func updated(actionHandler: CheckoutSummaryActionHandler) {

    }

    func dismissView() {

    }

}

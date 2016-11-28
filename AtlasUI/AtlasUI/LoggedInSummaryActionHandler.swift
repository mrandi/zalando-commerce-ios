//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import AtlasSDK

typealias LoggedInSummaryActionHandlerCompletion = (AtlasResult<LoggedInSummaryActionHandler>) -> Void
typealias CartCheckout = (cart: Cart?, checkout: Checkout?)
typealias CreateCartCheckoutCompletion = (AtlasResult<CartCheckout>) -> Void

class LoggedInSummaryActionHandler: CheckoutSummaryActionHandler {

    let customer: Customer

    weak var dataSource: CheckoutSummaryActionHandlerDataSource?
    weak var delegate: CheckoutSummaryActionHandlerDelegate?

    var cartCheckout: CartCheckout? {
        didSet {
            updateCheckout()
        }
    }

    fileprivate var shippingAddress: ShippingAddress? {
        return dataSource?.dataModel.shippingAddress as? EquatableAddress
    }

    fileprivate var billingAddress: BillingAddress? {
        return dataSource?.dataModel.billingAddress as? EquatableAddress
    }

    fileprivate var addresses: CheckoutAddresses? {
        return CheckoutAddresses(billingAddress: billingAddress, shippingAddress: shippingAddress)
    }

    fileprivate var hasAddresses: Bool {
        return shippingAddress != nil && billingAddress != nil
    }

    static func create(customer: Customer, selectedArticleUnit: SelectedArticleUnit,
                       completion: @escaping LoggedInSummaryActionHandlerCompletion) {
        LoggedInSummaryActionHandler.createCartCheckout(selectedArticleUnit: selectedArticleUnit) { result in
            switch result {
            case .success(let cartCheckout):
                let actionHandler = LoggedInSummaryActionHandler(customer: customer)
                actionHandler.cartCheckout = cartCheckout
                completion(.success(actionHandler))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    fileprivate init(customer: Customer) {
        self.customer = customer
    }

    func handleSubmitButton() {
        guard let dataSource = dataSource else { return }
        guard dataSource.dataModel.isPaymentSelected else {
            UserMessage.displayError(AtlasCheckoutError.missingAddressAndPayment)
            return
        }

        createCartCheckout { [weak self] result in
            guard let cartCheckout = result.process() else { return }
            guard let checkout = cartCheckout.checkout, cartCheckout.cart != nil else {
                return UserMessage.displayError(AtlasCheckoutError.unclassified)
            }

            self?.cartCheckout = cartCheckout

            if dataSource.dataModel.isPaymentSelected && !UserMessage.errorDisplayed {
                AtlasUIClient.createOrder(fromCheckoutId: checkout.id) { result in
                    guard let order = result.process() else { return }
                    self?.handleConfirmation(forOrder: order)
                }
            }
        }
    }

    func presentPaymentSelectionScreen() {
        guard let paymentURL = cartCheckout?.checkout?.payment.selectionPageURL,
            let callbackURL = AtlasAPIClient.shared?.config.payment.selectionCallbackURL else {
            let error = !hasAddresses ? AtlasCheckoutError.missingAddress : AtlasCheckoutError.unclassified
            UserMessage.displayError(error)
            return
        }

        let paymentViewController = PaymentViewController(paymentURL: paymentURL, callbackURL: callbackURL)
        paymentViewController.paymentCompletion = { [weak self] paymentStatus in
            switch paymentStatus {
            case .redirect, .success:
                self?.createCartCheckout { result in
                    guard let cartCheckout = result.process() else { return }
                    self?.cartCheckout = cartCheckout
                }
            case .cancel:
                break
            case .error:
                UserMessage.displayError(AtlasCheckoutError.unclassified)
            }
        }

        AtlasUIViewController.shared?.mainNavigationController.pushViewController(paymentViewController, animated: true)
    }

    func presentShippingAddressSelectionScreen() {
        AtlasUIClient.addresses { [weak self] result in
            guard let userAddresses = result.process() else { return }
            let addresses: [EquatableAddress] = userAddresses.map { $0 }
            let creationStrategy = ShippingAddressViewModelCreationStrategy()
            let addressViewController = AddressListViewController(initialAddresses: addresses, selectedAddress: self?.shippingAddress)
            addressViewController.addressUpdatedHandler = { self?.updated(address: $0) }
            addressViewController.addressDeletedHandler = { self?.deleted(address: $0) }
            addressViewController.addressSelectedHandler = { self?.select(shippingAddress: $0) }
            addressViewController.actionHandler = LoggedInAddressListActionHandler(addressViewModelCreationStrategy: creationStrategy)
            addressViewController.title = Localizer.format(string: "addressListView.title.shipping")
            AtlasUIViewController.shared?.mainNavigationController.pushViewController(addressViewController, animated: true)
        }
    }

    func presentBillingAddressSelectionScreen() {
        AtlasUIClient.addresses { [weak self] result in
            guard let userAddresses = result.process() else { return }
            let addresses: [EquatableAddress] = userAddresses.filter { $0.pickupPoint == nil } .map { $0 }
            let creationStrategy = BillingAddressViewModelCreationStrategy()
            let addressViewController = AddressListViewController(initialAddresses: addresses, selectedAddress: self?.billingAddress)
            addressViewController.addressUpdatedHandler = { self?.updated(address: $0) }
            addressViewController.addressDeletedHandler = { self?.deleted(address: $0) }
            addressViewController.addressSelectedHandler = { self?.select(billingAddress: $0) }
            addressViewController.actionHandler = LoggedInAddressListActionHandler(addressViewModelCreationStrategy: creationStrategy)
            addressViewController.title = Localizer.format(string: "addressListView.title.billing")
            AtlasUIViewController.shared?.mainNavigationController.pushViewController(addressViewController, animated: true)
        }
    }

}

extension LoggedInSummaryActionHandler {

    fileprivate func handleConfirmation(forOrder order: Order) {
        guard let paymentURL = order.externalPaymentURL else {
            presentConfirmationScreen(order)
            return
        }

        guard let callbackURL = AtlasAPIClient.shared?.config.payment.thirdPartyCallbackURL else {
            UserMessage.displayError(AtlasCheckoutError.unclassified)
            return
        }

        let paymentViewController = PaymentViewController(paymentURL: paymentURL, callbackURL: callbackURL)
        paymentViewController.paymentCompletion = { [weak self] paymentStatus in
            switch paymentStatus {
            case .success: self?.presentConfirmationScreen(order)
            case .redirect, .cancel: break
            case .error: UserMessage.displayError(AtlasCheckoutError.unclassified)
            }
        }
        AtlasUIViewController.shared?.mainNavigationController.pushViewController(paymentViewController, animated: true)
    }

    fileprivate func presentConfirmationScreen(_ order: Order) {
        guard let dataSource = dataSource, let delegate = delegate else { return }
        let selectedArticleUnit = dataSource.dataModel.selectedArticleUnit
        let dataModel = CheckoutSummaryDataModel(selectedArticleUnit: selectedArticleUnit, checkout: cartCheckout?.checkout, order: order)
        delegate.updated(actionHandler: OrderPlacedSummaryActionHandler())
        delegate.updated(dataModel: dataModel)
        delegate.updated(layout: OrderPlacedLayout())
    }

}

extension LoggedInSummaryActionHandler {

    fileprivate func createCartCheckout(completion: @escaping CreateCartCheckoutCompletion) {
        guard let selectedArticleUnit = dataSource?.dataModel.selectedArticleUnit else { return }
        LoggedInSummaryActionHandler.createCartCheckout(selectedArticleUnit: selectedArticleUnit,
                                                        addresses: addresses,
                                                        completion: completion)
    }

    fileprivate static func createCartCheckout(selectedArticleUnit: SelectedArticleUnit,
                                               addresses: CheckoutAddresses? = nil,
                                               completion: @escaping CreateCartCheckoutCompletion) {

        AtlasUIClient.createCheckoutCart(forSKU: selectedArticleUnit.sku, addresses: addresses) { result in
            switch result {
            case .failure(let error, _):
                guard case let AtlasAPIError.checkoutFailed(cart, _) = error else {
                    completion(.failure(error))
                    return
                }

                completion(.success((cart: cart, checkout: nil)))
                if addresses?.billingAddress != nil && addresses?.shippingAddress != nil {
                    UserMessage.displayError(AtlasCheckoutError.checkoutFailure)
                }
            case .success(let checkoutCart):
                completion(.success((cart: checkoutCart.cart, checkout: checkoutCart.checkout)))
            }
        }
    }

}

extension LoggedInSummaryActionHandler {

    fileprivate func updateCheckout() {
        updateDataModel(with: self.addresses, in: self.cartCheckout)
    }

    fileprivate func update(billingAddress newBillingAddress: BillingAddress? = nil,
                            shippingAddress newShippingAddress: ShippingAddress? = nil) {
        let newAddresses = CheckoutAddresses(billingAddress: newBillingAddress ?? self.billingAddress,
                                             shippingAddress: newShippingAddress ?? self.shippingAddress)
        updateDataModel(with: newAddresses, in: self.cartCheckout)
    }

    fileprivate func delete(billingAddress deleteBilling: Bool = false, shippingAddress deleteShipping: Bool = false) {
        let newAddresses = CheckoutAddresses(billingAddress: deleteBilling ? nil : self.billingAddress,
                                             shippingAddress: deleteShipping ? nil : self.shippingAddress)
        updateDataModel(with: newAddresses)
        cartCheckout?.checkout = nil
    }

    fileprivate func updateDataModel(with addresses: CheckoutAddresses?, in cartCheckout: CartCheckout? = nil) {
        guard let selectedArticleUnit = dataSource?.dataModel.selectedArticleUnit else { return }

        let dataModel = CheckoutSummaryDataModel(selectedArticleUnit: selectedArticleUnit, cartCheckout: cartCheckout, addresses: addresses)
        delegate?.updated(dataModel: dataModel)

        if cartCheckout?.checkout == nil && hasAddresses {
            createCartCheckout { [weak self] result in
                guard let cartCheckout = result.process() else { return }
                self?.cartCheckout = cartCheckout
            }
        }
    }

}

extension LoggedInSummaryActionHandler {

    fileprivate func updated(address: EquatableAddress) {
        if let shippingAddress = shippingAddress, shippingAddress == address {
            update(shippingAddress: address)
        }
        if let billingAddress = billingAddress, billingAddress == address {
            update(billingAddress: address)
        }
    }

    fileprivate func deleted(address deletedAddress: EquatableAddress) {
        if let shippingAddress = shippingAddress, shippingAddress == deletedAddress {
            delete(shippingAddress: true)
        }
        if let billingAddress = billingAddress, billingAddress == deletedAddress {
            delete(billingAddress: true)
        }
    }

    fileprivate func select(shippingAddress newShippingAddress: ShippingAddress?) {
        update(shippingAddress: newShippingAddress)
    }

    fileprivate func select(billingAddress newBillingAddress: BillingAddress?) {
        update(billingAddress: newBillingAddress)
    }

}

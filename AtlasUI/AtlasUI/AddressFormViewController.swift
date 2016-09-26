//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

typealias AddressFormCompletion = UserAddress -> Void

class AddressFormViewController: UIViewController, CheckoutProviderType {

    internal let scrollView: KeyboardScrollView = {
        let scrollView = KeyboardScrollView()
        scrollView.keyboardDismissMode = .Interactive
        return scrollView
    }()

    internal lazy var addressStackView: AddressFormStackView = {
        let stackView = AddressFormStackView()
        stackView.addressType = self.addressType
        stackView.checkoutProviderType = self
        stackView.axis = .Vertical
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        stackView.layoutMarginsRelativeArrangement = true
        return stackView
    }()

    internal let loaderView: LoaderView = {
        let view = LoaderView()
        view.hidden = true
        return view
    }()

    private let addressType: AddressFormType
    private let addressMode: AddressFormMode
    internal let checkout: AtlasCheckout
    private let addressViewModel: AddressFormViewModel
    internal var completion: AddressFormCompletion?

    init(addressType: AddressFormType, addressMode: AddressFormMode, checkout: AtlasCheckout, completion: AddressFormCompletion?) {
        self.addressType = addressType
        self.addressMode = addressMode
        self.checkout = checkout
        self.completion = completion

        switch addressMode {
        case .createAddress:
            self.addressViewModel = AddressFormViewModel(equatableAddress: nil, countryCode: checkout.client.config.countryCode)
        case .updateAddress(let address):
            self.addressViewModel = AddressFormViewModel(equatableAddress: address, countryCode: checkout.client.config.countryCode)
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
        buildView()
        addressStackView.configureData(addressViewModel)
        configureNavigation()
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "address-edit-right-button"
    }

}

extension AddressFormViewController {

    private func configureNavigation() {
        let saveButton = UIBarButtonItem(title: loc("Save"), style: .Plain, target: self, action: #selector(submitButtonPressed))
        navigationItem.rightBarButtonItem = saveButton

        if addressMode == .createAddress {
            let cancelButton = UIBarButtonItem(title: loc("Cancel"), style: .Plain, target: self, action: #selector(cancelButtonPressed))
            navigationItem.leftBarButtonItem = cancelButton
        }
    }

    private dynamic func submitButtonPressed() {
        view.endEditing(true)

        let isValid = addressStackView.textFields.map { $0.validateForm() }.filter { $0 == false }.isEmpty
        guard isValid else { return }
        checkAddressRequest()
    }

    private dynamic func cancelButtonPressed() {
        dismissView()
    }

    private func dismissView() {
        view.endEditing(true)

        if addressMode == .createAddress {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }

}

extension AddressFormViewController: UIBuilder {

    func configureView() {
        view.addSubview(scrollView)
        view.addSubview(loaderView)
        scrollView.addSubview(addressStackView)
        scrollView.registerForKeyboardNotifications()
    }

    func configureConstraints() {
        scrollView.fillInSuperView()
        loaderView.fillInSuperView()
        addressStackView.fillInSuperView()
        addressStackView.setWidth(equalToView: scrollView)
    }

    func builderSubviews() -> [UIBuilder] {
        return [addressStackView, loaderView]
    }

}

extension AddressFormViewController {

    private func checkAddressRequest() {
        guard let request = CheckAddressRequest(addressFormViewModel: addressViewModel) else { return }
        loaderView.show()
        checkout.client.checkAddress(request) { [weak self] result in
            self?.checkAddressRequestCompletion(result)
        }
    }

    private func createAddressRequest() {
        guard let request = CreateAddressRequest(addressFormViewModel: addressViewModel) else { return }
        loaderView.show()
        checkout.client.createAddress(request) { [weak self] result in
            self?.createUpdateAddressRequestCompletion(result)
        }
    }

    private func updateAddressRequest(originalAddress: EquatableAddress) {
        guard let request = UpdateAddressRequest(addressFormViewModel: addressViewModel) else { return }
        loaderView.show()
        checkout.client.updateAddress(originalAddress.id, request: request) { [weak self] result in
            self?.createUpdateAddressRequestCompletion(result)
        }
    }

    private func checkAddressRequestCompletion(result: AtlasResult<CheckAddressResponse>) {
        loaderView.hide()
        switch result {
        case .failure(let error):
            self.userMessage.show(error: error)
        case .success(let checkAddressResponse):
            if checkAddressResponse.status == .notCorrect {
                let title = self.loc("Address.validation.notValid")
                self.userMessage.show(title: title, message: nil, actions: ButtonAction(text: "OK"))
            } else {
                switch self.addressMode {
                case .createAddress: self.createAddressRequest()
                case .updateAddress(let address): self.updateAddressRequest(address)
                }
                self.dismissView()
            }
        }
    }

    private func createUpdateAddressRequestCompletion(result: AtlasResult<UserAddress>) {
        loaderView.hide()
        switch result {
        case .failure(let error):
            self.userMessage.show(error: error)
        case .success(let address):
            self.dismissView()
            self.completion?(address)
        }
    }

}
//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK
import AtlasUI

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var customerNumer: UILabel!
    @IBOutlet weak var gender: UILabel!

    @IBOutlet weak var languageSwitcher: UISegmentedControl!
    @IBOutlet weak var environmentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var salesChannelSwitcher: UISegmentedControl!

    @IBOutlet weak var profileStackView: UIStackView!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        updateSalesChannels()
        updateLanguages()
        updateEnvironmentSelectedIndex()
        updateProfile()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateProfile(fromNotification:)),
                                               name: .AtlasAuthorizationChanged,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func serverSwitched(_ sender: UISegmentedControl) {
        let useSandbox = sender.selectedSegmentIndex == 1
        AppSetup.change(environmentToSandbox: useSandbox)
    }

    @IBAction func languageSwitched(_ sender: UISegmentedControl) {
        let language = InterfaceLanguage(index: sender.selectedSegmentIndex)
        AppSetup.change(interfaceLanguage: language)
    }

    @IBAction func salesChannelChanged(_ sender: UISegmentedControl) {
        let salesChannel = SalesChannel(index: sender.selectedSegmentIndex)
        AppSetup.change(salesChannel: salesChannel)
    }

    @IBAction func logoutButtonTapped(_ sender: Any) {
        Atlas.deauthorize()
        updateProfile()
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        loadCustomerData()
    }

    fileprivate func setupViews() {
        self.name.text = ""
        self.email.text = ""
        self.customerNumer.text = ""
        self.gender.text = ""
        self.email.textColor = .gray

        self.profileStackView.alpha = 0
        self.loginButton.alpha = 0
    }

    @objc fileprivate func updateProfile(fromNotification: Notification) {
        updateProfile()
    }

    fileprivate func updateProfile(loadData: Bool = true) {
        let showProfile = Atlas.isAuthorized()

        UIView.animate(withDuration: 0.3) {
            self.profileStackView.alpha = showProfile ? 1 : 0
            self.loginButton.alpha = showProfile ? 0 : 1
        }

        if showProfile && loadData {
            loadCustomerData()
        }
    }

    fileprivate func updateLanguages() {
        self.languageSwitcher.removeAllSegments()
        InterfaceLanguage.all.forEach { language in
            let index = self.languageSwitcher.numberOfSegments
            self.languageSwitcher.insertSegment(withTitle: language.name, at: index, animated: false)
            if language.rawValue == AppSetup.options?.interfaceLanguage {
                self.languageSwitcher.selectedSegmentIndex = index
            }
        }
    }

    fileprivate func updateSalesChannels() {
        self.salesChannelSwitcher.removeAllSegments()
        SalesChannel.all.forEach { salesChannel in
            let index = self.salesChannelSwitcher.numberOfSegments
            self.salesChannelSwitcher.insertSegment(withTitle: salesChannel.name, at: index, animated: false)
            if salesChannel.rawValue == AppSetup.options?.salesChannel {
                self.salesChannelSwitcher.selectedSegmentIndex = index
            }
        }
    }

    fileprivate func updateEnvironmentSelectedIndex() {
        let selectedSegment = AppSetup.options?.useSandboxEnvironment == true ? 1 : 0
        environmentSegmentedControl.selectedSegmentIndex = selectedSegment
    }

    fileprivate func loadCustomerData() {
        AppSetup.atlas?.client.customer { result in
            let processedResult = result.processedResult()
            switch processedResult {
            case .success(let customer):
                self.avatar.image = UIImage(named: "user")
                self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
                self.avatar.clipsToBounds = true
                self.name.text = "\(customer.firstName) \(customer.lastName)"
                self.email.text = customer.email
                self.customerNumer.text = customer.customerNumber
                self.gender.text = customer.gender.rawValue

            case .error(_, let title, let message):
                UIAlertController.showMessage(title: title, message: message)

            case .handledInternally:
                break
            }

            self.updateProfile(loadData: false)
        }
    }

}

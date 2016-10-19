//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit

public class AtlasUIViewController: UIViewController {

    let mainNavigationController: UINavigationController
    private let atlasReachability = AtlasReachability()

    private let loaderView: LoaderView = {
        let view = LoaderView()
        view.hidden = true
        return view
    }()

    init(atlasCheckout: AtlasCheckout, forProductSKU sku: String) {
        let sizeSelectionViewController = SizeListSelectionViewController(checkout: atlasCheckout, sku: sku)
        mainNavigationController = UINavigationController(rootViewController: sizeSelectionViewController)

        super.init(nibName: nil, bundle: nil)
    }

    required public  init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        addChildViewController(mainNavigationController)
        view.addSubview(mainNavigationController.view)
        mainNavigationController.view.fillInSuperView()
        atlasReachability.setupReachability()
    }

}

extension AtlasUIViewController {

    func showLoader() {
        loaderView.removeFromSuperview()
        UIApplication.topViewController()?.view.addSubview(loaderView)
        loaderView.fillInSuperView()
        loaderView.buildView()
        loaderView.show()
    }

    func hideLoader() {
        loaderView.hide()
        loaderView.removeFromSuperview()
    }

}

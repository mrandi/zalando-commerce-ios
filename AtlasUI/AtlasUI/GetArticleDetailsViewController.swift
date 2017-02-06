//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK

class GetArticleDetailsViewController: UIViewController {

    let sku: String

    init(sku: String) {
        self.sku = sku
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchArticle()
    }

    private func fetchArticle() {
        AtlasUIClient.article(withSKU: self.sku) { [weak self] result in
            guard let article = result.process(forceFullScreenError: true) else { return }
            self?.showSummaryView(article: article)
        }
    }

    private func showSummaryView(article: Article) {
        guard article.hasSingleUnit else {
            let initialSelectedArticle = SelectedArticle(article: article, unitIndex: NSNotFound, quantity: 1)
            let dataModel = CheckoutSummaryDataModel(selectedArticle: initialSelectedArticle, totalPrice: initialSelectedArticle.totalPrice)
            let viewModel = CheckoutSummaryViewModel(dataModel: dataModel, layout: ArticleNotSelectedLayout())
            showSummaryView(viewModel: viewModel, actionHandler: ArticleNotSelectedActionHandler())
            return
        }

        let selectedArticle = SelectedArticle(article: article, unitIndex: 0, quantity: 1)
        guard AtlasAPIClient.shared?.isAuthorized == true else {
            let dataModel = CheckoutSummaryDataModel(selectedArticle: selectedArticle, totalPrice: selectedArticle.totalPrice)
            let viewModel = CheckoutSummaryViewModel(dataModel: dataModel, layout: NotLoggedInLayout())
            showSummaryView(viewModel: viewModel, actionHandler: NotLoggedInSummaryActionHandler())
            return
        }

        AtlasUIClient.customer { [weak self] customerResult in
            guard let customer = customerResult.process(forceFullScreenError: true) else { return }

            LoggedInSummaryActionHandler.create(customer: customer, selectedArticle: selectedArticle) { actionHandlerResult in
                guard let actionHandler = actionHandlerResult.process(forceFullScreenError: true) else { return }

                let dataModel = CheckoutSummaryDataModel(selectedArticle: selectedArticle, cartCheckout: actionHandler.cartCheckout)
                let viewModel = CheckoutSummaryViewModel(dataModel: dataModel, layout: LoggedInLayout())
                self?.showSummaryView(viewModel: viewModel, actionHandler: actionHandler)
            }
        }
    }

    private func showSummaryView(viewModel: CheckoutSummaryViewModel, actionHandler: CheckoutSummaryActionHandler) {
        let checkoutSummaryViewController = CheckoutSummaryViewController(viewModel: viewModel)
        checkoutSummaryViewController.actionHandler = actionHandler
        navigationController?.viewControllers = [checkoutSummaryViewController]
    }

}
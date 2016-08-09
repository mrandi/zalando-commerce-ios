//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit
import AtlasSDK
import AtlasUI

class CatalogViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var productCollectionView: UICollectionView!

    var articles = [DemoArticle]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.productCollectionView.reloadData()
            }
        }
    }

    private let articlesClient = ArticlesClient()
    private let exampleImageView = UIImageView()
    private let sampleSKUs = ["L2711E002-Q11", "AZ711N007-Q11",
        "GU121D08Z-Q11", "AZ711N007-Q11",
        "AZ711N008-G11", "AZ711M001-B11", "AZ711N00B-Q11", "MK151F00E-Q11"]

    override func viewDidLoad() {
        super.viewDidLoad()
        exampleImageView.image = UIImage(named: "example")
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadHomepageArticles()
    }

    private func loadHomepageArticles() {
        articlesClient.fetch(articlesForSKUs: sampleSKUs) { result in
            switch result {
            case .success(let articles):
                self.articles = articles
            case .failure(let error):
                UserMessage.showError(title: "Error", error: error)
            }
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCollectionViewCell", forIndexPath: indexPath)
        (cell as? ProductCollectionViewCell)?.setupCell(withArticle: articles[indexPath.row])

        return cell
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }

    @IBAction private func buyButtonTapped(sender: UIButton) {
        AtlasCheckoutInstance?.presentCheckoutView(sku: "N1242A0WI-K13")
    }

}

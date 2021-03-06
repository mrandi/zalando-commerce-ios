//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import XCTest
import Foundation
import Nimble

@testable import ZalandoCommerceAPI

class APIArticleTests: APITestCase {

    func testFetchArticle() {
        waitForAPIConfigured { done, api in
            let sku = ConfigSKU(value: "AD541L009-G11")
            api.article(with: sku) { result in
                switch result {
                case .failure(let error):
                    fail(String(describing: error))
                case .success(let article):
                    expect(article.id) == sku
                    expect(article.name) == "ADIZERO  - Sportkleid - red"
                    expect(article.brand.name) == "adidas Performance"

                    expect(article.availableUnits.count) == 1
                    expect(article.availableUnits.first?.id.value) == "AD541L009-G1100XS000"
                    expect(article.availableUnits.first?.price.amount) == 10.45

                    let validURL = "https://i6.ztat.net/detail/AD/54/1L/00/9G/11/AD541L009-G11@14.jpg"
                    expect(article.media?.firstImage?.detailURL) == URL(validURL: validURL)
                    expect(article.media?.firstImage?.order) == 1
                }
                done()
            }
        }
    }

}

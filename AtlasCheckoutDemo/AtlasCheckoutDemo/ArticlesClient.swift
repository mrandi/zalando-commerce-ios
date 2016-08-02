//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import AtlasSDK
import AtlasCommons
import AtlasMockAPI
import Alamofire

typealias ArticlesCompletion = AtlasCommons.Result<[DemoArticle]> -> Void

enum ArticlesError: ErrorType {
    case NoData
    case Error(ErrorType)
}

class ArticlesClient {

    var dataTask: NSURLSessionDataTask?

    func fetch(articlesForSKUs skus: [String], completion: ArticlesCompletion) {
        Alamofire.request(.GET, endpointURL(forSKUs: skus)).responseString { response in
            if let error = response.result.error {
                completion(.failure(ArticlesError.Error(error)))
                return
            }
            guard let responseString = response.result.value else {
                completion(.failure(ArticlesError.NoData))
                return
            }
            let articles = DemoCatalog(jsonString: responseString).articles
            completion(.success(articles))
        }
    }

    private func endpointURL(forSKUs skus: [String]) -> NSURL {
        if NSProcessInfo.hasMockedAPIEnabled {
            return AtlasMockAPI.endpointURL(forPath: "/articles")
        }

        let urlComponents = NSURLComponents(validUrlString: "https://api.zalando.com/articles")
        urlComponents.queryItems = skus.map {
            NSURLQueryItem(name: "articleId", value: $0)
        }
        return urlComponents.validURL
    }

}

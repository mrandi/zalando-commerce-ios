//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import Foundation

struct ResponseParser {

    let taskResponse: DataTaskResponse

    func parse(completion: ResponseCompletion) {
        if let error = taskResponse.error {
            let nsError = error as NSError
            let nsURLError = APIError.nsURLError(code: nsError.code,
                                                 details: nsError.localizedDescription)
            return completion(.failure(nsURLError))
        }

        guard let httpResponse = taskResponse.response, let data = taskResponse.data else {
            return completion(.failure(APIError.noData))
        }

        let json = try? JSON(data: data)

        guard httpResponse.isSuccessful else {
            let error: APIError
            if httpResponse.status == .unauthorized {
                error = APIError.unauthorized
            } else if let json = json {
                error = APIError.backend(status: json["status"].int,
                                         type: json["type"].string,
                                         title: json["title"].string,
                                         details: json["detail"].string)
            } else {
                error = APIError.http(status: httpResponse.statusCode,
                                      details: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
            }
            return completion(.failure(error))
        }

        completion(.success(JSONResponse(response: httpResponse, body: json)))
    }

}

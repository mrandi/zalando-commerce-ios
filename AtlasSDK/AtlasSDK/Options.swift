//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

public struct Options {

    public let useSandboxEnvironment: Bool
    public let clientId: String
    public let salesChannel: String
    public let interfaceLanguage: String?
    public let configurationURL: URL

    public init(clientId: String? = nil,
                salesChannel: String? = nil,
                useSandbox: Bool? = nil,
                interfaceLanguage: String? = nil,
                configurationURL: URL? = nil,
                infoBundle bundle: Bundle = Bundle.main) {
        self.clientId = clientId ?? bundle.string(for: .clientId) ?? ""
        self.salesChannel = salesChannel ?? bundle.string(for: .salesChannel) ?? ""
        self.useSandboxEnvironment = useSandbox ?? bundle.bool(for: .useSandbox) ?? false
        self.interfaceLanguage = interfaceLanguage ?? bundle.string(for: .interfaceLanguage)

        if let url = configurationURL {
            self.configurationURL = url
        } else {
            self.configurationURL = Options.defaultConfigurationURL(clientId: self.clientId, useSandbox: self.useSandboxEnvironment)
        }
    }

    public func validate() throws {
        if self.clientId.isEmpty {
            throw AtlasConfigurationError.missingClientId
        }
        if self.salesChannel.isEmpty {
            throw AtlasConfigurationError.missingSalesChannel
        }
    }

}

extension Options: CustomStringConvertible {

    public var description: String {
        func format(optional text: String?, defaultText: String = "<NONE>") -> String {
            guard let text = text else { return defaultText }
            return "'\(text) '"
        }

        return "\(type(of: self)) { "
            + "\n\tclientId = \(format(optional: clientId)) "
            + ", \n\tuseSandboxEnvironment = \(useSandboxEnvironment) "
            + ", \n\tsalesChannel = \(format(optional: salesChannel)) "
            + ", \n\tinterfaceLanguage = \(interfaceLanguage) "
            + " } "
    }

}

extension Options {

    enum Environment: String {
        case staging = "staging"
        case production = "production"
    }

    enum ResponseFormat: String {
        case json = "json"
        case yaml = "yaml"
        case properties = "properties"
    }

    fileprivate static func defaultConfigurationURL(clientId: String, useSandbox: Bool,
                                                    inFormat format: ResponseFormat = .json) -> URL {
        let environment: Environment = useSandbox ? .staging : .production
        let baseUrl = "https://atlas-config-api.dc.zalan.do"
        let path = "/api/config/\(clientId)-\(environment).\(format)"
        return URLComponents(validUrl: baseUrl, path: path).validUrl
    }

}

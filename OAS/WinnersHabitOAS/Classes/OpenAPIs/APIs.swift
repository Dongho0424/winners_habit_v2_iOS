// APIs.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

open class WinnersHabitOASAPI {
    public static var basePath = "http://grabtest.tk:4240"
    public static var credential: URLCredential?
    public static var customHeaders: [String: String] = [:]
    public static var requestBuilderFactory: RequestBuilderFactory = URLSessionRequestBuilderFactory()
    public static var apiResponseQueue: DispatchQueue = .main
}

open class RequestBuilder<T> {
    var credential: URLCredential?
    var headers: [String: String]
    public let parameters: [String: Any]?
    public let method: String
    public let URLString: String

    /// Optional block to obtain a reference to the request's progress instance when available.
    /// With the URLSession http client the request's progress only works on iOS 11.0, macOS 10.13, macCatalyst 13.0, tvOS 11.0, watchOS 4.0.
    /// If you need to get the request's progress in older OS versions, please use Alamofire http client.
    public var onProgressReady: ((Progress) -> Void)?

    required public init(method: String, URLString: String, parameters: [String: Any]?, headers: [String: String] = [:]) {
        self.method = method
        self.URLString = URLString
        self.parameters = parameters
        self.headers = headers

        addHeaders(WinnersHabitOASAPI.customHeaders)
    }

    open func addHeaders(_ aHeaders: [String: String]) {
        for (header, value) in aHeaders {
            headers[header] = value
        }
    }

    open func execute(_ apiResponseQueue: DispatchQueue = WinnersHabitOASAPI.apiResponseQueue, _ completion: @escaping (_ result: Swift.Result<Response<T>, Error>) -> Void) { }

    public func addHeader(name: String, value: String) -> Self {
        if !value.isEmpty {
            headers[name] = value
        }
        return self
    }

    open func addCredential() -> Self {
        credential = WinnersHabitOASAPI.credential
        return self
    }
}

public protocol RequestBuilderFactory {
    func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type
    func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type
}

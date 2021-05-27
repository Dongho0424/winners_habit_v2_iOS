//
// HabitAPI.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
import RxSwift

open class HabitAPI {
    /**
     유저의 특정 습관의 상세 정보 불러오기
     
     - parameter habitId: (path) PK of habit 
     - parameter userId: (query) PK of user 
     - parameter apiResponseQueue: The queue on which api response is dispatched.
     - returns: Observable<HabitDetail>
     */
    open class func habitHabitIdGet(habitId: Int, userId: Int, apiResponseQueue: DispatchQueue = OpenAPIClientAPI.apiResponseQueue) -> Observable<HabitDetail> {
        return Observable.create { observer -> Disposable in
            habitHabitIdGetWithRequestBuilder(habitId: habitId, userId: userId).execute(apiResponseQueue) { result -> Void in
                switch result {
                case let .success(response):
                    observer.onNext(response.body!)
                case let .failure(error):
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /**
     유저의 특정 습관의 상세 정보 불러오기
     - GET /habit/{habitId}
     - return HabitDetail
     - parameter habitId: (path) PK of habit 
     - parameter userId: (query) PK of user 
     - returns: RequestBuilder<HabitDetail> 
     */
    open class func habitHabitIdGetWithRequestBuilder(habitId: Int, userId: Int) -> RequestBuilder<HabitDetail> {
        var path = "/habit/{habitId}"
        let habitIdPreEscape = "\(APIHelper.mapValueToPathItem(habitId))"
        let habitIdPostEscape = habitIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{habitId}", with: habitIdPostEscape, options: .literal, range: nil)
        let URLString = OpenAPIClientAPI.basePath + path
        let parameters: [String: Any]? = nil

        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
            "user_id": userId.encodeToJSON(),
        ])

        let nillableHeaders: [String: Any?] = [
            :
        ]

        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<HabitDetail>.Type = OpenAPIClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, headers: headerParameters)
    }

    /**
     userId, date에 해당하는 습관의 히스토리 가져오기
     
     - parameter userId: (query) PK of user 
     - parameter date: (query) date which user want to show history of habits 
     - parameter apiResponseQueue: The queue on which api response is dispatched.
     - returns: Observable<HabitHistory>
     */
    open class func habitHistoryGet(userId: Int, date: String, apiResponseQueue: DispatchQueue = OpenAPIClientAPI.apiResponseQueue) -> Observable<HabitHistory> {
        return Observable.create { observer -> Disposable in
            habitHistoryGetWithRequestBuilder(userId: userId, date: date).execute(apiResponseQueue) { result -> Void in
                switch result {
                case let .success(response):
                    observer.onNext(response.body!)
                case let .failure(error):
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /**
     userId, date에 해당하는 습관의 히스토리 가져오기
     - GET /habit-history
     - parameter userId: (query) PK of user 
     - parameter date: (query) date which user want to show history of habits 
     - returns: RequestBuilder<HabitHistory> 
     */
    open class func habitHistoryGetWithRequestBuilder(userId: Int, date: String) -> RequestBuilder<HabitHistory> {
        let path = "/habit-history"
        let URLString = OpenAPIClientAPI.basePath + path
        let parameters: [String: Any]? = nil

        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
            "user_id": userId.encodeToJSON(),
            "date": date.encodeToJSON(),
        ])

        let nillableHeaders: [String: Any?] = [
            :
        ]

        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<HabitHistory>.Type = OpenAPIClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, headers: headerParameters)
    }

}

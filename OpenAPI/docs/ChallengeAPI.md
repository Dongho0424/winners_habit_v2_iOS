# ChallengeAPI

All URIs are relative to *http://grabtest.tk:4240*

Method | HTTP request | Description
------------- | ------------- | -------------
[**allChallengesGet**](ChallengeAPI.md#allchallengesget) | **GET** /allChallenges | 모든 챌린지 리스트 가져오기
[**challengeGet**](ChallengeAPI.md#challengeget) | **GET** /challenge | {userId}가 속한 챌린지의 습관들 불러오기


# **allChallengesGet**
```swift
    open class func allChallengesGet() -> Observable<[Challenge]>
```

모든 챌린지 리스트 가져오기

### Example 
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WinnersHabitOAS


// TODO RxSwift sample code not yet implemented. To contribute, please open a ticket via http://github.com/OpenAPITools/openapi-generator/issues/new
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[Challenge]**](Challenge.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **challengeGet**
```swift
    open class func challengeGet(userId: Int64) -> Observable<ChallengeInfo>
```

{userId}가 속한 챌린지의 습관들 불러오기

### Example 
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WinnersHabitOAS

let userId = 987 // Int64 | PK of user

// TODO RxSwift sample code not yet implemented. To contribute, please open a ticket via http://github.com/OpenAPITools/openapi-generator/issues/new
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **Int64** | PK of user | 

### Return type

[**ChallengeInfo**](ChallengeInfo.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


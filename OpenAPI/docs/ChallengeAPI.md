# ChallengeAPI

All URIs are relative to *http://grabtest.tk:4240*

Method | HTTP request | Description
------------- | ------------- | -------------
[**challengeGet**](ChallengeAPI.md#challengeget) | **GET** /challenge | {userId}가 속한 챌린지의 습관들 불러오기


# **challengeGet**
```swift
    open class func challengeGet(userId: Int64, completion: @escaping (_ data: ChallengeInfo?, _ error: Error?) -> Void)
```

{userId}가 속한 챌린지의 습관들 불러오기

### Example 
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int64 | PK of user

// {userId}가 속한 챌린지의 습관들 불러오기
ChallengeAPI.challengeGet(userId: userId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
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


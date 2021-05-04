# HabitAPI

All URIs are relative to *http://grabtest.tk:4240*

Method | HTTP request | Description
------------- | ------------- | -------------
[**habitHabitIdGet**](HabitAPI.md#habithabitidget) | **GET** /habit/{habitId} | 유저의 특정 습관의 상세 정보 불러오기


# **habitHabitIdGet**
```swift
    open class func habitHabitIdGet(habitId: Int, userId: Int, completion: @escaping (_ data: HabitDetail?, _ error: Error?) -> Void)
```

유저의 특정 습관의 상세 정보 불러오기

return HabitDetail

### Example 
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let habitId = 987 // Int | PK of habit
let userId = 987 // Int | PK of user

// 유저의 특정 습관의 상세 정보 불러오기
HabitAPI.habitHabitIdGet(habitId: habitId, userId: userId) { (response, error) in
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
 **habitId** | **Int** | PK of habit | 
 **userId** | **Int** | PK of user | 

### Return type

[**HabitDetail**](HabitDetail.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


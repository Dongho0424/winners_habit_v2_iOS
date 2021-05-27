# HabitAPI

All URIs are relative to *http://grabtest.tk:4240*

Method | HTTP request | Description
------------- | ------------- | -------------
[**habitHabitIdGet**](HabitAPI.md#habithabitidget) | **GET** /habit/{habitId} | 유저의 특정 습관의 상세 정보 불러오기
[**habitHistoryGet**](HabitAPI.md#habithistoryget) | **GET** /habit-history | userId, date에 해당하는 습관의 히스토리 가져오기


# **habitHabitIdGet**
```swift
    open class func habitHabitIdGet(habitId: Int, userId: Int) -> Observable<HabitDetail>
```

유저의 특정 습관의 상세 정보 불러오기

return HabitDetail

### Example 
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let habitId = 987 // Int | PK of habit
let userId = 987 // Int | PK of user

// TODO RxSwift sample code not yet implemented. To contribute, please open a ticket via http://github.com/OpenAPITools/openapi-generator/issues/new
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

# **habitHistoryGet**
```swift
    open class func habitHistoryGet(userId: Int, date: String) -> Observable<HabitHistory>
```

userId, date에 해당하는 습관의 히스토리 가져오기

### Example 
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import OpenAPIClient

let userId = 987 // Int | PK of user
let date = "date_example" // String | date which user want to show history of habits

// TODO RxSwift sample code not yet implemented. To contribute, please open a ticket via http://github.com/OpenAPITools/openapi-generator/issues/new
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **Int** | PK of user | 
 **date** | **String** | date which user want to show history of habits | 

### Return type

[**HabitHistory**](HabitHistory.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


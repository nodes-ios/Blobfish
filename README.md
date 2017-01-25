<p align="center">
  <img src="./Blobfish_icon.png?raw=true" alt="Blobfish"/>
</p>

Easily handle errors and present them to the user in a nice way.
[![Travis](https://travis-ci.org/nodes-ios/Blobfish.svg?branch=master)](https://travis-ci.org/nodes-ios/Blobfish)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Plaform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/nodes-ios/Policeman/blob/master/LICENSE)

## 📦 Installation

### Carthage
~~~bash
github "nodes-ios/Blobfish" ~> 1.0
~~~

> Last versions compatible with lower Swift versions:  
>
> **Swift 2.3**  
> `github "nodes-ios/Blobfish" == 0.2.0`
>
> **Swift 2.2**  
> `github "nodes-ios/Blobfish" == 0.1.2`

## 🔧 Setup

#### Blob & Blobbable

> **TODO:** Add instructions

#### Alamofire Extension

In your AppDelegate's `applicationDidFinishLaunching:launchOptions:` function first do the basic setup of Blobfish:

```swift
Blobfish.AlamofireConfig.blobForTokenExpired = {
    let action = Blob.AlertAction(title: "Ok", handler: {
        // Your custom actions on token expired go here
    })
    return Blob(title: "Token Expired", 
    			style: .Alert(message: "Your token has expired. Please log in again.", actions: [action]))
}

Blobfish.AlamofireConfig.blobForUnknownError = { _, _ in
    let action = Blob.AlertAction(title: "Ok", handler: nil)
    return Blob(title: "Uknown Error", 
    			style: .Alert(message: "Unknown error happened, please try again.", actions: [action]))
}

Blobfish.AlamofireConfig.blobForConnectionError = { _ in
    return Blob(title: "Connection error, please try again.", style: .Overlay)
}
```

There is an extension to Alamofire `Response` to make it adhere to the `Blobbable` protocol, so handling errors in your callbacks should be a breeze.

```swift
func doSomeRequest(completion: Response<AnyObject, NSError> -> Void) { ... }
// ...
doSomeRequest(completion: { response in 
	switch response.result {
	case .Failure(_):
		// First, handle your custom error codes manually
		if response.response?.statusCode == 870 {
			// Your code to handle a custom error code
		} else {
			// Fallback to Blobfish
			Blobfish.sharedInstance.handle(response)
		}
	default: break
})

```


## 👥 Credits
Made with ❤️ at [Nodes](http://nodesagency.com).

## 📄 License
**Blobfish** is available under the MIT license. See the [LICENSE](https://github.com/nodes-ios/Blobfish/blob/master/LICENSE) file for more info.

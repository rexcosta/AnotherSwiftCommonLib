# AnotherSwiftCommonLib

Just another swift common lib.

# Network

Just another swift Http layer

## NetworkProtocol

`NetworkProtocol` defines how a network layer should behave. 

You can use this behaviour to decorate your network implementation like the following example:
```swift
let networkImpl: NetworkProtocol = YourNetworkImpl()
let networkLogger: NetworkProtocol = YourNetworkLogger(
    network: networkImpl
)
let networkCache: NetworkProtocol = YourNetworkCache(
    network: networkLogger
)
let network: NetworkProtocol = YourNetworkActivity(
    network: networkCache
)

// Use normally
network.requestData(...)
```

## NetworkError

`NetworkProtocol` defines the possible errros for the network layer. 

## EmptyNetwork
Example of a `NetworkProtocol` implementation, that only returns success data.

# Combine

Just another swift Combine helpers collection

## Extensions

* `Result+AnyPublisher`
  * contains some factory methods to create more readable `Result`
* `Publisher+Sink`
  * contains some Sink Subscriber helpers

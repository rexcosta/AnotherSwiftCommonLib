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

## ValueCache

ValueCache is used to cache a value produced from a given Publisher.
* If the value don't exist yet or a error occurred the producer will be used to obtain the value/failure
* While a value is produced, other value requesters will not trigger another produce action
* ValueCache is thread safe

```swift
let cache = ValueCache<Int, Never>(producer: Deferred(createPublisher: { () -> AnyPublisher in
    // Return a value producer.
    // Ex: 
    return Future { promisse in
        queue.asyncAfter(deadline: .now() + 5) {
            promisse(Result.success(1))
        }
    }.eraseToAnyPublisher()
}))

// First value call will trigger the producer
cache.value().sinkIntoResultAndStore(in: &cancellables) { 
    // Handle the result
}

// Second call will wait for the producer to end or will use the cached value
// if the value is already available
cache.value().sinkIntoResultAndStore(in: &cancellables) { 
    // Handle the result
}        
```
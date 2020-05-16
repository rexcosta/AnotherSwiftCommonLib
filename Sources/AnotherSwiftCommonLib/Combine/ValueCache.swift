//
// The MIT License (MIT)
//
// Copyright (c) 2020 Effective Like ABoss, David Costa Gonçalves
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Combine
import Foundation
import os

/// ValueCache is used to cache a value produced from a given Publisher
/// While a value is produced, other value requesters will not trigger another produce action
/// If the value don't exists or a error occurred the producer will be used to obtain the value/failure
/// - Value: the type of the cached value
/// - Failure: The error type that can be produced
/// ValueCache is thread safe
public final class ValueCache<Value, Failure: Error> {
    
    /// Describes the internal state for the ValueCache
    private enum State {
        case uninitialized
        case error(_ error: Failure)
        case value(_ value: Value)
        case refreshing(_ downstream: PassthroughSubject<Value, Failure>)
    }
    
    private var currentStateLock = NSRecursiveLock()
    private var state = State.uninitialized
    
    private let producer: Deferred<AnyPublisher<Value, Failure>>
    private var cancellables = Set<AnyCancellable>()
    
    private let log: OSLog
    public let valueCacheName: String
    
    /// Creates a ready to use ValueCache
    /// - Parameters:
    ///   - log: the OSLog to be used, `default` to OSLog.default
    ///   - valueCacheName: the ValueCache name to appear in the logs, `default`to  empty string
    ///   - producer:
    /// - Note: producer must be Deferred, because it can be called multiple times
    public init(
        log: OSLog = .default,
        valueCacheName: String = "",
        producer: Deferred<AnyPublisher<Value, Failure>>
    ) {
        self.log = log
        self.valueCacheName = valueCacheName
        self.producer = producer
    }
    
    /// Forces the cache to load it's value from the producer
    /// - If the value don't exist or any error occurred previously, this method will use the producer to produce a value
    /// - If the value already exists this do nothing
    /// - If the value is already being queried this do nothing
    public func preload() {
        currentStateLock.lock()
        defer {
            currentStateLock.unlock()
        }
        
        switch state {
        case .uninitialized, .error:
            os_log(.debug, log: log, "[%s] Preloading Value", valueCacheName)
            let theCache = PassthroughSubject<Value, Failure>()
            state = .refreshing(theCache)
            produce(theCache)
            
        case .value, .refreshing:
            break
        }
    }
    
    /// Loads the value into the returned publisher
    /// - If the value don't exist or any error occurred previously, this method will use the producer to produce a value
    /// - If the value already exists, the value will be returned
    /// - If the value is already being queried this do nothing
    /// - Returns: Publisher to subscribe for value/failure update
    public func value() -> AnyPublisher<Value, Failure> {
        currentStateLock.lock()
        defer {
            currentStateLock.unlock()
        }
        
        switch state {
        case .uninitialized, .error:
            os_log(.debug, log: log, "[%s] Refreshing Value", valueCacheName)
            
            let downstream = PassthroughSubject<Value, Failure>()
            state = .refreshing(downstream)
            produce(downstream)
            return downstream.eraseToAnyPublisher()
            
        case .value(let theValue):
            return Result.makeSuccess(theValue)
            
        case .refreshing(let downstream):
            return downstream.eraseToAnyPublisher()
        }
    }
    
}

// MARK: Private
extension ValueCache {
    
    private func produce(_ downstream: PassthroughSubject<Value, Failure>) {
        producer.sinkIntoResultAndStore(in: &cancellables) { [weak self] (result) in
            switch result {
                
            case .success(let data):
                if let this = self {
                    os_log(.debug, log: this.log, "[%s] Produce with Success", this.valueCacheName)
                    
                    this.currentStateLock.lock()
                    this.state = .value(data)
                    this.currentStateLock.unlock()
                }
                downstream.send(data)
                downstream.send(completion: .finished)
                
            case .failure(let error):
                if let this = self {
                    os_log(.error, log: this.log, "[%s] Producewith Error %s", this.valueCacheName, error.localizedDescription)
                    
                    this.currentStateLock.lock()
                    this.state = .error(error)
                    this.currentStateLock.unlock()
                }
                downstream.send(completion: .failure(error))
            }
        }
    }
    
}

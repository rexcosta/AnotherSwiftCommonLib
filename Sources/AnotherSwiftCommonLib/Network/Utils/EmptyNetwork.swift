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

/// Implementation of NetworkProtocol
/// All methods return success after a period of time defined at the request timeout
///
/// Important:
/// -> This should not be used for production
/// -> This only exist for test purposes
public final class EmptyNetwork: NetworkProtocol {
    
    private let log: OSLog
    public let networkName: String
    
    private let dispatchQueue: DispatchQueue
    
    public init(
        log: OSLog = .default,
        networkName: String = String(describing: EmptyNetwork.self),
        dispatchQueue: DispatchQueue = DispatchQueue(label: "empty.requests.queue")
    ) {
        self.log = log
        self.networkName = networkName
        self.dispatchQueue = dispatchQueue
    }
    
    public func requestData(request: NetworkRequest) -> AnyPublisher<Data, NetworkError> {
        os_log(.debug, log: log, "[%s][%s] Requesting Empty Data",
               networkName,
               request.uniqueRequestId.uuidString)
        
        return makeFuture(request: request) { () -> Result<Data, NetworkError> in
            os_log(.debug, log: self.log, "[%s][%s] Producing Empty Data",
                self.networkName,
                request.uniqueRequestId.uuidString
            )
            
            return Result.success(Data())
        }
    }
    
    public func requestJsonObject(request: NetworkRequest) -> AnyPublisher<[String: Any], NetworkError> {
        os_log(.debug, log: log, "[%s][%s] Requesting Json Object",
            networkName,
            request.uniqueRequestId.uuidString
        )
        
        return makeFuture(request: request) { () -> Result<[String: Any], NetworkError> in
            os_log(.debug, log: self.log, "[%s][%s] Producing Empty Json Object",
                self.networkName,
                request.uniqueRequestId.uuidString
            )
            
            return Result.success([String: Any]())
        }
    }
    
    public func requestJsonArray(request: NetworkRequest) -> AnyPublisher<[Any], NetworkError> {
        os_log(.debug, log: log, "[%s][%s] Requesting Json Array",
            networkName,
            request.uniqueRequestId.uuidString
        )
        
        return makeFuture(request: request) { () -> Result<[Any], NetworkError> in
            os_log(.debug, log: self.log, "[%s][%s] Producing Empty Json Array",
                self.networkName,
                request.uniqueRequestId.uuidString
            )
            
            return Result.success([Any]())
        }
    }
    
    public func requestDecodable<T: Decodable>(request: NetworkRequest) -> AnyPublisher<T, NetworkError> {
        os_log(.debug, log: log, "[%s][%s] Requesting Empty Decodable",
            networkName,
            request.uniqueRequestId.uuidString
        )
        
        return makeFuture(request: request) { () -> Result<T, NetworkError> in
            do {
                let typeAsString = String(reflecting: T.self)
                
                // To use JSONDecoder, we need to provide a empty json
                // We check if the value is Swift.Array to provide [] or {}
                // The provided Object must have all the properties optional
                let rawJsonString: String
                if typeAsString.contains("Swift.Array") {
                    os_log(.debug, log: self.log, "[%s][%s] Producing Empty Decodable from json []",
                        self.networkName,
                        request.uniqueRequestId.uuidString
                    )
                    rawJsonString = "[]"
                    
                } else {
                    os_log(.debug, log: self.log, "[%s][%s] Producing Empty Decodable from json {}",
                        self.networkName,
                        request.uniqueRequestId.uuidString
                    )
                    rawJsonString = "{}"
                }
                
                guard let jsonData = rawJsonString.data(using: .utf8) else {
                    os_log(.error, log: self.log, "[%s][%s] Producing Empty Decodable unable to produce string into data",
                        self.networkName,
                        request.uniqueRequestId.uuidString
                    )
                    return Result.failure(NetworkError.invalidJson)
                }
                
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: jsonData)
                return Result.success(result)
                
            } catch  {
                os_log(.error, log: self.log, "[%s][%s] Producing Empty Decodable ended with error %s",
                    self.networkName,
                    request.uniqueRequestId.uuidString,
                    error.localizedDescription
                )
                return Result.failure(NetworkError.unknown(cause: error))
            }
        }
    }
    
    private func makeFuture<T>(
        request: NetworkRequest,
        resultMaker: @escaping () -> Result<T, NetworkError>
    ) -> AnyPublisher<T, NetworkError> {
        // https://heckj.github.io/swiftui-notes/#reference-future
        return Deferred {
            return Future<T, NetworkError> { promisse in
                self.dispatchQueue.asyncAfter(deadline: .now() + request.timeout) {
                    promisse(resultMaker())
                }
            }
        }.eraseToAnyPublisher()
    }
    
}

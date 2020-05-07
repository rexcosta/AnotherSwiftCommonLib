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

/// Implementation of NetworkProtocol
/// All methods return success after a period of time defined at the request timeout
///
/// Important:
/// -> This should not be used for production
/// -> This only exist for test purposes
public final class EmptyNetwork: NetworkProtocol {
    
    private let dispatchQueue: DispatchQueue
    
    public init(dispatchQueue: DispatchQueue = DispatchQueue(label: "empty.requests.queue")) {
        self.dispatchQueue = dispatchQueue
    }
    
    public func requestData(request: NetworkRequest) -> AnyPublisher<Data, NetworkError> {
        return makeFuture(request: request) { () -> Result<Data, NetworkError> in
            return Result.success(Data())
        }
    }
    
    public func requestJsonObject(request: NetworkRequest) -> AnyPublisher<[String: Any], NetworkError> {
        return makeFuture(request: request) { () -> Result<[String: Any], NetworkError> in
            return Result.success([String: Any]())
        }
    }
    
    public func requestJsonArray(request: NetworkRequest) -> AnyPublisher<[Any], NetworkError> {
        return makeFuture(request: request) { () -> Result<[Any], NetworkError> in
            return Result.success([Any]())
        }
    }
    
    public func requestDecodable<T: Decodable>(request: NetworkRequest) -> AnyPublisher<T, NetworkError> {
        return makeFuture(request: request) { () -> Result<T, NetworkError> in
            do {
                let typeAsString = String(reflecting: T.self)
                
                let rawJsonString: String
                if typeAsString.contains("Swift.Array") {
                    rawJsonString = "[]"
                } else {
                    rawJsonString = "{}"
                }
                
                guard let jsonData = rawJsonString.data(using: .utf8) else {
                    return Result.failure(NetworkError.invalidJson)
                }
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: jsonData)
                return Result.success(result)
            } catch  {
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
                self.dispatchQueue.asyncAfter(deadline: DispatchTime.now() + request.timeout) {
                    promisse(resultMaker())
                }
            }
        }.eraseToAnyPublisher()
    }
    
}

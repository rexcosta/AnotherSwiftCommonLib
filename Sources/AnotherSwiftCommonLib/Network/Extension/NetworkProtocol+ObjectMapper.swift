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

// MARK: - NetworkProtocol + Map response and error
extension NetworkProtocol {
    
    public func requestData<Mapper: ObjectMapper, ErrorMapper: ObjectMapper>(
        request: NetworkRequest,
        objectMapper: Mapper,
        errorMapper: ErrorMapper
    ) -> AnyPublisher<Mapper.Output, ErrorMapper.Output> where Mapper.Input == Data, ErrorMapper.Input == NetworkError {
        return requestData(request: request)
            .map { objectMapper.mapInput($0) }
            .mapError { errorMapper.mapInput($0) }
            .eraseToAnyPublisher()
    }
    
    public func requestJsonArray<Mapper: ObjectMapper, ErrorMapper: ObjectMapper>(
        request: NetworkRequest,
        objectMapper: Mapper,
        errorMapper: ErrorMapper
    ) -> AnyPublisher<Mapper.Output, ErrorMapper.Output> where Mapper.Input == [Any], ErrorMapper.Input == NetworkError {
        return requestJsonArray(request: request)
            .map { objectMapper.mapInput($0) }
            .mapError { errorMapper.mapInput($0) }
            .eraseToAnyPublisher()
    }
    
    public func requestJsonObject<Mapper: ObjectMapper, ErrorMapper: ObjectMapper>(
        request: NetworkRequest,
        objectMapper: Mapper,
        errorMapper: ErrorMapper
    ) -> AnyPublisher<Mapper.Output, ErrorMapper.Output> where Mapper.Input == [String: Any], ErrorMapper.Input == NetworkError {
        return requestJsonObject(request: request)
            .map { objectMapper.mapInput($0) }
            .mapError { errorMapper.mapInput($0) }
            .eraseToAnyPublisher()
    }
    
    public func requestDecodable<Mapper: ObjectMapper, ErrorMapper: ObjectMapper>(
        request: NetworkRequest,
        objectMapper: Mapper,
        errorMapper: ErrorMapper
    ) -> AnyPublisher<Mapper.Output, ErrorMapper.Output> where Mapper.Input: Decodable, ErrorMapper.Input == NetworkError {
        return requestDecodable(request: request)
            .map { objectMapper.mapInput($0) }
            .mapError { errorMapper.mapInput($0) }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - NetworkProtocol + Map only the response
extension NetworkProtocol {
    
    public func requestData<Mapper: ObjectMapper>(
        request: NetworkRequest,
        objectMapper: Mapper
    ) -> AnyPublisher<Mapper.Output, NetworkError> where Mapper.Input == Data {
        return requestData(request: request)
            .map { objectMapper.mapInput($0) }
            .eraseToAnyPublisher()
    }
    
    public func requestJsonArray<Mapper: ObjectMapper>(
        request: NetworkRequest,
        objectMapper: Mapper
    ) -> AnyPublisher<Mapper.Output, NetworkError> where Mapper.Input == [Any] {
        return requestJsonArray(request: request)
            .map { objectMapper.mapInput($0) }
            .eraseToAnyPublisher()
    }
    
    public func requestJsonObject<Mapper: ObjectMapper>(
        request: NetworkRequest,
        objectMapper: Mapper
    ) -> AnyPublisher<Mapper.Output, NetworkError> where Mapper.Input == [String: Any] {
        return requestJsonObject(request: request)
            .map { objectMapper.mapInput($0) }
            .eraseToAnyPublisher()
    }
    
    public func requestDecodable<Mapper: ObjectMapper>(
        request: NetworkRequest,
        objectMapper: Mapper
    ) -> AnyPublisher<Mapper.Output, NetworkError> where Mapper.Input: Decodable {
        return requestDecodable(request: request)
            .map { objectMapper.mapInput($0) }
            .eraseToAnyPublisher()
    }
    
}

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

import Foundation

public struct NetworkRequest {
    
    public let uniqueRequestId: UUID
    public var allowsCellularAccess: Bool
    public var timeout: TimeInterval
    public var cachePolicy: NSURLRequest.CachePolicy
    public var networkServiceType: URLRequest.NetworkServiceType
    public var url: String
    public var headers: [HttpHeader]
    public var parameters = [HttpQueryParameter]()
    public var body: Data?
    public var method: HttpMethod
    
    public init(
        uniqueRequestId: UUID = UUID(),
        allowsCellularAccess: Bool = true,
        timeout: TimeInterval = TimeInterval(30),
        cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
        networkServiceType: URLRequest.NetworkServiceType = .default,
        url: String,
        headers: [HttpHeader] = [HttpHeader](),
        parameters: [HttpQueryParameter] = [HttpQueryParameter](),
        body: Data? = nil,
        method: HttpMethod = HttpMethod.get
    ) {
        self.uniqueRequestId = uniqueRequestId
        self.allowsCellularAccess = allowsCellularAccess
        self.timeout = timeout
        self.cachePolicy = cachePolicy
        self.networkServiceType = networkServiceType
        self.url = url
        self.headers = headers
        self.parameters = parameters
        self.body = body
        self.method = method
    }
    
}

// MARK: Hashable & Equatable
extension NetworkRequest: Hashable {
    
    public static func ==(lhs: NetworkRequest, rhs: NetworkRequest) -> Bool {
         return lhs.uniqueRequestId == rhs.uniqueRequestId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueRequestId)
    }
    
    public func deepEqual(to other: NetworkRequest) -> Bool {
        return allowsCellularAccess == other.allowsCellularAccess &&
            timeout == other.timeout &&
            cachePolicy == other.cachePolicy &&
            networkServiceType == other.networkServiceType &&
            url == other.url &&
            headers == other.headers &&
            parameters == other.parameters &&
            body == other.body &&
            method == other.method
    }
    
}

// MARK: CustomStringConvertible
extension NetworkRequest: CustomStringConvertible {
    
    public var description: String {
        return [
            "allowsCellularAccess": allowsCellularAccess,
            "timeout": timeout,
            "cachePolicy": cachePolicy,
            "networkServiceType": networkServiceType,
            "url": url,
            "headers": headers,
            "method": method,
            "body": body?.count ?? "nil"
            ].description
    }
    
}

// MARK: Headers
extension NetworkRequest {
    
    public mutating func add(header: HttpHeader) {
        headers.append(header)
    }
    
    public mutating func add(headers: [HttpHeader]) {
        self.headers.append(contentsOf: headers)
    }
    
    public mutating func remove(header: String) {
        headers.removeAll { $0.name == header }
    }
    
    public mutating func remove(headers: Set<String>) {
        self.headers.removeAll { headers.contains($0.name) }
    }
    
}

// MARK: QueryParameter
extension NetworkRequest {
    
    public mutating func add(parameter: HttpQueryParameter) {
        parameters.append(parameter)
    }
    
    public mutating func add(parameters: [HttpQueryParameter]) {
        self.parameters.append(contentsOf: parameters)
    }
    
    public mutating func remove(parameters: Set<String>) {
        self.parameters.removeAll { parameters.contains($0.name) }
    }
    
    public mutating func remove(parameter: String) {
        parameters.removeAll { $0.name == parameter }
    }
    
}

// MARK: To URLRequest
extension NetworkRequest {
    
    public func transformToRequest() -> URLRequest? {
        guard let requestUrl = getUrl() else {
            return nil
        }
        
        var mutableRequest = URLRequest(
            url: requestUrl,
            cachePolicy: cachePolicy,
            timeoutInterval: timeout
        )
        
        mutableRequest.networkServiceType = networkServiceType
        mutableRequest.allowsCellularAccess = allowsCellularAccess
        mutableRequest.httpMethod = method.rawValue
        
        headers.forEach {
            mutableRequest.setValue($0.value, forHTTPHeaderField: $0.name)
        }
        
        mutableRequest.httpBody = body
        
        return mutableRequest
    }
    
    private func getUrl() -> URL? {
        guard !parameters.isEmpty else {
            return URL(string: url)
        }
        guard var components = URLComponents(string: url) else {
            return nil
        }
        
        var queryItems = components.queryItems ?? [URLQueryItem]()
        parameters.forEach {
            queryItems.append(URLQueryItem(name: $0.name, value: $0.value))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components.url
    }
}

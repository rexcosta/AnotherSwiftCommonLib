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

public struct HttpHeader: Hashable {
    
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
    
}

extension HttpHeader: CustomStringConvertible {
    
    public var description: String {
        "\(name): \(value)"
    }
    
}

extension HttpHeader {
    
    public static func authorization(_ value: String) -> HttpHeader {
        return HttpHeader(name: "Authorization", value: value)
    }
    
    public static func accept(_ value: String) -> HttpHeader {
        return HttpHeader(name: "Accept", value: value)
    }
    
    public static func accept(_ value: HttpMimeType) -> HttpHeader {
        return HttpHeader(name: "Accept", value: value.rawValue)
    }
    
    public static func contentType(_ value: String) -> HttpHeader {
        return HttpHeader(name: "Content-Type", value: value)
    }
    
    public static func contentType(_ value: HttpMimeType) -> HttpHeader {
        return HttpHeader(name: "Content-Type", value: value.rawValue)
    }
    
    public static func userAgent(_ value: String) -> HttpHeader {
        return HttpHeader(name: "User-Agent", value: value)
    }
    
}

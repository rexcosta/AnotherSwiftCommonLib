import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnotherSwiftCommonLibTests.allTests),
        testCase(ValueCacheTests.allTests),
    ]
}
#endif

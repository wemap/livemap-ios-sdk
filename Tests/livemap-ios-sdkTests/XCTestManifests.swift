import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(livemap_ios_sdkTests.allTests),
    ]
}
#endif

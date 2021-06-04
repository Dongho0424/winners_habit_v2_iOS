import XCTest

import ProxyModularTests

var tests = [XCTestCaseEntry]()
tests += ProxyModularTests.allTests()
XCTMain(tests)

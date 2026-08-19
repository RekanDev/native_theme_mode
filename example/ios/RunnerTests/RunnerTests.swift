import Flutter
import UIKit
import XCTest

@testable import native_theme_mode

class RunnerTests: XCTestCase {

  func testUnknownMethodReturnsNotImplemented() {
    let plugin = NativeThemeModePlugin()
    let call = FlutterMethodCall(methodName: "getPlatformVersion", arguments: [])

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      XCTAssertTrue(result is NSObject)
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }

  func testConfigureReturnsAModeString() {
    let plugin = NativeThemeModePlugin()
    let call = FlutterMethodCall(
      methodName: "configure",
      arguments: [
        "storageKey": "theme_mode",
        "defaultMode": "system",
        "persist": true,
        "enableAndroid": true,
        "enableIOS": true,
      ]
    )

    let resultExpectation = expectation(description: "result block must be called.")
    plugin.handle(call) { result in
      let mode = result as? String
      XCTAssertTrue(mode == "light" || mode == "dark" || mode == "system")
      resultExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
  }
}

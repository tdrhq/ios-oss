//
//  Argo+TryDecodableTests.swift
//  Library-iOSTests
//
//  Created by Justin Swart on 11/1/19.
//  Copyright © 2019 Kickstarter. All rights reserved.
//

import Argo
@testable import KsApi
import XCTest

final class Argo_TryDecodableTests: XCTestCase {
  func testTryDecodable() {
    let dictionary: [String: Any] = [
      "a": "a-string",
      "b": [
        "c": "c-string"
      ],
      "d": [
        "d-string1",
        "d-string2",
        "d-string3"
      ],
      "e": 3,
      "f": false
    ]

    guard let json = Argo.JSON.decodeJSONDictionary(dictionary).value else {
      XCTFail("Should have an Argo JSON value")
      return
    }

    guard let reversedDictionary = json.toPrimitive() as? [String: Any] else {
      XCTFail("Should have had a reversed dictionary")
      return
    }

    XCTAssertEqual(reversedDictionary["a"] as? String, "a-string")
    XCTAssertEqual((reversedDictionary["b"] as? [String: Any])?["c"] as? String, "c-string")
    XCTAssertEqual((reversedDictionary["d"] as? [String])?[0], "d-string1")
    XCTAssertEqual((reversedDictionary["d"] as? [String])?[1], "d-string2")
    XCTAssertEqual((reversedDictionary["d"] as? [String])?[2], "d-string3")
    XCTAssertEqual((reversedDictionary["e"] as? Int), 3)
    XCTAssertEqual((reversedDictionary["f"] as? Bool), false)
  }
}

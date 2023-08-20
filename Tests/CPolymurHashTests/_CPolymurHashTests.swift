import XCTest
import _CPolymurHash

class _CPolymurHashTests: XCTestCase {
  public static let quiet = "" == ""  // edit during debugging

  func testDemo() {
    let code = _polymurHashDemo(0)
    XCTAssertTrue(0 == code, "error code: \(code)")
  }

  func testDemoPrint() {
    if !Self.quiet {
      _ = _polymurHashDemo(1)
    }
  }
}

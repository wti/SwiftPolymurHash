import XCTest

@testable import PolymurHash

class PolymurHashTests: XCTestCase {
  /// Check Array of UInt8 can be hashed (no real validation of results)
  func testHashBytes() {
    let me = PolymurHasher(seed: UInt64(37))
    let bufs: [[UInt8]] = [[], [11, 13, 17, 19]]
    for buf in bufs {
      let hash = me.hash(bytes: buf, tweak: UInt64(7))
      XCTAssertTrue(0 != hash, "no hash")
      let hash2 = me.hash(bytes: buf, tweak: UInt64(7))
      XCTAssertEqual(hash, hash2, "hash not repeating")
      let hash3 = me.hash(bytes: buf)  // no tweak, should be different
      XCTAssertTrue(hash2 != hash3, "hash repeated with default tweak")
    }
  }

  /// Check String can be hashed repeatedly (no real validation of results)
  func testHashString() {
    let k = (UInt64(1) << 31) - 1
    let s = (UInt64(1) << 61) - 1
    let me = PolymurHasher(k: k, s: s)
    let long = Array(repeating: "abc", count: 100_000)
      .joined(separator: "d")
    let ss = ["", "a", long]
    var results = Array(repeating: UInt64(0), count: ss.count)
    for (i, s) in ss.enumerated() {
      let hash = me.hash(s: s)  // <------------- test
      results[i] = hash
      XCTAssertTrue(0 != hash, "[\(i)] no hash for \(s)")
    }
    for (i, s) in ss.enumerated() {
      let hash = me.hash(s: s)
      XCTAssertEqual(results[i], hash, "[\(i)] did not repeat \(s)")
    }
  }

  /// Meaningless check with weird seeds for weird behavior
  func testDegenerateSeeds() {
    let seeds: [UInt64] = [.min, 1, (1 << 31) - 1, .max]
    func hashers(_ i: Int) -> [PolymurHasher] {
      var result = [PolymurHasher]()
      let seed = seeds[i]
      result.append(PolymurHasher(seed: seed))
      result.append(PolymurHasher(k: seed, s: seed))
      let noti = 0 == i ? 1 : i - 1
      let GETTING_COLLISIONS = "" == ""  // change to "." to see collisions
      if !GETTING_COLLISIONS {
        result.append(PolymurHasher(k: seed, s: seeds[noti]))
        result.append(PolymurHasher(k: seeds[noti], s: seed))
      }
      return result
    }
    let buf: [UInt8] = [11, 13, 17, 19]
    var results = [UInt64]()
    for i in 0..<seeds.count {
      for (j, me) in hashers(i).enumerated() {
        let hash = me.hash(bytes: buf)  // <------------- test
        // hmm: not really a collision when checking different hash seeds
        if let errIndex = results.firstIndex(of: hash) {
          let err =
            "collide at [\(i), \(j)]\n seed: \(seeds[i])"
            + "\n hash: \(hash)\n results[\(errIndex)]: \(results)"
          XCTAssertTrue(false, err)
        }
        results.append(hash)
      }
    }
  }
  func testHashable() {
    struct H: Hashable {
      let s: String
      // deprecation warning here
      var hashValue: Int {
        Scope.hasher.hashInt(s: s)
      }
    }
    struct J: Hashable {
      let h: H
      let i: Int
    }
    let j = J(h: H(s: "here"), i: 42)
    let set = Set([j])
    XCTAssertEqual("here", set.first?.h.s ?? "not here")
  }
  enum Scope {
    static let hasher = PolymurHasher(seed: .max)

  }
  // https://github.com/apple/swift/pull/41534/
  // https://forums.swift.org/t/pitch-pointer-bit-width-compile-time-conditional
  // https://forums.swift.org/t/compilation-conditions-for-word-size/26995
  //public static func asIntBits(_ i: UInt64) -> Int? {
}

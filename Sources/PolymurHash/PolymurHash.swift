import _CPolymurHash

/// Swift interface to polymur-hash
///
/// For details, see [polymur-hash on github](https://github.com/orlp/polymur-hash)
public struct PolymurHasher {

  // One commit past 2.0 tag, but only demo code changed
  public static let VERSION = "v2.0+_a7cc6b00051b4b579d718a4f26428098580029ec"

  private let params: PolymurHashParams  // 4 UInt64

  /// Value used when tweak parameter is 0 (default)
  public let tweak0: UInt64

  /// Initialize with s and k seed values
  /// - Parameters:
  ///   - k: UInt64 secret key for evaluating polynomial
  ///   - s: UInt64 secret for murmur-style permutation
  ///   - tweak0: UInt64 value used for tweak when parameter is 0 (defaults to 0)
  public init(k: UInt64, s: UInt64, tweak0: UInt64 = 0) {
    var params = PolymurHashParams()
    withUnsafeMutablePointer(to: &params) { paramPtr in
      polymur_init_params(paramPtr, k, s)
    }
    self.params = params
    self.tweak0 = tweak0
  }

  /// Initialize by splitting seed into s and k
  /// - Parameter seed: UInt64
  public init(seed: UInt64, tweak0: UInt64 = 0) {
    var params = PolymurHashParams()
    withUnsafeMutablePointer(to: &params) { paramPtr in
      polymur_init_params_from_seed(paramPtr, seed)
    }
    self.params = params
    self.tweak0 = tweak0
  }

  /// Hash byte buffer, with optional tweak for avoiding consistency.
  ///
  /// - Parameters:
  ///   - bufPtr: UnsafePointer to UInt8
  ///   - count: number of elements to hash (expect crash if beyond actual buffer)
  ///   - tweak: UInt64 added to result for variability (defaults to 0)
  /// - Returns: UInt64 hash value
  public func hash(
    bufPtr: UnsafePointer<[UInt8]>,
    count: Int,
    tweak: UInt64 = UInt64(0)
  ) -> UInt64 {
    return withUnsafePointer(to: self.params) { paramPtr in
      return polymur_hash(bufPtr, count, paramPtr, fix(tweak))
    }
  }

  /// Hash UInt8 (byte) array, with optional tweak for avoiding consistency
  /// - Parameters:
  ///   - bytes: Array of UInt8
  ///   - tweak: UInt64 added to result for variability (defaults to 0)
  /// - Returns: UInt64 hash value
  public func hash(bytes: [UInt8], tweak: UInt64 = UInt64(0)) -> UInt64 {
    withUnsafePointer(to: bytes) { bufPtr in
      hash(bufPtr: bufPtr, count: bytes.count, tweak: tweak)  // NOT fix(..)
    }
  }

  /// Hash String, with optional tweak for avoiding consistency
  /// - Parameters:
  ///   - s: String
  ///   - tweak: UInt64 added to result for variability (defaults to 0)
  /// - Returns: UInt64 hash value
  public func hash(s: String, tweak: UInt64 = UInt64(0)) -> UInt64 {
    // no need to use `withUnsafePointer(to: s.utf8CString)`
    // https://developer.apple.com/documentation/swift/string/utf8view
    // says char*, but it handles [UInt8] (with correct count, presumably)
    withUnsafePointer(to: self.params) { paramPtr in
      return polymur_hash(s, s.utf8CString.count, paramPtr, fix(tweak))
    }
  }

  private func fix(_ input: UInt64) -> UInt64 {
    0 != input ? input : tweak0
  }
}

// MARK: Int-compatible API for Hashable
extension PolymurHasher {
  /// Check that this can produce Int hashes (i.e., when Int is 64 bits)
  /// - Returns: True when `hashi`-named functions should work.
  public static func canReturnInt() -> Bool {
    Int.bitWidth == UInt64.bitWidth
  }

  /// Int-returning form of ``hash(bufPtr:count:tweak:)``, usable when ``canReturnInt()``
  /// - Parameters:
  ///   - bufPtr: UnsafePointer to UInt8
  ///   - count: number of elements to hash (expect crash if beyond actual buffer)
  ///   - tweak: UInt64 added to result for variability (defaults to 0)
  /// - Returns: Int hash value
  public func hashInt(
    bufPtr: UnsafePointer<[UInt8]>,
    count: Int,
    tweak: UInt64 = UInt64(0)
  ) -> Int {
    let hash = hash(bufPtr: bufPtr, count: count, tweak: tweak)
    return Int(truncatingIfNeeded: hash)
  }

  /// Int-returning form of ``hash(bytes:tweak:)``, usable when ``canReturnInt()``
  /// - Parameters:
  ///   - buf: Array of UInt8
  ///   - tweak: UInt64 added to result for variability (defaults to 0)
  /// - Returns: Int hash value
  public func hashInt(bytes: [UInt8], tweak: UInt64 = UInt64(0)) -> Int {
    return Int(truncatingIfNeeded: hash(bytes: bytes, tweak: tweak))
  }

  /// Int-returning form of ``hash(s:tweak:)``, usable when ``canReturnInt()``
  /// - Parameters:
  ///   - s: String
  ///   - tweak: UInt64
  /// - Returns: Int hash value
  public func hashInt(s: String, tweak: UInt64 = UInt64(0)) -> Int {
    return Int(truncatingIfNeeded: hash(s: s, tweak: tweak))
  }

}

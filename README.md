# SwiftPolymurHash
- Swift wrapper for [polymur-hash](https://github.com/orlp/polymur-hash)
    - [polymur-hash discussion on HN](https://news.ycombinator.com/item?id=37176289)
 
## Usage
- See e.g., [PolymurHashTests](Tests/PolymurHashTests/PolymurHashTests.swift#L11)
- The tweak value provides some pseudo-variance to avoid hash attacks
    - But you can set it to zero or the same value to reproduce hashes
- It uses 5 UInt64's of state per hasher (including the default tweak value)

### Warning: combining with Swift's hasher isn't easy and may not be wise 
- Swift is not amenable to extrinsic hashing
    - Hashable.hashValue is deprecated
    - Hasher has no API for extrinsic values
- There are no guarantees that polymur hashes will combine well with Swift hashes 
- So perhaps restrict usage to top-level types
- See  [SE-206](https://github.com/apple/swift-evolution/blob/main/proposals/0206-hashable-enhancements.md)

## Development
- polymur-hash.h is manually copied from its source repository
    - also demo.c is from main.c, with main function renamed
    - Update PolymurHash.VERSION in swift when updating sources
- Untested except on macOS
    - TODO: verify swift compiler reduces to same/similar assembly as clang
    - No need to link with m (math) library on Linux, et al?
      - `linkerSettings: [.linkedLibrary("m", .when(platforms: [.linux]))]`
- 2 known warnings
    - test code deprecation for `Hashable.hashValue`
    - c code `Implicit conversion loses integer precision`

## Legal
- Copyright authors, All Rights Reserved
- polymur-hash is subject to its license and copyright
- This wrapper project is released under an MIT license.

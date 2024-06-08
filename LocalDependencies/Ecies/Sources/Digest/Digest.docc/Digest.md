# ``Digest``

Digest and random number utilities

## Overview

The Digest package provides the following functionality:

* Message Digest algorithms - SHA1, SHA2 and SHA3
* Extendable Output Functions - SHAKE and XOF
* Hash Based Message Authentication Codes - HMAC
* Key Derivation Functions - HKDF and X963KDF
* Mask Generation Function - MGF1
* Random number generation using the Mersenne Twister algorithm

### Message Digest

Message digesting is a three step operation.

**Example**

```swift
import Digest

// 1. create the message digest instance
let md = MessageDigest(.SHA3_224)

// 2. feed the data to digest in one or more steps
md.update([1, 2, 3])
md.update([4, 5, 6])

// 3. compute the digest
let digest1 = md.digest()

// The steps can be combined
let digest2 = MessageDigest(.SHA3_224).digest([1, 2, 3, 4, 5, 6])

print("digest1:", digest1)
print("digest2:", digest2)
```
giving:

```swift
digest1: [62, 55, 233, 98, 97, 184, 219, 20, 116, 115, 238, 1, 51, 166, 35, 107, 203, 162, 84, 97, 158, 122, 189, 59, 178, 19, 16, 201]
digest2: [62, 55, 233, 98, 97, 184, 219, 20, 116, 115, 238, 1, 51, 166, 35, 107, 203, 162, 84, 97, 158, 122, 189, 59, 178, 19, 16, 201]
```

### SHAKE and XOF

``Digest/SHAKE`` and ``Digest/XOF`` are extendable output functions which can generate output of any desired length based on a given seed.

**SHAKE 128 example**

```swift
import Digest

let shake = SHAKE(.SHAKE128)
shake.update([1, 2, 3])
print(shake.digest(25))
```
    
giving:

```swift
[218, 239, 167, 7, 93, 32, 41, 187, 214, 105, 12, 86, 166, 83, 123, 154, 218, 108, 92, 47, 146, 196, 24, 130, 197]
```

If you know you need 25 bytes of output, you must request them all at once,
`digest(12)` followed by `digest(13)` won't work, because the `digest` method resets `shake` to its original state.

**XOF 128 example**

```swift
import Digest

let xof = XOF(.XOF128, [1, 2, 3])
var z: Bytes = []
for _ in 0 ..< 25 {
    z += xof.read(1)
}
print(z)
```

giving:

```swift
[218, 239, 167, 7, 93, 32, 41, 187, 214, 105, 12, 86, 166, 83, 123, 154, 218, 108, 92, 47, 146, 196, 24, 130, 197]
```

XOF is similar to SHAKE, but as the examples show, the XOF `read` method can be called many times to accumulate the total amount of output.
XOF has no `update` method, the initial seed must be supplied in the constructor.

### Message Authentication Codes

Using ``Digest/HMAC`` to generate a message authentication code is a three step operation.

**Example**

```swift
import Digest

// 1. create the HMAC instance with a specified message digest and secret key
let hmac = HMAC(.SHA2_256, [1, 2, 3, 4, 5, 6])

// 2. update the HMAC instance with the text to compute the code for
hmac.update([1, 2, 3])

// 3. compute the code
let code = hmac.compute()
print(code)
```
giving:
```swift
[165, 171, 8, 206, 249, 140, 216, 179, 11, 30, 187, 136, 116, 132, 141, 34, 66, 169, 175, 107, 27, 31, 84, 190, 108, 60, 61, 222, 233, 97, 15, 247]
```

### Key Derivation Functions

A key derivation function generates a symmetric key from a shared secret. There are two key derivation functions:

* HKDF as specified in [RFC 5859]
* X963KDF as specified in [SEC 1].

Both are static methods in the ``Digest/KDF`` structure.

**Example**

```swift
import Digest

let key1 = KDF.HKDF(.SHA2_224, [1, 2, 3, 4, 5, 6, 7, 8], 12, [1, 2, 3], [])
print("HKDF key   ", key1)

let key2 = KDF.X963KDF(.SHA2_224, [1, 2, 3, 4, 5, 6, 7, 8], 12, [1, 2, 3])
print("X963KDF key", key2)
```
giving:
```swift
HKDF key    [209, 96, 93, 84, 150, 249, 149, 185, 105, 184, 47, 210]
X963KDF key [110, 88, 12, 176, 49, 119, 151, 82, 163, 233, 226, 9]
```

### Mask Generation Function

The mask generation function MGF1 as specified in [RFC 8017], is a static method in the ``Digest/KDF`` structure.  
It generates a mask of a specified size from a specified message digest and seed.

**Example**

```swift
import Digest

let mask = KDF.MGF1(.SHA1, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 12)
print(mask)
```
giving:
```swift
[224, 166, 61, 124, 140, 77, 129, 205, 28, 5, 103, 191]
```

### Random Numbers

The MT class generates random numbers. There are two MT versions:

* One that uses the 32 bit Mersenne Twister algorithm
* One that uses the 64 bit Mersenne Twister algorithm

MT conforms to the `RandomNumberGenerator` protocol. It generates:

* Random bits
* Random integers in a specified open or closed interval
* Random unsigned integers in a specified open or closed interval
* Random floating point values in a specified open or closed interval

A generator instance must be instantiated either with a randomly generated seed value or with a specified seed or seed array.
The sequence of generated numbers is deterministic and depends solely on the initial seed.

The internal state of a generator instance can be saved with the `getState` method and reinstated later with the `setState` method.

**Example 1**

```swift
import Digest

// 32 bit version, randomly generated seed
let mt32 = MT(kind: .MT32)

let theState = mt32.getState()
for _ in 0 ..< 3 {
  print(mt32.randomInt(in: 0 ..< 100))
}
mt32.setState(state: theState)
print("After reinstate")
for _ in 0 ..< 3 {
  print(mt32.randomInt(in: 0 ..< 100))
}
```
giving (for example):
```swift
24
75
33
After reinstate
24
75
33
```

**Example 2**

```swift
import Digest

// 64 bit version, seed array = [123, 456, 789]
let mt64 = MT(kind: .MT64, seed: [123, 456, 789])

for _ in 0 ..< 10 {
    print(mt64.randomInt(in: -1000 ... 1000))
}
```
giving:
```swift
781
570
-403
29
-924
-368
553
-60
989
418
```

> Important:
`MT` is not suitable for cryptographic applications.

### Usage

To use Digest, in your project Package.swift file add a dependency like

```swift
dependencies: [
  package(url: "https://github.com/leif-ibsen/Digest", from: "1.6.0"),
]
```

Digest itself does not depend on other packages.

> Important:
Digest requires Swift 5.0. It also requires that the `Int` and `UInt` types be 64 bit types.

## Topics

### Classes

- ``Digest/MessageDigest``
- ``Digest/MT``

### Structures

- ``Digest/HMAC``
- ``Digest/KDF``
- ``Digest/SHAKE``
- ``Digest/XOF``

### Type Aliases

- ``Digest/Byte``
- ``Digest/Bytes``

### Additional Information

- <doc:References>

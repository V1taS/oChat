//
//  MT32.swift
//  DigestTest
//
//  Created by Leif Ibsen on 09/04/2024.
//

import Foundation

struct MT32: MTProtocol {
    
    static let N = 624
    
    static let D26 = Double(1 << 26)
    static let D32 = Double(1 << 32)
    static let D53 = Double(1 << 53)
    static let D53_1 = Double(1 << 53 - 1)

    var X: [UInt32]
    var w: Int
    
    init() {
        var seed = [UInt32](repeating: 0, count: MT32.N)
        guard SecRandomCopyBytes(kSecRandomDefault, 4 * seed.count, &seed) == errSecSuccess else {
            fatalError("random failed")
        }
        self.init(seed)
    }
    
    init(_ seed: UInt32) {
        self.X = [UInt32](repeating: 0, count: MT32.N)
        self.w = MT32.N
        self.X[0] = seed
        for i in 1 ..< MT32.N {
            self.X[i] = 1812433253
            self.X[i] &*= self.X[i - 1] ^ (self.X[i - 1] >> 30)
            self.X[i] &+= UInt32(i)
        }
    }

    init(_ seed: [UInt32]) {
        self.init(UInt32(19650218))
        var i = 1
        var j = 0
        var k = MT32.N > seed.count ? MT32.N : seed.count
        while k > 0 {
            self.X[i] ^= (self.X[i - 1] ^ (self.X[i - 1] >> 30)) &* 1664525
            self.X[i] &+= seed[j]
            self.X[i] &+= UInt32(j)
            i += 1
            j += 1
            if i >= MT32.N {
                self.X[0] = self.X[MT32.N - 1]
                i = 1
            }
            if j >= seed.count {
                j = 0
            }
            k -= 1
        }
        k = MT32.N - 1
        while k > 0 {
            self.X[i] ^= (self.X[i - 1] ^ (self.X[i - 1] >> 30)) &* 1566083941
            self.X[i] &-= UInt32(i)
            i += 1
            if i >= MT32.N {
                self.X[0] = self.X[MT32.N - 1]
                i = 1
            }
            k -= 1
        }
        self.X[0] = 0x80000000
    }
    
    init(_ seed: UInt64) {
        fatalError("init(UInt64)")
    }
    
    init(_ seed: [UInt64]) {
        fatalError("init([UInt64])")
    }

    mutating func twist() {
        for i in 0 ..< MT32.N {
            let tmp = (self.X[i] & 0x80000000) &+ (self.X[(i + 1) % MT32.N] & 0x7fffffff)
            var tmpA = tmp >> 1
            if tmp & 1 == 1 {
                tmpA ^= 0x9908B0df
            }
            self.X[i] = self.X[(i + 397) % MT32.N] ^ tmpA
        }
        self.w = 0
    }

    mutating func next32() -> UInt32 {
        if self.w == MT32.N {
            self.twist()
        }
        var y = self.X[self.w]
        y ^= y >> 11
        y ^= (y << 7) & 0x9d2c5680
        y ^= (y << 15) & 0xefc60000
        y ^= y >> 18
        self.w += 1
        return y
    }
    
    mutating func next() -> UInt64 {
        return UInt64(self.next32()) << 32 | UInt64(self.next32())
    }
    
    mutating func nextBit() -> Bool {
        return self.next32() & 1 == 1
    }
    
    // Double value in 0.0 ..< 1.0 or 0.0 ... 1.0
    mutating func nextDouble(open: Bool) -> Double {
        return (Double(self.next32() >> 5) * MT32.D26 + Double(self.next32() >> 6)) / (open ? MT32.D53 : MT32.D53_1)
    }
    
    func getState() -> Bytes {
        var state = Bytes(repeating: 0, count: 2 + 4 * MT32.N)
        state[0] = Byte(self.w & 0xff)
        state[1] = Byte((self.w >> 8) & 0xff)
        var i4 = 0
        for i in 0 ..< self.X.count {
            state[2 + i4] = Byte(self.X[i] & 0xff)
            state[3 + i4] = Byte(self.X[i] >> 8 & 0xff)
            state[4 + i4] = Byte(self.X[i] >> 16 & 0xff)
            state[5 + i4] = Byte(self.X[i] >> 24 & 0xff)
            i4 += 4
        }
        return state
    }

    mutating func setState(_ state: Bytes) {
        if state.count == 2 + 4 * MT32.N {
            let W = Int(state[1]) << 8 | Int(state[0])
            if W <= MT32.N {
                self.w = W
                var i4 = 0
                for i in 0 ..< self.X.count {
                    self.X[i] = UInt32(state[2 + i4])
                    self.X[i] |= UInt32(state[3 + i4]) << 8
                    self.X[i] |= UInt32(state[4 + i4]) << 16
                    self.X[i] |= UInt32(state[5 + i4]) << 24
                    i4 += 4
                }
            }
        }
    }

}

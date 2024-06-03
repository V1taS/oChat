//
//  MT64.swift
//  DigestTest
//
//  Created by Leif Ibsen on 09/04/2024.
//

import Foundation

struct MT64: MTProtocol {
    
    static let N = 312

    static let D53 = Double(1 << 53)
    static let D53_1 = Double(1 << 53 - 1)

    var X: [UInt64]
    var w: Int
    
    init() {
        var seed = [UInt64](repeating: 0, count: MT64.N)
        guard SecRandomCopyBytes(kSecRandomDefault, 8 * seed.count, &seed) == errSecSuccess else {
            fatalError("random failed")
        }
        self.init(seed)
    }
    
    init(_ seed: UInt64) {
        self.X = [UInt64](repeating: 0, count: MT64.N)
        self.w = MT64.N
        self.X[0] = seed
        for i in 1 ..< MT64.N {
            self.X[i] = 6364136223846793005
            self.X[i] &*= self.X[i - 1] ^ (self.X[i - 1] >> 62)
            self.X[i] &+= UInt64(i)
        }
    }

    init(_ seed: [UInt64]) {
        self.init(UInt64(19650218))
        var i = 1
        var j = 0
        var k = MT64.N > seed.count ? MT64.N : seed.count
        while k > 0 {
            self.X[i] ^= (self.X[i - 1] ^ (self.X[i - 1] >> 62)) &* 3935559000370003845
            self.X[i] &+= seed[j]
            self.X[i] &+= UInt64(j)
            i += 1
            j += 1
            if i >= MT64.N {
                self.X[0] = self.X[MT64.N - 1]
                i = 1
            }
            if j >= seed.count {
                j = 0
            }
            k -= 1
        }
        k = MT64.N - 1
        while k > 0 {
            self.X[i] ^= (self.X[i - 1] ^ (self.X[i - 1] >> 62)) &* 2862933555777941757
            self.X[i] &-= UInt64(i)
            i += 1
            if i >= MT64.N {
                self.X[0] = self.X[MT64.N - 1]
                i = 1
            }
            k -= 1
        }
        self.X[0] = 0x8000000000000000
    }
    
    init(_ seed: UInt32) {
        fatalError("init(UInt32)")
    }
    
    init(_ seed: [UInt32]) {
        fatalError("init([UInt32])")
    }

    mutating func twist() {
        for i in 0 ..< MT64.N {
            let tmp = (self.X[i] & 0xffffffff80000000) &+ (self.X[(i + 1) % MT64.N] & 0x7fffffff)
            var tmpA = tmp >> 1
            if tmp & 1 == 1 {
                tmpA ^= 0xb5026f5aa96619e9
            }
            self.X[i] = self.X[(i + 156) % MT64.N] ^ tmpA
        }
        self.w = 0
    }

    mutating func next64() -> UInt64 {
        if self.w == MT64.N {
            self.twist()
        }
        var y = self.X[self.w]
        y ^= (y >> 29) & 0x5555555555555555
        y ^= (y << 17) & 0x71d67fffeda60000
        y ^= (y << 37) & 0xfff7eee000000000
        y ^= y >> 43
        self.w += 1
        return y
    }
    
    mutating func next() -> UInt64 {
        return self.next64()
    }
    
    mutating func nextBit() -> Bool {
        return self.next64() & 1 == 1
    }

    // Double value in 0.0 ..< 1.0 or 0.0 ... 1.0
    mutating func nextDouble(open: Bool) -> Double {
        return Double(self.next64() >> 11) / (open ? MT64.D53 : MT64.D53_1)
    }

    func getState() -> Bytes {
        var state = Bytes(repeating: 0, count: 2 + 8 * MT64.N)
        state[0] = Byte(self.w & 0xff)
        state[1] = Byte((self.w >> 8) & 0xff)
        var i8 = 0
        for i in 0 ..< self.X.count {
            state[2 + i8] = Byte(self.X[i] & 0xff)
            state[3 + i8] = Byte(self.X[i] >> 8 & 0xff)
            state[4 + i8] = Byte(self.X[i] >> 16 & 0xff)
            state[5 + i8] = Byte(self.X[i] >> 24 & 0xff)
            state[6 + i8] = Byte(self.X[i] >> 32 & 0xff)
            state[7 + i8] = Byte(self.X[i] >> 40 & 0xff)
            state[8 + i8] = Byte(self.X[i] >> 48 & 0xff)
            state[9 + i8] = Byte(self.X[i] >> 56 & 0xff)
            i8 += 8
        }
        return state
    }

    mutating func setState(_ state: Bytes) {
        if state.count == 2 + 8 * MT64.N {
            let W = Int(state[1]) << 8 | Int(state[0])
            if W <= MT64.N {
                self.w = W
                var i8 = 0
                for i in 0 ..< self.X.count {
                    self.X[i] = UInt64(state[2 + i8])
                    self.X[i] |= UInt64(state[3 + i8]) << 8
                    self.X[i] |= UInt64(state[4 + i8]) << 16
                    self.X[i] |= UInt64(state[5 + i8]) << 24
                    self.X[i] |= UInt64(state[6 + i8]) << 32
                    self.X[i] |= UInt64(state[7 + i8]) << 40
                    self.X[i] |= UInt64(state[8 + i8]) << 48
                    self.X[i] |= UInt64(state[9 + i8]) << 56
                    i8 += 8
                }
            }
        }
    }

}

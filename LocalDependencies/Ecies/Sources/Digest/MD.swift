//
//  MessageDigest.swift
//  SwiftDigestTest
//
//  Created by Leif Ibsen on 24/11/2023.
//

typealias Word = UInt32
typealias Words = [UInt32]
typealias Limb = UInt64
typealias Limbs = [UInt64]

protocol MDImplementation {
    func doBuffer(_ buffer: inout Bytes, _ hw: inout Words, _ hl: inout Limbs)
    func doReset(_ hw: inout Words, _ hl: inout Limbs)
    func padding(_ totalBytes: Int, _ blockSize: Int) -> Bytes
}

/// Unsigned 8 bit value
public typealias Byte = UInt8

/// Array of unsigned 8 bit values
public typealias Bytes = [UInt8]

/// The MessageDigest class
public class MessageDigest {

    /// The message digest algorithms
    public enum Kind: CaseIterable {
        
        /// SHA1 Message Digest
        case SHA1

        /// SHA2-224 Message Digest
        case SHA2_224

        /// SHA2-256 Message Digest
        case SHA2_256
        
        /// SHA2-384 Message Digest
        case SHA2_384
        
        /// SHA2-512 Message Digest
        case SHA2_512
        
        /// SHA3-224 Message Digest
        case SHA3_224
        
        /// SHA3-256 Message Digest
        case SHA3_256
        
        /// SHA3-384 Message Digest
        case SHA3_384
        
        /// SHA3-512 Message Digest
        case SHA3_512
    }

    let impl: MDImplementation
    let keccak: Bool
    var totalBytes: Int
    var bytes: Int
    var buffer: Bytes
    var hw: Words
    var hl: Limbs
    var S: Bytes

    init() {
        // SHA3-128
        self.impl = SHA3()
        self.keccak = true
        self.digestLength = 16
        self.buffer = Bytes(repeating: 0, count: 168)
        self.hw = Words(repeating: 0, count: 0)
        self.hl = Limbs(repeating: 0, count: 0)
        self.S = Bytes(repeating: 0, count: 200)
        self.totalBytes = 0
        self.bytes = 0
        self.impl.doReset(&self.hw, &self.hl)
    }

    
    // MARK: Initializer

    /// Constructs a Message Digest of a specified kind
    ///
    /// - Parameters:
    ///   - kind: The message digest kind
    public init(_ kind: Kind) {
        switch kind {
        case .SHA1:
            self.impl = SHA1()
            self.keccak = false
            self.digestLength = 20
            self.buffer = Bytes(repeating: 0, count: 64)
            self.hw = Words(repeating: 0, count: 5)
            self.hl = Limbs(repeating: 0, count: 0)
            self.S = Bytes(repeating: 0, count: 0)
        case .SHA2_224:
            self.impl = SHA2_256(true)
            self.keccak = false
            self.digestLength = 28
            self.buffer = Bytes(repeating: 0, count: 64)
            self.hw = Words(repeating: 0, count: 8)
            self.hl = Limbs(repeating: 0, count: 0)
            self.S = Bytes(repeating: 0, count: 0)
        case .SHA2_256:
            self.impl = SHA2_256(false)
            self.keccak = false
            self.digestLength = 32
            self.buffer = Bytes(repeating: 0, count: 64)
            self.hw = Words(repeating: 0, count: 8)
            self.hl = Limbs(repeating: 0, count: 0)
            self.S = Bytes(repeating: 0, count: 0)
        case .SHA2_384:
            self.impl = SHA2_512(true)
            self.keccak = false
            self.digestLength = 48
            self.buffer = Bytes(repeating: 0, count: 128)
            self.hw = Words(repeating: 0, count: 0)
            self.hl = Limbs(repeating: 0, count: 8)
            self.S = Bytes(repeating: 0, count: 0)
        case .SHA2_512:
            self.impl = SHA2_512(false)
            self.keccak = false
            self.digestLength = 64
            self.buffer = Bytes(repeating: 0, count: 128)
            self.hw = Words(repeating: 0, count: 0)
            self.hl = Limbs(repeating: 0, count: 8)
            self.S = Bytes(repeating: 0, count: 0)
        case .SHA3_224:
            self.impl = SHA3()
            self.keccak = true
            self.digestLength = 28
            self.buffer = Bytes(repeating: 0, count: 144)
            self.hw = Words(repeating: 0, count: 0)
            self.hl = Limbs(repeating: 0, count: 0)
            self.S = Bytes(repeating: 0, count: 200)
        case .SHA3_256:
            self.impl = SHA3()
            self.keccak = true
            self.digestLength = 32
            self.buffer = Bytes(repeating: 0, count: 136)
            self.hw = Words(repeating: 0, count: 0)
            self.hl = Limbs(repeating: 0, count: 0)
            self.S = Bytes(repeating: 0, count: 200)
        case .SHA3_384:
            self.impl = SHA3()
            self.keccak = true
            self.digestLength = 48
            self.buffer = Bytes(repeating: 0, count: 104)
            self.hw = Words(repeating: 0, count: 0)
            self.hl = Limbs(repeating: 0, count: 0)
            self.S = Bytes(repeating: 0, count: 200)
        case .SHA3_512:
            self.impl = SHA3()
            self.keccak = true
            self.digestLength = 64
            self.buffer = Bytes(repeating: 0, count: 72)
            self.hw = Words(repeating: 0, count: 0)
            self.hl = Limbs(repeating: 0, count: 0)
            self.S = Bytes(repeating: 0, count: 200)
        }
        self.totalBytes = 0
        self.bytes = 0
        self.impl.doReset(&self.hw, &self.hl)
    }


    // MARK: Stored properties
    
    /// The digest length
    public internal(set) var digestLength: Int


    // MARK: Methods

    /// Resets `self` to its original state
    public func reset() {
        for i in 0 ..< self.buffer.count {
            self.buffer[i] = 0
        }
        for i in 0 ..< self.S.count {
            self.S[i] = 0
        }
        self.totalBytes = 0
        self.bytes = 0
        self.impl.doReset(&self.hw, &self.hl)
    }

    /// Digests more data
    ///
    /// - Parameters:
    ///   - data: Data to digest
    public func update(_ data: Bytes) {
        var remaining = data.count
        var ndx = 0
        while remaining > 0 {
            let a = remaining < self.buffer.count - self.bytes ? remaining : self.buffer.count - self.bytes
            for i in 0 ..< a {
                self.buffer[self.bytes + i] = data[ndx + i]
            }
            self.bytes += a
            ndx += a
            remaining -= a
            if self.bytes == self.buffer.count {
                if self.keccak {
                    for i in 0 ..< self.buffer.count {
                        self.S[i] ^= self.buffer[i]
                    }
                    self.impl.doBuffer(&self.S, &self.hw, &self.hl)
                } else {
                    self.impl.doBuffer(&self.buffer, &self.hw, &self.hl)
                }
                self.bytes = 0
            }
        }
        self.totalBytes += data.count
    }

    /// Computes the digest value and resets `self` to its original state
    ///
    /// - Parameters:
    ///   - data: Data to digest before the digest value is computed - an empty array is default
    /// - Returns: The digest value
    public func digest(_ data: Bytes = []) -> Bytes {
        self.update(data)
        var md = Bytes(repeating: 0, count: self.digestLength)
        update(self.impl.padding(self.totalBytes, self.buffer.count))
        if self.keccak {
            var Z = Bytes(repeating: 0, count: 0)
            while true {
                for i in 0 ..< self.buffer.count {
                    Z.append(S[i])
                }
                if Z.count < self.digestLength {
                    self.impl.doBuffer(&self.S, &self.hw, &self.hl)
                } else {
                    for i in 0 ..< self.digestLength {
                        md[i] = Z[i]
                    }
                    break
                }
            }
        } else if self.digestLength > 32 {
                
            // SHA2_384 and SHA2_512
                
            for i in 0 ..< self.digestLength {
                md[i] = Byte((self.hl[i >> 3] >> ((7 - (i & 0x7)) * 8)) & 0xff)
            }
        } else {
            
            // SHA1, SHA2_224 and SHA2_256

            for i in 0 ..< self.digestLength {
                md[i] = Byte((self.hw[i >> 2] >> ((3 - (i & 0x3)) * 8)) & 0xff)
            }
        }
        self.reset()
        return md
    }
    
    func doBuffer() {
        self.impl.doBuffer(&self.S, &self.hw, &self.hl)
    }

}

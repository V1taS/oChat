//
//  HMAC.swift
//  SwiftDigestTest
//
//  Created by Leif Ibsen on 24/11/2023.
//

/// The HMAC structure
public struct HMAC {
    
    static let OPAD = Byte(0x5c)
    static let IPAD = Byte(0x36)
    
    let md: MessageDigest
    let blockSize: Int
    var iKeyPad: Bytes = []
    var oKeyPad: Bytes = []
    

    // MARK: - Initializer

    /// Constructs a HMAC instance
    ///
    /// - Parameters:
    ///   - kind: The kind of message digest algorithm to use
    ///   - key: The key to use
    public init(_ kind: MessageDigest.Kind, _ key: Bytes) {
        self.md = MessageDigest(kind)
        self.blockSize = self.md.buffer.count
        self.initialize(key)
    }
    
    mutating func initialize(_ key: Bytes) {
        var macKey = Bytes(repeating: 0, count: self.blockSize)
        if key.count > self.blockSize {
            self.md.update(key)
            let x = self.md.digest()
            for i in 0 ..< x.count {
                macKey[i] = x[i]
            }
        } else {
            for i in 0 ..< key.count {
                macKey[i] = key[i]
            }
        }
        self.iKeyPad = Bytes(repeating: 0, count: self.blockSize)
        self.oKeyPad = Bytes(repeating: 0, count: self.blockSize)
        for i in 0 ..< self.blockSize {
            self.iKeyPad[i] = macKey[i] ^ HMAC.IPAD
            self.oKeyPad[i] = macKey[i] ^ HMAC.OPAD
        }
        self.reset()
    }
    

    // MARK: Methods

    /// Resets `self` to its original state
    public func reset() {
        self.md.reset()
        self.md.update(self.iKeyPad)
    }

    /// Digests more data
    ///
    /// - Parameters:
    ///   - data: Data to digest
    public func update(_ data: Bytes) {
        self.md.update(data)
    }

    /// Computes the message authentication code and resets `self` to its original state
    ///
    /// - Parameters:
    ///   - data: Data to digest before the message authentication code is computed - an empty array is default
    /// - Returns: The message authentication code
    public func compute(_ data: Bytes = []) -> Bytes {
        self.md.update(data)
        let b = self.md.digest()
        self.md.update(oKeyPad)
        self.md.update(b)
        let result = self.md.digest()
        self.reset()
        return result
    }

}

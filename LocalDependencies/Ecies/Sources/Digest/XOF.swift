//
//  File.swift
//  
//
//  Created by Leif Ibsen on 28/11/2023.
//

class XOFimpl {
    
    let sha3: MessageDigest
    var buffer: Bytes
    var ndx: Int
    
    init(_ sha3: MessageDigest, _ seed: Bytes) {
        self.sha3 = sha3
        self.sha3.update(seed)
        var padBytes = Bytes(repeating: 0, count: self.sha3.buffer.count - self.sha3.bytes % self.sha3.buffer.count)
        padBytes[0] = 0x1f
        padBytes[padBytes.count - 1] |= 0x80
        self.sha3.update(padBytes)
        self.buffer = Bytes(self.sha3.S[0 ..< self.sha3.buffer.count])
        self.ndx = 0
    }
    
    func read(_ length: Int) -> Bytes {
        var x = Bytes(repeating: 0, count: length)
        self.read(&x)
        return x
    }
    
    func read(_ x: inout Bytes) {
        for i in 0 ..< x.count {
            if self.ndx == self.buffer.count {
                self.sha3.doBuffer()
                self.buffer = Bytes(self.sha3.S[0 ..< self.buffer.count])
                self.ndx = 0
            }
            x[i] = self.buffer[self.ndx]
            self.ndx += 1
        }
    }
    
}

/// The XOF structure
public struct XOF {
    
    /// The XOF kinds
    public enum Kind: CaseIterable {
        
        /// XOF128
        case XOF128

        /// XOF256
        case XOF256

    }

    let xof: XOFimpl
    

    // MARK: - Initializer

    /// Constructs a XOF instance of a specified kind
    ///
    /// - Parameters:
    ///   - kind: The XOF kind, `.XOF128` or `.XOF256`
    ///   - seed: The seed the XOF is based on
    public init(_ kind: Kind, _ seed: Bytes) {
        self.xof = kind == .XOF128 ? XOFimpl(MessageDigest( /* SHA3-128 */ ), seed) : XOFimpl(MessageDigest(.SHA3_256), seed)
    }
    

    // MARK: Methods

    /// Reads bytes from `self`
    ///
    /// - Parameters:
    ///   - size: The size of the returned value
    /// - Returns: The next `size` bytes
    public func read(_ size: Int) -> Bytes {
        return xof.read(size)
    }

    /// Reads bytes from `self`
    ///
    /// - Parameters:
    ///   - buffer: Gets filled with the next `buffer.count` bytes
    public func read(_ buffer: inout Bytes) {
        self.xof.read(&buffer)
    }

}

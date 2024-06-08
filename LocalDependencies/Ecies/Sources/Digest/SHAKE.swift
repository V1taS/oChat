//
//  File.swift
//  
//
//  Created by Leif Ibsen on 28/11/2023.
//

struct SHAKEimpl {
 
    let sha3: MessageDigest
    
    init(_ sha3: MessageDigest) {
        self.sha3 = sha3
    }

    func update(_ data: Bytes) {
        self.sha3.update(data)
    }

    // FIPS202 - algorithm 8
    func digest(_ n: Int) -> Bytes {
        assert(n >= 0)
        var padBytes = Bytes(repeating: 0, count: self.sha3.buffer.count - self.sha3.bytes % self.sha3.buffer.count)
        padBytes[0] = 0x1f
        padBytes[padBytes.count - 1] |= 0x80
        self.update(padBytes)
        
        assert(self.sha3.totalBytes % self.sha3.buffer.count == 0)

        var Z: Bytes = []
        while Z.count < n {
            Z += Bytes(self.sha3.S[0 ..< self.sha3.buffer.count])
            self.sha3.doBuffer()
        }
        self.sha3.reset()
        return Bytes(Z[0 ..< n])
    }

}

/// The SHAKE structure
public struct SHAKE {
    
    /// The SHAKE kinds
    public enum Kind: CaseIterable {
        
        /// SHAKE128
        case SHAKE128

        /// SHAKE256
        case SHAKE256

    }

    let shake: SHAKEimpl
    
    
    // MARK: - Initializer

    /// Constructs a SHAKE instance of a specified kind
    ///
    /// - Parameters:
    ///   - kind: The SHAKE kind, `.SHAKE128` or `.SHAKE256`
    public init(_ kind: Kind) {
        self.shake = kind == .SHAKE128 ? SHAKEimpl(MessageDigest( /* SHA3-128 */ )) : SHAKEimpl(MessageDigest(.SHA3_256))
    }
    

    // MARK: Methods

    /// Digest more data
    ///
    /// - Parameters:
    ///   - data: Data to digest
    public func update(_ data: Bytes) {
        self.shake.update(data)
    }

    /// Computes the digest value and resets `self` to its original state
    ///
    /// - Parameters:
    ///   - size: The size of the digest value
    /// - Returns: The digest value
    public func digest(_ size: Int) -> Bytes {
        return self.shake.digest(size)
    }

}

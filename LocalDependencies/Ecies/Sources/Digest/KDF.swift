//
//  File.swift
//  
//
//  Created by Leif Ibsen on 30/11/2023.
//

/// The KDF structure
public struct KDF {
    
    private init() {
        /* Not meant to be instantiated */
    }
    

    // MARK: Methods

    /// The HKDF key derivation function from [RFC 5869].
    ///
    /// Derives a symmetric key from a shared secret.
    ///
    /// - Precondition: 0 < `size` and `size` <= digestLength \* 255
    /// - Parameters:
    ///   - kind: The kind of message digest algorithm to use
    ///   - ikm: The shared secret
    ///   - size: The required length of the key
    ///   - info: Information shared with the other party - possibly none
    ///   - salt: Salt to use - possibly none
    /// - Returns: A byte array which is the symmetric key
    public static func HKDF(_ kind: MessageDigest.Kind, _ ikm: Bytes, _ size: Int, _ info: Bytes, _ salt: Bytes) -> Bytes {
        var hmac = HMAC(kind, salt)
        let dl = hmac.md.digestLength
        precondition(size > 0 && size <= 255 * dl)
        let prk = hmac.compute(ikm)
        let n = (size + dl) / dl
        hmac = HMAC(kind, prk)
        var T: Bytes = []
        var t: Bytes = []
        for i in 1 ... n {
            t = hmac.compute(t + info + [Byte(i)])
            T += t
        }
        return Bytes(T[0 ..< size])
    }

    /// The ANS X9.63 key derivation function from [SEC 1] section 3.6.1.
    ///
    /// Derives a symmetric key from a shared secret.
    ///
    /// - Precondition: 0 <= `size` and `size` <= digestLength \* (2^32 - 1)
    /// - Parameters:
    ///   - kind: The kind of message digest algorithm to use
    ///   - ikm: The shared secret
    ///   - size: The required length of the key
    ///   - info: Information shared with the other party - possibly none
    /// - Returns: A byte array which is the symmetric key
    public static func X963KDF(_ kind: MessageDigest.Kind, _ ikm: Bytes, _ size: Int, _ info: Bytes) -> Bytes {
        let md = MessageDigest(kind)
        precondition(size >= 0 && size < md.digestLength * 0xffffffff)
        var T: Bytes = []
        var counter: Bytes = [0, 0, 0, 1]
        let n = size == 0 ? 0 : (size - 1) / md.digestLength + 1
        for _ in 0 ..< n {
            md.update(ikm)
            md.update(counter)
            md.update(info)
            T += md.digest()
            counter[3] &+= 1
            if counter[3] == 0 {
                counter[2] &+= 1
                if counter[2] == 0 {
                    counter[1] &+= 1
                    if counter[1] == 0 {
                        counter[0] &+= 1
                    }
                }
            }
        }
        return Bytes(T[0 ..< size])
    }

    /// The Mask Generation Function from [RFC 8017].
    ///
    /// - Parameters:
    ///   - kind: The kind of message digest algorithm to use
    ///   - seed: The seed to generate the mask from
    ///   - size: The required length of the generated mask
    /// - Returns: The generated mask
    public static func MGF1(_ kind: MessageDigest.Kind, _ seed: Bytes, _ size: Int) -> Bytes {
        let md = MessageDigest(kind)
        var t: Bytes = []
        var counter: Bytes = [0, 0, 0, 0]
        let n = size == 0 ? 0 : (size - 1) / md.digestLength + 1
        for _ in 0 ..< n {
            md.update(seed)
            md.update(counter)
            let h = md.digest()
            t += h
            counter[3] &+= 1
            if counter[3] == 0 {
                counter[2] &+= 1
                if counter[2] == 0 {
                    counter[1] &+= 1
                    if counter[1] == 0 {
                        counter[0] &+= 1
                    }
                }
            }
        }
        return Bytes(t[0 ..< size])
    }

}

//
//  Mersenne.swift
//  MersenneTest
//
//  Created by Leif Ibsen on 18/04/2024.
//

public class MT: RandomNumberGenerator {
    
    /// The Mersenne Twister kinds
    public enum Kind: CaseIterable {
        
        /// 32 bit Mersenne Twister
        case MT32

        /// 64 bit Mersenne Twister
        case MT64

    }

    var MT: MTProtocol
    
    /// Constructs a Mersenne Twister based on a randomly generated seed
    ///
    /// - Parameters:
    ///   - kind: The Mersenne Twister kind, `.MT32` or `.MT64`
    public init(kind: Kind) {
        self.MT = kind == .MT32 ? MT32() : MT64()
    }

    /// Constructs a Mersenne Twister based on a seed
    ///
    /// - Parameters:
    ///   - kind: The Mersenne Twister kind, `.MT32` or `.MT64`
    ///   - seed: The seed
    public init(kind: Kind, seed: UInt) {
        self.MT = kind == .MT32 ? MT32(UInt32(seed & 0xffffffff)) : MT64(UInt64(seed))
    }

    /// Constructs a Mersenne Twister based on a seed array
    ///
    /// - Parameters:
    ///   - kind: The Mersenne Twister kind, `.MT32` or `.MT64`
    ///   - seed: The seed array
    public init(kind: Kind, seed: [UInt]) {
        if kind == .MT32 {
            var ss = [UInt32](repeating: 0, count: seed.count)
            for i in 0 ..< ss.count {
                ss[i] = UInt32(seed[i] & 0xffffffff)
            }
            self.MT = MT32(ss)
        } else {
            var ss = [UInt64](repeating: 0, count: seed.count)
            for i in 0 ..< ss.count {
                ss[i] = UInt64(seed[i])
            }
            self.MT = MT64(ss)
        }
    }

    /// Required by the `RandomNumberGenerator` protocol
    ///
    ///  - Returns: A random UInt64 value
    public func next() -> UInt64 {
        return self.MT.next()
    }

    /// Random bit
    ///
    /// - Returns: A random bit
    public func randomBit() -> Bool {
        return self.MT.nextBit()
    }

    // Open range
    
    /// Random integer value
    ///
    /// - Parameters:
    ///   - range: An open range
    /// - Returns: A random integer in the specified range
    public func randomInt(in range: Range<Int>) -> Int {
        return randomInt(in: range.lowerBound ... range.upperBound - 1)
    }

    /// Random 32 bit integer value
    ///
    /// - Parameters:
    ///   - range: An open range
    /// - Returns: A random 32 bit integer in the specified range
    public func randomInt(in range: Range<Int32>) -> Int32 {
        return randomInt(in: range.lowerBound ... range.upperBound - 1)
    }

    /// Random 64 bit integer value
    ///
    /// - Parameters:
    ///   - range: An open range
    /// - Returns: A random 64 bit integer in the specified range
    public func randomInt(in range: Range<Int64>) -> Int64 {
        return randomInt(in: range.lowerBound ... range.upperBound - 1)
    }

    /// Random unsigned integer value
    ///
    /// - Parameters:
    ///   - range: An open range
    /// - Returns: A random unsigned integer in the specified range
    public func randomUInt(in range: Range<UInt>) -> UInt {
        return randomUInt(in: range.lowerBound ... range.upperBound - 1)
    }
    
    /// Random unsigned 32 bit integer value
    ///
    /// - Parameters:
    ///   - range: An open range
    /// - Returns: A random unsigned 32 bit integer in the specified range
    public func randomUInt(in range: Range<UInt32>) -> UInt32 {
        return randomUInt(in: range.lowerBound ... range.upperBound - 1)
    }
    
    /// Random unsigned 64 bit integer value
    ///
    /// - Parameters:
    ///   - range: An open range
    /// - Returns: A random unsigned 64 bit integer in the specified range
    public func randomUInt(in range: Range<UInt64>) -> UInt64 {
        return randomUInt(in: range.lowerBound ... range.upperBound - 1)
    }

    // Closed range
    
    /// Random integer value
    ///
    /// - Parameters:
    ///   - range: A closed range
    /// - Returns: A random integer in the specified range
    public func randomInt(in range: ClosedRange<Int>) -> Int {
        if range.lowerBound == range.upperBound {
            return range.lowerBound
        }
        let n = 2 * (Double(range.upperBound) - Double(range.lowerBound))
        if n == 0.0 {

            // upperBound and lowerBound convert to the same Double value

            return range.lowerBound + randomInt(in: 0 ... range.upperBound - range.lowerBound)
        }
        let f = randomFloat(in: -1.0 / n ... (n + 1.0) / n)
        var x: Int
        if range.upperBound > 0 && range.lowerBound < 0 {
            x = Int(Double(range.lowerBound) + ((Double(range.upperBound) - Double(range.lowerBound)) * f).rounded(.toNearestOrEven))
        } else {
            x = range.lowerBound - Int((Double(range.lowerBound - range.upperBound) * f).rounded(.toNearestOrEven))
        }
        if x > range.upperBound {

            // May happen in extremely rare cases due to floating point rounding to even

            return range.upperBound
        } else if x < range.lowerBound {

            // May happen in extremely rare cases due to floating point rounding to even

            return range.lowerBound
        } else {
            return x
        }
    }

    /// Random 32 bit integer value
    ///
    /// - Parameters:
    ///   - range: A closed range
    /// - Returns: A random 32 bit integer in the specified range
    public func randomInt(in range: ClosedRange<Int32>) -> Int32 {
        return Int32(randomInt(in: Int(range.lowerBound) ... Int(range.upperBound)))
    }

    /// Random 64 bit integer value
    ///
    /// - Parameters:
    ///   - range: A closed range
    /// - Returns: A random 64 bit integer in the specified range
    public func randomInt(in range: ClosedRange<Int64>) -> Int64 {
        return Int64(randomInt(in: Int(range.lowerBound) ... Int(range.upperBound)))
    }

    /// Random unsigned integer value
    ///
    /// - Parameters:
    ///   - range: A closed range
    /// - Returns: A random unsigned integer in the specified range
    public func randomUInt(in range: ClosedRange<UInt>) -> UInt {
        if range.lowerBound == range.upperBound {
            return range.lowerBound
        }
        let n = 2 * (Double(range.upperBound - range.lowerBound))
        let f = randomFloat(in: -1.0 / n ... (n + 1.0) / n)
        let x = range.lowerBound + UInt((Double(range.upperBound - range.lowerBound) * f).rounded(.toNearestOrEven))
        if x > range.upperBound {

            // May happen in extremely rare cases due to floating point rounding to even

            return range.upperBound
        } else if x < range.lowerBound {

            // May happen in extremely rare cases due to floating point rounding to even

            return range.lowerBound
        } else {
            return x
        }
    }

    /// Random unsigned 32 bit integer value
    ///
    /// - Parameters:
    ///   - range: A closed range
    /// - Returns: A random unsigned 32 bit integer in the specified range
    public func randomUInt(in range: ClosedRange<UInt32>) -> UInt32 {
        return UInt32(randomUInt(in: UInt(range.lowerBound) ... UInt(range.upperBound)))
    }

    /// Random unsigned 64 bit integer value
    ///
    /// - Parameters:
    ///   - range: A closed range
    /// - Returns: A random unsigned 64 bit integer in the specified range
    public func randomUInt(in range: ClosedRange<UInt64>) -> UInt64 {
        return UInt64(randomUInt(in: UInt(range.lowerBound) ... UInt(range.upperBound)))
    }

    /// Random floating point value
    ///
    /// - Parameters:
    ///   - range: An open range
    /// - Returns: A random floating point value in the specified range
    public func randomFloat(in range: Range<Double>) -> Double {
        return range.lowerBound + (range.upperBound - range.lowerBound) * self.MT.nextDouble(open: true)
    }
    
    /// Random floating point value
    ///
    /// - Parameters:
    ///   - range: A closed range
    /// - Returns: A random floating point value in the specified range
    public func randomFloat(in range: ClosedRange<Double>) -> Double {
        return range.lowerBound + (range.upperBound - range.lowerBound) * self.MT.nextDouble(open: false)
    }

    /// Get the internal state
    ///
    /// - Returns:The internal state of *self* - 2498 bytes
    public func getState() -> Bytes {
        return self.MT.getState()
    }

    /// Reinstate the internal state
    ///
    /// - Parameters:
    ///   - state: The new internal state of *self* - must be a 2498 byte array
    public func setState(state: Bytes) {
        self.MT.setState(state)
    }

}

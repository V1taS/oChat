//
//  Protocol.swift
//  MersenneTest
//
//  Created by Leif Ibsen on 18/04/2024.
//

protocol MTProtocol {
    
    init()
    init(_ seed: UInt32)
    init(_ seed: [UInt32])
    init(_ seed: UInt64)
    init(_ seed: [UInt64])
    mutating func next() -> UInt64
    mutating func nextBit() -> Bool
    mutating func nextDouble(open: Bool) -> Double
    func getState() -> Bytes
    mutating func setState(_ state: Bytes)

}

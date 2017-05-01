//
//  ObjectIdentifier.swift
//  X509Certificate
//
//  Created by Richard McDuffey on 4/30/17.
//  Copyright © 2017 Richard McDuffey. All rights reserved.
//

import Foundation

class ObjectIdentifier {
    private(set) var oid: String
    
    lazy private(set) var bytes: [UInt8] = {
        print("called")
        var bytes: [UInt8] = []
        
        var values = self.oid.components(separatedBy: ".").flatMap({ Int($0) })
        
        let first = values.removeFirst()
        let second = values.removeFirst()
        var firstByte = 40 * first + second
        
        if firstByte > 0x80 {
            bytes.append(contentsOf: self.getBytes(firstByte))
        } else {
            bytes.append(UInt8(firstByte))
        }
        
        for sub in values {
            if sub > 0x80 {
                bytes.append(contentsOf: self.getBytes(sub))
            } else {
                bytes.append(UInt8(sub))
            }
        }
        
        let len =  UInt8(bytes.count)
        
        return [0x06, len] + bytes
    }()
    
    init(_ oid: String) {
        self.oid = oid
    }
    
    //performs long form encoding
    private func getBytes(_ value: Int) -> [UInt8] {
        var current = value
        var bytes: [UInt8] = []
        
        while current != 0 {
            var byte = current % 128
            if byte & 0x80 == 0 { //setting bit 8 to one if it is set to 0
                byte |= 0x80
            }
            current = current >> 7
            bytes.append(UInt8(byte))
        }
        
        var last = bytes.removeFirst()
        last = last & ~0x80 //set bit 8 of last byte to zero to signal end of sequence
        bytes.reverse() //place bytes in big-endian order
        bytes.append(last)
        
        return bytes
    }
}

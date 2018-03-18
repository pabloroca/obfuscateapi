//
//  AESKeyClass.swift
//  obfuscateapit
//
//  Created by Pablo Roca Rozas on 18/3/18.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import Foundation

extension String {
    private static let aesKeyData: [UInt8] =
        [
            0x9b, 0x63, 0xad, 0x14, 0x46, 0x1b, 0x5e, 0x7b, 0x6b, 0x65,
            0xa4, 0x89
    ]

    public func aesKey() -> String {
        let data = Data(bytes: UnsafePointer<UInt8>(type(of: self).aesKeyData), count: type(of: self).aesKeyData.count)
        return String(data: data, encoding: .utf8)!
    }
}

//
//  Crypto+Extensions.swift
//
// Copyright (c) 2018 by PR2Studio
//
// https://pr2studio.com
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import CommonCrypto

extension Data {
    fileprivate init?(fromHexString hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }

    /// AES128 generic encryption/decryption
    ///
    /// - Parameters:
    ///   - keyData: aes key, Data from String Hex String who applied first a MD5
    ///   - ivData: iv Data from Hex String
    ///   - operation: Int (kCCEncrypt / kCCDecrypt)
    /// - Returns: kCCDecrypt
    ///
    /// Note: You will need to import CommonCrypto
    public func aes(keyData: Data, ivData: Data, operation: Int) -> Data {
        let cryptLength = size_t(self.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)
        let keyLength = size_t(kCCKeySizeAES128)

        var numBytesProcessed: size_t = 0
        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            self.withUnsafeBytes {dataBytes in
                ivData.withUnsafeBytes {ivBytes in
                    keyData.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(operation),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes, keyLength,
                                ivBytes,
                                dataBytes, self.count,
                                cryptBytes, cryptLength,
                                &numBytesProcessed)
                    }
                }
            }
        }

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesProcessed..<cryptData.count)
        } else {
            fatalError("Error: \(cryptStatus)")
        }
        return cryptData
    }

}

extension String {
    fileprivate func md5() -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let d = self.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }

    /// AES128 Encrypts a String to a base64 string
    ///
    /// - Parameters:
    ///   - key: key: aes key (String)
    ///   - iv: iv in Hex String
    /// - Returns: The AES128 encrypted string (String: Base64)
    public func aesEncryptWithKey(_ key: String, iv: String = "00000000000000000000000000000000") -> String {
        let keyinMD5 = key.md5()!
        let keyData = Data(fromHexString: keyinMD5)!
        let ivData = Data(fromHexString: iv)!

        let origData = self.data(using: String.Encoding.utf8)!
        let cryptData = origData.aes(keyData: keyData, ivData: ivData, operation: kCCEncrypt)
        let encryptedDataBase64 = cryptData.base64EncodedData(options: [])
        let encryptedStringBase64 = String(data: encryptedDataBase64, encoding: .utf8)!
        return encryptedStringBase64
    }

    /// AES128 Decrypts a Base 64 String to a String
    ///
    /// - Parameters:
    ///   - key: aes key (String)
    ///   - iv: iv in Hex String
    /// - Returns: Am AES128 decrypted string
    public func aesDecryptWithKey(_ key: String, iv: String = "00000000000000000000000000000000") -> String {
        let keyinMD5 = key.md5()!
        let keyData = Data(fromHexString: keyinMD5)!
        let ivData = Data(fromHexString: iv)!

        let origData = Data(base64Encoded: self, options: [])!
        let cryptData = origData.aes(keyData: keyData, ivData: ivData, operation: kCCDecrypt)
        let decryptedString = String(data: cryptData, encoding: .utf8)!
        return decryptedString
    }
}

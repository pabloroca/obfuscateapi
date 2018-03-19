//
//  main.swift
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

func usage() {
    print("obfuscateapi v1.0 @PR2Studio 2018");
    print("Usage: obfuscateapi -key aeskey [-iv ivstring] [-infile file] \n");
}

// MARK: - Argument management

if CommandLine.arguments.count < 3 {
    usage()
    exit(1)
}

var arrArguments = CommandLine.arguments
arrArguments.removeFirst()

var argsDict: [String:String] = [:]

// create Dictionary from arguments
for (index, element) in arrArguments.enumerated() {
    if remainder(Double(index), 2) == 1 {
        var key = arrArguments[index-1]
        key.remove(at: element.startIndex)
        argsDict[key] = element
    }
}

var infile = "apiplain.plist"
if let infileFromArgs = argsDict["infile"] {
    infile = infileFromArgs
}

if !FileManager.default.fileExists(atPath: infile) {
    print("infile '\(infile)' does not exist");
    usage()
    exit(1)
}

guard let aesKey = argsDict["key"] else {
    usage()
    exit(1)
}

var hexiv = "00000000000000000000000000000000"
if let ivFromArgs = argsDict["iv"] {
    hexiv = ivFromArgs
}

// MARK: - Create outfile

var outfile = "APIConstants.swift"
if let outfileFromArgs = argsDict["outfile"] {
    outfile = outfileFromArgs
}

guard var inputDict = NSDictionary(contentsOfFile: infile) else {
    exit(1)
}

FileManager.default.createFile(atPath: outfile, contents: nil, attributes: nil)

do {
    let fileHandler = try FileHandle(forWritingTo: URL(string: outfile)!)
    fileHandler.seekToEndOfFile()
    let header = String(format: "//\n// %@\n//\n\n", outfile)
    fileHandler.write(header.data(using: .utf8)!)
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("import Foundation\n\n".data(using: .utf8)!)
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("/// End Points\n".data(using: .utf8)!)
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("struct APIConstants {\n\n".data(using: .utf8)!)
    
    for endPointComment in inputDict {
        fileHandler.seekToEndOfFile()
        let stringEndPointComment = String(format: "    /// %@\n", endPointComment.key as! CVarArg)
        fileHandler.write(stringEndPointComment.data(using: .utf8)!)
        
        guard let childDict = endPointComment.value as? [String: String] else {
            exit(1)
        }
        
        // encrypt
        let stringToEncrypt = String(format: "%@", childDict["value"]!)
        let encryptedStringBase64 = stringToEncrypt.aesEncryptWithKey(aesKey, iv: hexiv)
        // encrypt
        
        //let jar = encryptedStringBase64.aesDecryptWithKey(aesKey, iv: hexiv)
        
        fileHandler.seekToEndOfFile()
        let endPoint = String(format: "    static let %@ = \"%@\"\n\n", childDict["key"]!, encryptedStringBase64)
        fileHandler.write(endPoint.data(using: .utf8)!)
    }
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("}\n".data(using: .utf8)!)
    fileHandler.closeFile()
} catch {
    print("Error writing to file \(outfile). Error \(error)")
    exit(2)
}

// MARK: - Create aeskey class

var keyclass = "AESKeyClass.swift"
if let keyclassFromArgs = argsDict["keyclass"] {
    keyclass = keyclassFromArgs
}
FileManager.default.createFile(atPath: keyclass, contents: nil, attributes: nil)

do {
    let fileHandler = try FileHandle(forWritingTo: URL(string: keyclass)!)
    fileHandler.seekToEndOfFile()
    let header = String(format: "//\n// %@\n//\n\n", keyclass)
    fileHandler.write(header.data(using: .utf8)!)
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("import Foundation\n\n".data(using: .utf8)!)
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("@inline(__always) public func aesKey() -> [UInt8] {\n".data(using: .utf8)!)
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("    return [\n".data(using: .utf8)!)
    
    let aesKeyData: Data = aesKey.data(using: .utf8)!
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("        ".data(using: .utf8)!)
    
    for (index,character) in aesKeyData.enumerated() {

        let firstNumber = UInt8(arc4random_uniform(UInt32(character)))

        switch arc4random_uniform(2) {
        // adds
        case 0:
            fileHandler.seekToEndOfFile()
            fileHandler.write(String(format: "0x%02X",firstNumber).data(using: .utf8)!)
            let secondNumber = character - firstNumber
            fileHandler.seekToEndOfFile()
            fileHandler.write(String(format: "+0x%02X",secondNumber).data(using: .utf8)!)
        // substracts
        default:
            fileHandler.seekToEndOfFile()
            fileHandler.write(String(format: "0x%02X",character + firstNumber).data(using: .utf8)!)
            fileHandler.seekToEndOfFile()
            fileHandler.write(String(format: "-0x%02X",firstNumber).data(using: .utf8)!)
            break
        }
        
        if index < aesKeyData.count - 1 {
            fileHandler.seekToEndOfFile()
            fileHandler.write(", ".data(using: .utf8)!)
        }
        if remainder(Double(index), 9) == 0 && index != 0 {
            fileHandler.seekToEndOfFile()
            fileHandler.write("\n        ".data(using: .utf8)!)
        }
    }
    
    fileHandler.seekToEndOfFile()
    fileHandler.write("\n    ]\n".data(using: .utf8)!)
    fileHandler.seekToEndOfFile()
    fileHandler.write("}\n".data(using: .utf8)!)
    fileHandler.closeFile()
} catch {
    print("Error writing to file \(outfile). Error \(error)")
    exit(2)
}

//let arrKeyString = String(data: Data(bytes: aesKey()), encoding: .utf8)

print("Generated files APIConstants.swift and AESKeyClass.swift")

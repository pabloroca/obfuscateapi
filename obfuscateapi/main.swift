//
//  main.swift
//  obfuscateapi
//
//  Created by Pablo Roca Rozas on 18/3/18.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import Foundation

func usage() {
    print("Usage: obfuscateapi -key <XXX> -iv <XXX> -infile <file> \n");
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

print("End")

# obfuscateapi

Mac OSX, Command line Swift 4 Utility for obfuscate / defuscate strings (API endpoints) in AES128 format.

## Motivation

The list of endpoints or servers that an iOS app have, is restricted information that should not be disclosed, usually devs we create that network services definition in a constants file or even worse, in a plist.

A plist is easily breakable and plain text strings are also (see strings command), so anyone with a minimum of knowledge can get to know how is our network services definition, who leads it prone to attacks.

So doing like this, is a bad security practice:

```
struct APIConstants {
    static let baseURL = "https://server.com"
    static let deviceBinding = "api/devideBinding"
...
```

This command line utility creates two Swift 4 compatible files:

- An ```APIConstants.swift``` file. With strings from network layer encrypted by AES128 CBC format. See how it looks now:

```
struct APIConstants {
    static let baseURL = "Cs6WqbJ4uVMXUhQ/pU96WF/wsWAT5yiBqfGVG99XZ0M="
    static let deviceBinding = "Ja2p49mofIichhwVjkgQlIKQC/RDNBZe4PtZUCMaYCY="
...
```

- An inline method in file ```AESKeyClass.swift``` where password is scrambled. See it for password: secretpassword

```
import Foundation
@inline(__always) public func aesKey() -> [UInt8] {
    return [
        0x7C-0x09, 0x66-0x01, 0x51+0x12, 0x01+0x71, 0x0C+0x59, 0x59+0x1B,
        0x44+0x2C, 0x6F-0x0E, 0xCA-0x57, 0x8D-0x1A,
        0xAD-0x36, 0x56+0x19, 0xD9-0x67, 0x7E-0x1A
    ]
}
```


# obfuscateapi

Mac OSX, Command line Swift 4 Utility for obfuscate / defuscate strings (API endpoints) in AES128 format.

## Motivation

The list of endpoints or servers that an iOS app have, is restricted information that should not be disclosed, usually developers create that network services definition in a constants file or even worse, in a plist.

A plist is easily breakable and plain text strings are also (see strings command), so anyone with a minimum of knowledge can get to know how is our network services definition, who leaves it prone to attacks.

So doing like this, is a bad security practice:

```swift
struct APIConstants {
    static let baseURL = "https://server.com"
    static let deviceBinding = "api/devideBinding"
```

This command line utility creates two Swift 4 compatible files:

- An ```APIConstants.swift``` file. With strings from network layer encrypted by AES128 CBC format. See how it looks now:

```swift
struct APIConstants {
    static let baseURL = "Cs6WqbJ4uVMXUhQ/pU96WF/wsWAT5yiBqfGVG99XZ0M="
    static let deviceBinding = "Ja2p49mofIichhwVjkgQlIKQC/RDNBZe4PtZUCMaYCY="
```

- An inline method in file ```AESKeyClass.swift``` where password is scrambled. See it for password: secretpassword

```swift
import Foundation
@inline(__always) public func aesKey() -> [UInt8] {
    return [
        0x7C-0x09, 0x66-0x01, 0x51+0x12, 0x01+0x71, 0x0C+0x59, 0x59+0x1B,
        0x44+0x2C, 0x6F-0x0E, 0xCA-0x57, 0x8D-0x1A,
        0xAD-0x36, 0x56+0x19, 0xD9-0x67, 0x7E-0x1A
    ]
}
```
## Technology

* It uses [AES128 CBC](https://tools.ietf.org/html/rfc3602) format, with an optional ```iv```, if you don´t specify, the default ```iv``` will be ```00000000000000000000000000000000```

* Symmetric encryption

* inline function for the aes key. So it will be more difficult to hijack it, and the attacker would need to patch all occurrences of it.

* the inlined bytes are generated pseudo-ramdomly, so every time you run it, it will generate different hexs with operations

* we can deploy a new version of the app with a new AES key. Just running again this command utility.

* Secure enough

## Install

### 1 Install Command Line Developer tools.

The easiest way is with: ```xcode-select --install```

### 2 Adjust the ouput files to your needs

This can be done changing how they will render, it´s done in ```main.swift```

### 3 Archive the project

From your achived project, you will have an ```obfuscateapi date.xcarchive``` file

### 4 Copy executable to your usr/local/bin folder

Go to xcarchive, show contents and locate  ```/usr/local/bin/obfuscateapi``` and copy it to your ```/usr/local/bin folder```

## Running it

Open a command line in Terminal and run the command ```obfuscateapi```

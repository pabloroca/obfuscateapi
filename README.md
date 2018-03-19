# obfuscateapi

[![Swift](https://img.shields.io/badge/swift-4.0-red.svg?style=flat)](https://developer.apple.com/swift)

Mac OSX, Command line Swift 4 Utility for obfuscate / defuscate strings (API endpoints) in AES128 format.

## Contents

- [Motivation](#motivation)
- [Tecnology](#technology)
- [Install](#install)
- [Running it](#running-it)
- [Using it](#using-it)
- [Credits](#credits)
- [License](#license)

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

- An ```APIConstants.swift``` file. With strings from network layer encrypted in AES128 CBC format. See how it looks now:

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

* Uses standards. Done with Apple CommonCrypto and standard format. No third parties or propietary formats.

* inline function for the aes key. So it will be more difficult to hijack it, and the attacker would need to patch all occurrences of it.

* the inlined bytes are generated pseudo-ramdomly, so every time you run it, it will generate different hexs with operations

* we can deploy a new version of the app with a new AES key. Just running again this command utility.

* Secure enough

## Install

#### 1 Install Command Line Developer tools.

The easiest way is with: ```xcode-select --install```

#### 2 Adjust the ouput files to your needs

This can be done changing how they will render, it´s done in ```main.swift```

#### 3 Archive the project

From your achived project, you will have an ```obfuscateapi date.xcarchive``` file

#### 4 Copy executable to your usr/local/bin folder

Go to xcarchive, show contents and locate  ```/usr/local/bin/obfuscateapi``` and copy it to your ```/usr/local/bin folder```

## Running it

Open a command line in Terminal and run the command ```obfuscateapi```

**NAME** 

obfuscateapi - obfuscates a plist to classes in AES128 format

**SYNOPSIS**

   **obfuscateapi** **-key** aeskey [**-iv** ivstring] [**-infile** file]

**DESCRIPTION**

The following options are available:

**-key** the key for encrypting. Better to use a long one

**-iv** initialization vector. By default is `00000000000000000000000000000000`

**-infile** plist to convert to classes. bu default is `apiplain.plist`

It will generate two files `APIConstants.swift` with the encrypted strings and `AESKeyClass.swift` with a function to retrieve the key

## infile plist format

We should describe the network services in a plist, this is a sample plist. Each entry has three parts (dictionary with a long name for comments, constant name and value. Sample with three constants

	<key>Base URL</key>
	<dict>
		<key>key</key>
		<string>baseURL</string>
		<key>value</key>
		<string>https://pr2studio.com</string>
	</dict>
	<key>Device binding</key>
	<dict>
		<key>key</key>
		<string>deviceBinding</string>
		<key>value</key>
		<string>/means/getbinding</string>
	</dict>
	<key>Send key</key>
	<dict>
		<key>key</key>
		<string>sendKey</string>
		<key>value</key>
		<string>/means/sendkey</string>
	</dict>

## Using it

After generated the two files (`APIConstants.swift` and `AESKeyClass.swift`), you can copy it to your project, along with [Crypto+Extensions.swift](https://github.com/pabloroca/obfuscateapi/blob/master/obfuscateapi/Crypto%2BExtensions.swift)

Then when you want to retrieve the string for an endpoint, you should do this:

```
let arrKeyString = String(data: Data(bytes: aesKey()), encoding: .utf8)
let endpoint = APIConstants.deviceBinding.aesDecryptWithKey(arrKeyString)
```

then use endpoint constant for doing yout network request

You can check if the strings generated work fine with this openssl command (first save the string ending with a carriage return in file test.enc):

`openssl enc -aes128 -k secretpassword -p -iv 00000000000000000000000000000000 -nosalt -base64 -d -in test.enc`

## Credits

Pablo Roca Rozas. PR2Studio.

## License

**obfuscateapi** is released under the MIT license. [See LICENSE](https://github.com/pabloroca/obfuscateapi/blob/master/LICENSE) for details.

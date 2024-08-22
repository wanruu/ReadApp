# ReadApp

This is an iOS application for e-book reading & listening. Implemented in SwiftUI and involves some components from UIKit. 

Using Apple's built-in text-to-speech interface, the reading may be a bit influent. I will consider embedding a reading AI in the future.

The app is only for individual use.


## Features

### File import
Target types: plaintext file in UTF-16.


### Chapter split
Automatically detect chapter titles and split the text into multiple sections.


### Text to speech
Supported language: zh-CN


## TODO
- [ ] Bug: can't open file from other app when running on real phone

- [ ] Feature: support file export

- [ ] Feature: should allow user to define title regex pattern & reload catalog

- [ ] Feature: text editor

- [ ] Bug: should allow user to cancel countdown in reading

- [ ] Feature: accept more file type (currently only plaintext in UTF-16)

- [ ] Feature: support multiple languages (currently only mandarian)

- [ ] Feature: sort book with options, e.g., rating, author

- [ ] Bug: In book profile page, the padding for comment editor component is odd

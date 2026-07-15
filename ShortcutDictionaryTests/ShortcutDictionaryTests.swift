//
//  ShortcutDictionaryTests.swift
//  ShortcutDictionaryTests
//
//  Created by 문부영 on 10/19/24.
//

import AppKit
@testable import ShortcutDictionary
import Testing

struct ShortcutDictionaryTests {
    @Test func liquidGlassBackgroundDefaultsToNativeWindow() {
        #expect(
            SettingKeys.liquidGlassBackgroundColor.defaultValue as? String
                == SettingKeys.nativeWindowBackgroundColorValue
        )
        #expect(
            SettingKeys.liquidGlassBackgroundDarkColor.defaultValue as? String
                == SettingKeys.nativeWindowBackgroundColorValue
        )
    }

    @Test func hexColorParserRejectsInvalidValues() {
        #expect(NSColor(hexString: "#FFFFFF") != nil)
        #expect(NSColor(hexString: "ZZZZZZ") == nil)
        #expect(NSColor(hexString: "12GG34") == nil)
    }
}

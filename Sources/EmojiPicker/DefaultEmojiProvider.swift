//
//  DefaultEmojiProvider.swift
//
//
//  Created by Kévin Sibué on 11/01/2023.
//

import Foundation

public final class DefaultEmojiProvider: EmojiProvider {
    
    public init() { }
    
    public func getAll() -> [Emoji] {
        return self.list().map({ Emoji(value: $0, name: name(emoji: $0).first ?? "") }).filter({ Unicode.Scalar($0.value)?.properties.isEmoji ?? false })
    }
    
    public func list() -> [String] {
        let ranges = [
            0x1F600...0x1F64F, // Emoticons
            8400...8447, // Combining Diacritical Marks for Symbols
            9100...9300, // Misc items
            0x2600...0x26FF, // Misc symbols
            0x2700...0x27BF, // Dingbats
            0xFE00...0xFE0F, // Variation Selectors
            0x1F018...0x1F270, // Various asian characters
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x1F1E6...0x1F1FF, // Regional country flags
            0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
            65024...65039, // Variation selector
        ]
        
        var all = ranges.joined().map {
            return String(Character(UnicodeScalar($0)!))
        }
        
        //⌚️⌨️⭐️
        let solos = [0x231A, 0x231B, 0x2328, 0x2B50]
        all.append(contentsOf: solos.map({ String(Character(UnicodeScalar($0)!))}))
        
        return all
    }
    
    /// Return standard name for a emoji
    public func name(emoji: String) -> [String] {
        let string = NSMutableString(string: String(emoji))
        var range = CFRangeMake(0, CFStringGetLength(string))
        CFStringTransform(string, &range, kCFStringTransformToUnicodeName, false)
        
        return Utils.dropPrefix(string: String(string), subString: "\\N")
            .components(separatedBy: "\\N")
            .map {
                return Utils.remove(string: $0, set: (Set(["{", "}"])))
            }
    }
}

struct Utils {
    
    static func dropPrefix(string: String, subString: String) -> String {
        guard string.hasPrefix(subString),
              let range = string.range(of: subString) else {
            return string
        }
        
        return string.replacingCharacters(in: range, with: "")
    }
    
    static func remove(string: String, set: Set<String>) -> String {
        var result = string
        set.forEach {
            result = result.replacingOccurrences(of: $0, with: "")
        }
        
        return result
    }
}

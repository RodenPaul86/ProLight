//
//  MorseCodeManager.swift
//  ProLight
//
//  Created by Paul Roden II on 3/27/22.
//  Copyright © 2022 Studio4Designsoftware. All rights reserved.
//

import UIKit
import AVFoundation

//MARK: Global Function(s)
//converts text to lowercase
func initializeString(toConvert: inout String) {
    toConvert = toConvert.lowercased()
}

class MorseCodeManager {
    static func getMorseCode() -> [String: String] {
        var mapMorseCode : [String: String] = [:]
        //MARK: Morse Code Start
        mapMorseCode["a"] = ".-"
        mapMorseCode["b"] = "-..."
        mapMorseCode["c"] = "-.-."
        mapMorseCode["d"] = "-.."
        mapMorseCode["e"] = "."
        mapMorseCode["f"] = "..-."
        mapMorseCode["g"] = "--."
        mapMorseCode["h"] = "...."
        mapMorseCode["i"] = ".."
        mapMorseCode["j"] = ".---"
        mapMorseCode["k"] = "-.-"
        mapMorseCode["l"] = ".-.."
        mapMorseCode["m"] = "--"
        mapMorseCode["n"] = "-."
        mapMorseCode["o"] = "---"
        mapMorseCode["p"] = ".--."
        mapMorseCode["q"] = "--.-"
        mapMorseCode["r"] = ".-."
        mapMorseCode["s"] = "..."
        mapMorseCode["t"] = "-"
        mapMorseCode["u"] = "..-"
        mapMorseCode["v"] = "...-"
        mapMorseCode["w"] = ".--"
        mapMorseCode["x"] = "-..-"
        mapMorseCode["y"] = "-.--"
        mapMorseCode["z"] = "--.."
        mapMorseCode["1"] = ".----"
        mapMorseCode["2"] = "..---"
        mapMorseCode["3"] = "...--"
        mapMorseCode["4"] = "....-"
        mapMorseCode["5"] = "....."
        mapMorseCode["6"] = "-...."
        mapMorseCode["7"] = "--..."
        mapMorseCode["8"] = "---.."
        mapMorseCode["9"] = "----."
        mapMorseCode["0"] = "-----"
        mapMorseCode["."] = ".-.-.-"
        mapMorseCode[","] = "--..--"
        mapMorseCode["?"] = "..--.."
        mapMorseCode["\'"] = ".----."
        mapMorseCode["!"] = "-.-.--"
        mapMorseCode["/"] = "-..-."
        mapMorseCode["("] = "-.--."
        mapMorseCode[")"] = "-.--.-"
        mapMorseCode["&"] = ".-..."
        mapMorseCode[":"] = "---..."
        mapMorseCode[";"] = "-.-.-."
        mapMorseCode["="] = "-...-"
        mapMorseCode["+"] = ".-.-."
        mapMorseCode["-"] = "-...-"
        mapMorseCode["_"] = "..--.-"
        mapMorseCode["\""] = ".-..-."
        mapMorseCode["$"] = "...-..-"
        mapMorseCode["@"] = ".--.-."
        mapMorseCode[" "] = "/"
        mapMorseCode[" # "] = "#"
        //MARK: Morse Code END
        return mapMorseCode
    }
}

//MARK: Extension(s)
extension String {
    var length: Int {
        return count
    }
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

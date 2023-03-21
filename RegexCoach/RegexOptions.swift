//
//  RegexOptions.swift
//  RegexCoach
//
//  Created by Philipp on 21.03.23.
//

import SwiftUI

struct RegexOptions: OptionSet {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let ignoresCase = RegexOptions(rawValue: 1 << 0)
    static let anchorsMatchLineEndings = RegexOptions(rawValue: 1 << 1)
    static let dotMatchesNewlines = RegexOptions(rawValue: 1 << 2)
}

// Allow storing RegexOptions as Int literal
extension RegexOptions: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        rawValue = value
    }
}

// Allow defining a binding for each option
extension Binding where Value == RegexOptions {
    subscript(_ option: RegexOptions) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                wrappedValue.contains(option)
            },
            set: { newValue, _ in
                if newValue {
                    wrappedValue.insert(option)
                } else {
                    wrappedValue.remove(option)
                }
            }
        )
    }
}


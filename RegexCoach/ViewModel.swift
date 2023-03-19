//
//  ViewModel.swift
//  RegexCoach
//
//  Created by Philipp on 19.03.23.
//

import SwiftUI

class ViewModel: ObservableObject {
    @AppStorage("pattern") var pattern = "" { didSet { update() } }
    @AppStorage("input") var input = "Text to match here" { didSet { update() } }
    @AppStorage("replacement") var replacement = "" { didSet { update() } }

    @Published var replacementOutput = ""
    @Published var matches = [Match]()
    @Published var isValid = true

    var code: String {
        """
        import Foundation

        let input = \"""
        \(input)
        \"""

        let regex = /\(pattern)/
        let replacement = "\(replacement)"
        let results = input.matches(of: regex)

        for result in results {
            let matchText = String(input[result.range])
            print("Found: \\(matchText)")
        }

        let output = input.replacing(regex, with: replacement)
        print(output)
        """
    }

    func update() {
        guard pattern.isEmpty == false else { return }

        do {
            let regex = try Regex(pattern)
            let results = input.matches(of: regex)
            replacementOutput = input.replacing(regex, with: replacement)
            isValid = true

            matches = results.compactMap({ result in
                let wholeText = String(input[result.range])
                if wholeText.isEmpty { return nil }

                var wholeMatch = Match(text: wholeText, position: result.range.position(in: input))

                if result.count > 1 {
                    wholeMatch.groups = [Match]()

                    for part in result.indices.dropFirst() {
                        let match = result[part]
                        guard let range = match.range else { continue }

                        let matchText = String(input[range])
                        if matchText.isEmpty { continue }

                        let partMatch = Match(text: matchText, position: range.position(in: input))
                        wholeMatch.groups?.append(partMatch)
                    }
                }

                return wholeMatch
            })
        } catch {
            matches.removeAll()
            replacementOutput = ""
            isValid = false
        }
    }
}

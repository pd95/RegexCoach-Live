//
//  ViewModel.swift
//  RegexCoach
//
//  Created by Philipp on 19.03.23.
//

import SwiftUI

class ViewModel: ObservableObject {
    @AppStorage("pattern") var pattern = "" { didSet { if oldValue != pattern { update() } } }
    @AppStorage("input") var input = "Text to match here" { didSet { if oldValue != input { update() } } }
    @AppStorage("replacement") var replacement = "" { didSet { if oldValue != replacement { update() } } }

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
            isValid = true

            matches = results.compactMap({ (regexMatch: Regex<AnyRegexOutput>.Match) -> Match? in
                let wholeText = String(input[regexMatch.range])
                if wholeText.isEmpty { return nil }

                var wholeMatch = Match(text: wholeText, position: regexMatch.range.position(in: input), range: regexMatch.range)

                // Replace "whole match placeholder" (if found)
                var matchReplacement = replacement.replacing("$0", with: wholeText)
                if regexMatch.count > 1 {
                    wholeMatch.groups = [Match]()
                    for part in regexMatch.indices.dropFirst() {
                        let match = regexMatch[part]
                        guard let range = match.range else { continue }

                        let matchText = String(input[range])

                        // Replace "named group" placeholder
                        if let matchName = match.name {
                            matchReplacement = matchReplacement.replacing("$\(matchName)", with: matchText)
                        }

                        // Replace "indexed group" placeholder"
                        matchReplacement = matchReplacement.replacing("$\(part)", with: matchText)

                        if matchText.isEmpty { continue }

                        let partMatch = Match(text: matchText, position: range.position(in: input), range: range)
                        wholeMatch.groups?.append(partMatch)
                    }
                }
                wholeMatch.replacement = matchReplacement

                return wholeMatch
            })

            // Generate replacement output by applying all match replacements
            var output = [Substring]()
            var lastIndex = input.startIndex
            for match in matches {
                output.append(input[lastIndex..<match.range.lowerBound])
                output.append(match.replacement[...])
                lastIndex = match.range.upperBound
            }
            output.append(input[lastIndex..<input.endIndex])
            replacementOutput = output.joined()
        } catch {
            print("🔴", error)
            matches.removeAll()
            replacementOutput = ""
            isValid = false
        }
    }
}

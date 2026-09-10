//
//  SolarWindows.swift
//  Solar
//

import Foundation

/// A pair of windows in a day — one either side of solar noon — that exist
/// only when the sun actually passes through the altitudes that define them.
///
/// Golden hour and blue hour both come as a morning and an evening. Either
/// can be missing: in Tromsø in June the sun never gets low enough for
/// either, and in Tromsø in December it never gets high enough for golden
/// hour to have an end, so the window runs to solar noon instead.
public struct SolarWindows: Sendable, Hashable, Codable {

    /// The window before solar noon, when it exists.
    public let morning: DateInterval?

    /// The window after solar noon, when it exists.
    public let evening: DateInterval?

    /// Builds a pair of windows by hand; ``Solar/goldenHour(on:at:in:)`` and
    /// ``Solar/blueHour(on:at:in:)`` compute real ones.
    public init(morning: DateInterval?, evening: DateInterval?) {
        self.morning = morning
        self.evening = evening
    }
}

//
//  MoonPhaseName.swift
//  Solar
//

import Foundation

/// The eight named phases, each owning an eighth of the cycle.
///
/// A phase name is a bin, not an instant. "New moon" here is the 45° of
/// elongation centred on the moment of new moon — roughly a day and a half
/// either side — because that is what a calendar or a weather app means by
/// it. The exact instants are separate: ``MoonPhase/nextNewMoon`` and
/// ``MoonPhase/nextFullMoon``.
public enum MoonPhaseName: String, CaseIterable, Sendable, Codable {
    case new
    case waxingCrescent
    case firstQuarter
    case waxingGibbous
    case full
    case waningGibbous
    case lastQuarter
    case waningCrescent

    /// The name as it is written on a calendar.
    public var label: String {
        switch self {
        case .new:            "New Moon"
        case .waxingCrescent: "Waxing Crescent"
        case .firstQuarter:   "First Quarter"
        case .waxingGibbous:  "Waxing Gibbous"
        case .full:           "Full Moon"
        case .waningGibbous:  "Waning Gibbous"
        case .lastQuarter:    "Last Quarter"
        case .waningCrescent: "Waning Crescent"
        }
    }
}

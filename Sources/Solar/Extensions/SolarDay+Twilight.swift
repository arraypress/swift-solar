//
//  SolarDay+Twilight.swift
//  Solar
//

import Foundation

extension SolarDay {

    /// The dawn of a twilight, by name — the same values as the six
    /// properties, for callers that hold a ``Twilight`` rather than a
    /// property.
    public func dawn(_ twilight: Twilight) -> SolarEvent {
        switch twilight {
        case .civil:        civilDawn
        case .nautical:     nauticalDawn
        case .astronomical: astronomicalDawn
        }
    }

    /// The dusk of a twilight, by name.
    public func dusk(_ twilight: Twilight) -> SolarEvent {
        switch twilight {
        case .civil:        civilDusk
        case .nautical:     nauticalDusk
        case .astronomical: astronomicalDusk
        }
    }
}

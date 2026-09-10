//
//  SolarEvent.swift
//  Solar
//

import Foundation

/// When the sun crosses a particular altitude on a given day — or the fact
/// that it never did.
///
/// Three cases rather than an optional because the two ways of having no
/// time mean opposite things. In Tromsø on 21 June the sun never sets, and
/// in Tromsø on 21 December it never rises; a `nil` for both would send the
/// caller back to the latitude to work out which. Nothing here ever
/// invents a time: a library that returns "00:00" for a sunset that does
/// not happen has told a lie somebody will display.
///
/// For a twilight event the same two cases read one level down.
/// ``polarDay`` on a civil dusk means the sun never dropped below -6°, so
/// the sky never got darker than civil twilight — Reykjavik in June, where
/// the sun does set but it never gets dark. ``polarNight`` on a civil dawn
/// means it never climbed above -6°.
public enum SolarEvent: Sendable, Hashable, Codable {

    /// The crossing happened, at this instant.
    case at(Date)

    /// The sun stayed above this altitude for the whole day.
    case polarDay

    /// The sun stayed below this altitude for the whole day.
    case polarNight
}

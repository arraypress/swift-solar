//
//  SunPosition.swift
//  Solar
//

import Foundation

/// Where the sun is in the sky at one instant, from one place.
public struct SunPosition: Sendable, Hashable, Codable {

    /// Degrees above the horizon, as geometry has it; negative is below.
    ///
    /// This is the number the rise, set and twilight definitions are written
    /// against. Sunrise is the centre of the sun at -0.833°: half a degree of
    /// refraction plus a quarter of a degree of the disc, which is why the
    /// sun is visible while this says it is below the horizon.
    public let altitude: Double

    /// Degrees above the horizon as seen, with atmospheric refraction added.
    ///
    /// Near the horizon the air lifts the sun by about half a degree, so at
    /// the moment of sunrise ``altitude`` reads -0.83 and this reads about
    /// -0.27 — the upper limb on the horizon.
    public let apparentAltitude: Double

    /// Degrees clockwise from true north: east is 90, south is 180.
    public let azimuth: Double

    /// Builds a position by hand; ``Solar/position(at:coordinate:)`` computes a
    /// real one.
    public init(altitude: Double, apparentAltitude: Double, azimuth: Double) {
        self.altitude = altitude
        self.apparentAltitude = apparentAltitude
        self.azimuth = azimuth
    }
}

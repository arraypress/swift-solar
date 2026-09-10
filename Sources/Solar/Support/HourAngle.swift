//
//  HourAngle.swift
//  Solar
//
//  The one equation behind every rise, set and twilight: at what angle from
//  the meridian does the sun stand at a given altitude.
//

import Foundation

/// The hour angle at which the sun's centre reaches an altitude, or the
/// reason it never does.
enum HourAngle {

    /// The altitude of the sun's centre at sunrise and sunset, degrees.
    ///
    /// -0.833: 0.567° of atmospheric refraction lifting the sun, plus 0.267°
    /// for the top edge of the disc rather than its centre. This is the
    /// definition NOAA, the USNO and every printed almanac share, so times
    /// computed against it agree with the newspaper.
    static let horizon = -0.833

    /// Degrees of hour angle either side of solar noon at which the sun's
    /// centre reaches `altitude`, at a place with `latitude`, on a day when
    /// the sun's `declination` is as given. All in degrees.
    ///
    /// The cosine falling outside -1...1 is not an error: it is the sun
    /// never reaching that altitude that day, and which side it fell out
    /// says whether it stayed above or below.
    static func sweep(latitude: Double, declination: Double, altitude: Double) -> Sweep {
        let numerator = Angles.sin(altitude) - Angles.sin(latitude) * Angles.sin(declination)
        let denominator = Angles.cos(latitude) * Angles.cos(declination)
        let cosine = numerator / denominator
        if cosine > 1 { return .alwaysBelow }
        if cosine < -1 { return .alwaysAbove }
        return .angle(Angles.acos(cosine))
    }
}

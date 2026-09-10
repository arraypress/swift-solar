//
//  SolarGeometry.swift
//  Solar
//
//  The sun's position on the celestial sphere, term for term as NOAA's solar
//  calculator has it (Meeus, Astronomical Algorithms, chapter 25).
//

import Foundation

/// Where the sun is, as seen from the centre of the Earth, for a given
/// Julian century. Every function takes the same `T` so the pieces can be
/// tested one at a time against the almanac's worked examples.
enum SolarGeometry {

    /// Geometric mean longitude of the sun, degrees.
    static func meanLongitude(julianCentury t: Double) -> Double {
        Angles.normalized(280.46646 + t * (36000.76983 + 0.0003032 * t))
    }

    /// Geometric mean anomaly of the sun, degrees.
    static func meanAnomaly(julianCentury t: Double) -> Double {
        357.52911 + t * (35999.05029 - 0.0001537 * t)
    }

    /// Eccentricity of the Earth's orbit. About 0.0167, and shrinking.
    static func eccentricity(julianCentury t: Double) -> Double {
        0.016708634 - t * (0.000042037 + 0.0000001267 * t)
    }

    /// The equation of the centre: how far the true sun runs ahead of or
    /// behind the mean one because the orbit is an ellipse, degrees.
    static func equationOfCenter(julianCentury t: Double) -> Double {
        let m = meanAnomaly(julianCentury: t)
        return Angles.sin(m) * (1.914602 - t * (0.004817 + 0.000014 * t))
            + Angles.sin(2 * m) * (0.019993 - 0.000101 * t)
            + Angles.sin(3 * m) * 0.000289
    }

    /// True longitude of the sun, degrees.
    static func trueLongitude(julianCentury t: Double) -> Double {
        meanLongitude(julianCentury: t) + equationOfCenter(julianCentury: t)
    }

    /// Longitude of the ascending node of the moon's orbit, degrees — the
    /// argument of the nutation terms.
    static func ascendingNode(julianCentury t: Double) -> Double {
        125.04 - 1934.136 * t
    }

    /// Apparent longitude of the sun, corrected for nutation and aberration,
    /// degrees.
    static func apparentLongitude(julianCentury t: Double) -> Double {
        trueLongitude(julianCentury: t) - 0.00569 - 0.00478 * Angles.sin(ascendingNode(julianCentury: t))
    }

    /// Mean obliquity of the ecliptic, degrees. About 23.44, and shrinking.
    static func meanObliquity(julianCentury t: Double) -> Double {
        23 + (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60
    }

    /// Obliquity of the ecliptic with the nutation correction, degrees.
    static func obliquity(julianCentury t: Double) -> Double {
        meanObliquity(julianCentury: t) + 0.00256 * Angles.cos(ascendingNode(julianCentury: t))
    }

    /// Declination of the sun, degrees: how far north or south of the
    /// celestial equator it stands. ±23.44 at the solstices, 0 at the equinoxes.
    static func declination(julianCentury t: Double) -> Double {
        Angles.asin(Angles.sin(obliquity(julianCentury: t)) * Angles.sin(apparentLongitude(julianCentury: t)))
    }

    /// The equation of time, minutes: how far sundial time runs ahead of
    /// mean time. Positive means the sun is early.
    ///
    /// Up to 16 minutes either way through the year, from two causes
    /// added together — the ellipse and the tilt — which is why solar noon
    /// is almost never at 12:00 and why the earliest sunset of the year is
    /// not on the shortest day.
    static func equationOfTime(julianCentury t: Double) -> Double {
        let epsilon = obliquity(julianCentury: t)
        let l0 = meanLongitude(julianCentury: t)
        let e = eccentricity(julianCentury: t)
        let m = meanAnomaly(julianCentury: t)
        let y = pow(Angles.tan(epsilon / 2), 2)

        let radians = y * Angles.sin(2 * l0)
            - 2 * e * Angles.sin(m)
            + 4 * e * y * Angles.sin(m) * Angles.cos(2 * l0)
            - 0.5 * y * y * Angles.sin(4 * l0)
            - 1.25 * e * e * Angles.sin(2 * m)
        return 4 * radians * 180 / .pi
    }
}

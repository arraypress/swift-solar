//
//  MoonGeometry.swift
//  Solar
//
//  The moon's longitude and how much of it the sun lights — Meeus,
//  Astronomical Algorithms, chapters 47 and 48, truncated to the terms that
//  matter for a phase.
//

import Foundation

/// The moon's place along the ecliptic and its illuminated fraction.
enum MoonGeometry {

    /// One term of the longitude series: a coefficient in millionths of a
    /// degree and the multipliers of D, M, M′ and F in its argument.
    private struct Term {
        let coefficient: Double
        let d: Double
        let m: Double
        let mPrime: Double
        let f: Double
    }

    /// The largest terms of Meeus's table 47.A. The full table has 60; these
    /// 30 leave the longitude within a few hundredths of a degree, which
    /// moves the illuminated fraction by less than a thousandth.
    private static let longitudeTerms: [Term] = [
        Term(coefficient: 6_288_774, d: 0, m: 0, mPrime: 1, f: 0),
        Term(coefficient: 1_274_027, d: 2, m: 0, mPrime: -1, f: 0),
        Term(coefficient: 658_314, d: 2, m: 0, mPrime: 0, f: 0),
        Term(coefficient: 213_618, d: 0, m: 0, mPrime: 2, f: 0),
        Term(coefficient: -185_116, d: 0, m: 1, mPrime: 0, f: 0),
        Term(coefficient: -114_332, d: 0, m: 0, mPrime: 0, f: 2),
        Term(coefficient: 58_793, d: 2, m: 0, mPrime: -2, f: 0),
        Term(coefficient: 57_066, d: 2, m: -1, mPrime: -1, f: 0),
        Term(coefficient: 53_322, d: 2, m: 0, mPrime: 1, f: 0),
        Term(coefficient: 45_758, d: 2, m: -1, mPrime: 0, f: 0),
        Term(coefficient: -40_923, d: 0, m: 1, mPrime: -1, f: 0),
        Term(coefficient: -34_720, d: 1, m: 0, mPrime: 0, f: 0),
        Term(coefficient: -30_383, d: 0, m: 1, mPrime: 1, f: 0),
        Term(coefficient: 15_327, d: 2, m: 0, mPrime: 0, f: -2),
        Term(coefficient: -12_528, d: 0, m: 0, mPrime: 1, f: 2),
        Term(coefficient: 10_980, d: 0, m: 0, mPrime: 1, f: -2),
        Term(coefficient: 10_675, d: 4, m: 0, mPrime: -1, f: 0),
        Term(coefficient: 10_034, d: 0, m: 0, mPrime: 3, f: 0),
        Term(coefficient: 8_548, d: 4, m: 0, mPrime: -2, f: 0),
        Term(coefficient: -7_888, d: 2, m: 1, mPrime: -1, f: 0),
        Term(coefficient: -6_766, d: 2, m: 1, mPrime: 0, f: 0),
        Term(coefficient: -5_163, d: 1, m: 0, mPrime: -1, f: 0),
        Term(coefficient: 4_987, d: 1, m: 1, mPrime: 0, f: 0),
        Term(coefficient: 4_036, d: 2, m: -1, mPrime: 1, f: 0),
        Term(coefficient: 3_994, d: 2, m: 0, mPrime: 2, f: 0),
        Term(coefficient: 3_861, d: 4, m: 0, mPrime: 0, f: 0),
        Term(coefficient: 3_665, d: 2, m: 0, mPrime: -3, f: 0),
        Term(coefficient: -2_689, d: 0, m: 1, mPrime: -2, f: 0),
        Term(coefficient: -2_602, d: 2, m: 0, mPrime: -1, f: 2),
        Term(coefficient: 2_390, d: 2, m: -1, mPrime: -2, f: 0),
    ]

    /// The moon's mean longitude, degrees.
    static func meanLongitude(julianCentury t: Double) -> Double {
        Angles.normalized(218.3164477 + 481267.88123421 * t - 0.0015786 * t * t + t * t * t / 538_841 - t * t * t * t / 65_194_000)
    }

    /// Mean elongation of the moon from the sun, degrees.
    static func meanElongation(julianCentury t: Double) -> Double {
        Angles.normalized(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t + t * t * t / 545_868 - t * t * t * t / 113_065_000)
    }

    /// Mean anomaly of the sun, degrees.
    static func sunMeanAnomaly(julianCentury t: Double) -> Double {
        Angles.normalized(357.5291092 + 35999.0502909 * t - 0.0001536 * t * t + t * t * t / 24_490_000)
    }

    /// Mean anomaly of the moon, degrees.
    static func moonMeanAnomaly(julianCentury t: Double) -> Double {
        Angles.normalized(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t + t * t * t / 69_699 - t * t * t * t / 14_712_000)
    }

    /// The moon's argument of latitude, degrees.
    static func argumentOfLatitude(julianCentury t: Double) -> Double {
        Angles.normalized(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t - t * t * t / 3_526_000 + t * t * t * t / 863_310_000)
    }

    /// The moon's geocentric longitude, degrees.
    static func longitude(julianCentury t: Double) -> Double {
        let d = meanElongation(julianCentury: t)
        let m = sunMeanAnomaly(julianCentury: t)
        let mPrime = moonMeanAnomaly(julianCentury: t)
        let f = argumentOfLatitude(julianCentury: t)
        /// The Earth's eccentricity is falling, which shrinks every term in
        /// M — once per power of M in the argument.
        let e = 1 - 0.002516 * t - 0.0000074 * t * t

        var sum = 0.0
        for term in longitudeTerms {
            let argument = term.d * d + term.m * m + term.mPrime * mPrime + term.f * f
            let scale = pow(e, abs(term.m))
            sum += term.coefficient * scale * Angles.sin(argument)
        }
        /// The three additive terms Meeus lists after the table: Venus,
        /// Jupiter, and the flattening of the Earth.
        let a1 = 119.75 + 131.849 * t
        let a2 = 53.09 + 479264.290 * t
        sum += 3958 * Angles.sin(a1) + 1962 * Angles.sin(meanLongitude(julianCentury: t) - f) + 318 * Angles.sin(a2)

        return Angles.normalized(meanLongitude(julianCentury: t) + sum / 1_000_000)
    }

    /// The moon's elongation east of the sun, 0 ..< 360 degrees. 0 at new
    /// moon, 180 at full, and under 180 while waxing.
    static func elongation(julianCentury t: Double) -> Double {
        Angles.normalized(longitude(julianCentury: t) - SolarGeometry.apparentLongitude(julianCentury: t))
    }

    /// The lit fraction of the disc for an elongation, 0 to 1.
    ///
    /// Meeus 48.4: the phase angle is very nearly 180° less the elongation,
    /// because the sun is four hundred times further away than the moon.
    /// The exact form differs by a few thousandths; the moon's latitude,
    /// ignored here, by less.
    static func illuminatedFraction(elongation: Double) -> Double {
        (1 - Angles.cos(elongation)) / 2
    }
}

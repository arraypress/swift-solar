//
//  LunarPhases.swift
//  Solar
//
//  The instants of new and full moon — Meeus, Astronomical Algorithms,
//  chapter 49, with every correction term he lists for those two phases.
//

import Foundation

/// New and full moons by their index `k` in Meeus's count, where `k = 0` is
/// the new moon of 6 January 2000 and each whole number is one lunation
/// later. Full moons sit at `k + 0.5`.
enum LunarPhases {

    /// Mean length of a lunation, days.
    static let synodicMonth = 29.530588861

    /// The difference between Dynamical Time, which the series is written
    /// in, and Universal Time, which clocks keep: seconds, for the 2020s.
    ///
    /// ΔT drifts by under a second a year at present. A constant here is
    /// good to a minute across two decades, which is finer than anything
    /// else in this file.
    static let deltaT: TimeInterval = 69

    /// The `k` of the mean new moon nearest an instant — fractional, so the
    /// caller can round in whichever direction it needs.
    static func meanIndex(of date: Date) -> Double {
        let years = (JulianDay.julianDay(date) - 2451545.0) / 365.25
        return years * 12.3685
    }

    /// The instant of the new moon of index `k`, in Universal Time.
    static func newMoon(index k: Double) -> Date {
        phase(index: k.rounded(), full: false)
    }

    /// The instant of the full moon of index `k + 0.5`, in Universal Time.
    static func fullMoon(index k: Double) -> Date {
        phase(index: k.rounded() + 0.5, full: true)
    }

    /// The last new moon at or before `date`.
    static func lastNewMoon(before date: Date) -> Date {
        var k = meanIndex(of: date).rounded(.down) + 1
        var moon = newMoon(index: k)
        while moon > date {
            k -= 1
            moon = newMoon(index: k)
        }
        return moon
    }

    /// The first new moon after `date`.
    static func nextNewMoon(after date: Date) -> Date {
        var k = meanIndex(of: date).rounded(.down) - 1
        var moon = newMoon(index: k)
        while moon <= date {
            k += 1
            moon = newMoon(index: k)
        }
        return moon
    }

    /// The first full moon after `date`.
    static func nextFullMoon(after date: Date) -> Date {
        var k = meanIndex(of: date).rounded(.down) - 2
        var moon = fullMoon(index: k)
        while moon <= date {
            k += 1
            moon = fullMoon(index: k)
        }
        return moon
    }

    /// Meeus 49.1 with the periodic terms of tables 49.A and 49.B.
    private static func phase(index k: Double, full: Bool) -> Date {
        let t = k / 1236.85
        var jde = 2451550.09766 + synodicMonth * k
            + 0.00015437 * t * t - 0.000000150 * t * t * t + 0.00000000073 * t * t * t * t

        let e = 1 - 0.002516 * t - 0.0000074 * t * t
        let m = Angles.normalized(2.5534 + 29.10535670 * k - 0.0000014 * t * t - 0.00000011 * t * t * t)
        let mPrime = Angles.normalized(201.5643 + 385.81693528 * k + 0.0107582 * t * t + 0.00001238 * t * t * t - 0.000000058 * t * t * t * t)
        let f = Angles.normalized(160.7108 + 390.67050284 * k - 0.0016118 * t * t - 0.00000227 * t * t * t + 0.000000011 * t * t * t * t)
        let omega = Angles.normalized(124.7746 - 1.56375588 * k + 0.0020672 * t * t + 0.00000215 * t * t * t)

        /// The two phases share every term but the first six coefficients,
        /// and those differ in the third decimal, not in sign. A transcription
        /// that flips the fifth and sixth puts the new moon 20 minutes out
        /// while every full moon still lands to the second — which is how
        /// it was caught.
        let (c1, c2, c3, c4, c5, c6) = full
            ? (-0.40614, 0.17302, 0.01614, 0.01043, 0.00734, -0.00515)
            : (-0.40720, 0.17241, 0.01608, 0.01039, 0.00739, -0.00514)

        var correction = c1 * Angles.sin(mPrime)
            + c2 * e * Angles.sin(m)
            + c3 * Angles.sin(2 * mPrime)
            + c4 * Angles.sin(2 * f)
            + c5 * e * Angles.sin(mPrime - m)
            + c6 * e * Angles.sin(mPrime + m)
            + 0.00208 * e * e * Angles.sin(2 * m)
            - 0.00111 * Angles.sin(mPrime - 2 * f)
            - 0.00057 * Angles.sin(mPrime + 2 * f)
            + 0.00056 * e * Angles.sin(2 * mPrime + m)
            - 0.00042 * Angles.sin(3 * mPrime)
            + 0.00042 * e * Angles.sin(m + 2 * f)
            + 0.00038 * e * Angles.sin(m - 2 * f)
            - 0.00024 * e * Angles.sin(2 * mPrime - m)
            - 0.00017 * Angles.sin(omega)
            - 0.00007 * Angles.sin(mPrime + 2 * m)
            + 0.00004 * Angles.sin(2 * mPrime - 2 * f)
            + 0.00004 * Angles.sin(3 * m)
            + 0.00003 * Angles.sin(mPrime + m - 2 * f)
            + 0.00003 * Angles.sin(2 * mPrime + 2 * f)
            - 0.00003 * Angles.sin(mPrime + m + 2 * f)
            + 0.00003 * Angles.sin(mPrime - m + 2 * f)
            - 0.00002 * Angles.sin(mPrime - m - 2 * f)
            - 0.00002 * Angles.sin(3 * mPrime + m)
            + 0.00002 * Angles.sin(4 * mPrime)

        /// The planetary arguments, table 49.B — the same for every phase.
        correction += 0.000325 * Angles.sin(299.77 + 0.107408 * k - 0.009173 * t * t)
            + 0.000165 * Angles.sin(251.88 + 0.016321 * k)
            + 0.000164 * Angles.sin(251.83 + 26.651886 * k)
            + 0.000126 * Angles.sin(349.42 + 36.412478 * k)
            + 0.000110 * Angles.sin(84.66 + 18.206239 * k)
            + 0.000062 * Angles.sin(141.74 + 53.303771 * k)
            + 0.000060 * Angles.sin(207.14 + 2.453732 * k)
            + 0.000056 * Angles.sin(154.84 + 7.306860 * k)
            + 0.000047 * Angles.sin(34.52 + 27.261239 * k)
            + 0.000042 * Angles.sin(207.19 + 0.121824 * k)
            + 0.000040 * Angles.sin(291.34 + 1.844379 * k)
            + 0.000037 * Angles.sin(161.72 + 24.198154 * k)
            + 0.000035 * Angles.sin(239.56 + 25.513099 * k)
            + 0.000023 * Angles.sin(331.55 + 3.592518 * k)

        jde += correction
        return JulianDay.date(julianDay: jde).addingTimeInterval(-deltaT)
    }
}

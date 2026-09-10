//
//  JulianDay.swift
//  Solar
//
//  The astronomers' clock: days since noon on 1 January 4713 BC, as one
//  number, which is what every series in this package is written against.
//

import Foundation

/// Conversions between `Date` and the Julian Day, and the century since J2000
/// that the solar and lunar series take as their variable.
enum JulianDay {

    /// The Julian Day of the Unix epoch, 1970-01-01 00:00 UTC.
    ///
    /// Half a day, because Julian days begin at noon and Unix days at
    /// midnight. Forgetting the .5 puts every event twelve hours out, which
    /// is exactly wrong enough to look like a time-zone bug.
    static let unixEpoch = 2440587.5

    /// The Julian Day of J2000.0, 2000-01-01 12:00 TT, the origin of every
    /// series here.
    static let j2000 = 2451545.0

    /// The Julian Day of an instant.
    static func julianDay(_ date: Date) -> Double {
        unixEpoch + date.timeIntervalSince1970 / 86_400
    }

    /// The instant of a Julian Day.
    static func date(julianDay: Double) -> Date {
        Date(timeIntervalSince1970: (julianDay - unixEpoch) * 86_400)
    }

    /// Julian centuries since J2000, the `T` of the almanac formulae.
    static func century(julianDay: Double) -> Double {
        (julianDay - j2000) / 36_525
    }

    /// Julian centuries since J2000 for an instant.
    static func century(of date: Date) -> Double {
        century(julianDay: julianDay(date))
    }
}

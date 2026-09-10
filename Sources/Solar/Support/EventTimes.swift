//
//  EventTimes.swift
//  Solar
//
//  Turning "the day of this date, in this zone" into the instants the sun
//  reaches each altitude — the NOAA calculator's method, refined at the
//  time of the event itself.
//

import Foundation

/// Solar noon and the altitude crossings for one calendar day.
enum EventTimes {

    /// A calendar day cut in a zone, with the UTC midnight that solar noon
    /// is counted from.
    struct Day {
        /// First instant of the day in its zone.
        let start: Date
        /// First instant of the next day in its zone.
        let end: Date
        /// The UTC midnight the day's events are counted from.
        let baseUTCMidnight: Date
        /// The transit that falls inside the day.
        let solarNoon: Date
    }

    /// The Gregorian calendar in a zone, for cutting days.
    static func calendar(in timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    /// The day in `timeZone` that contains `date`, with its solar noon.
    ///
    /// Solar noon is counted from a UTC midnight, and the first guess at
    /// which one is the UTC date that holds the *local* midday — for Sydney
    /// the local day starts on the previous UTC date, and counting from
    /// there lands on the wrong transit. The guess is then checked: the noon
    /// it produces must fall inside the day. It does not on the date line,
    /// where a zone can sit two hours from its solar time and the transit
    /// counted from the guessed midnight belongs to the day before or after.
    static func day(containing date: Date, in timeZone: TimeZone, longitude: Double) -> Day {
        let local = calendar(in: timeZone)
        let start = local.startOfDay(for: date)
        let end = local.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        let midday = start.addingTimeInterval(end.timeIntervalSince(start) / 2)
        let utc = calendar(in: TimeZone(identifier: "UTC")!)
        var base = utc.startOfDay(for: midday)
        var noon = solarNoon(from: base, longitude: longitude)
        if noon < start {
            base = base.addingTimeInterval(86_400)
            noon = solarNoon(from: base, longitude: longitude)
        } else if noon >= end {
            base = base.addingTimeInterval(-86_400)
            noon = solarNoon(from: base, longitude: longitude)
        }
        return Day(start: start, end: end, baseUTCMidnight: base, solarNoon: noon)
    }

    /// The instant of solar noon counted from a UTC midnight, at a longitude.
    ///
    /// 720 minutes after the base midnight, less four minutes per degree of
    /// east longitude, less the equation of time evaluated at the noon
    /// itself — which needs one round trip, because the equation of time is
    /// a function of the answer.
    static func solarNoon(from baseUTCMidnight: Date, longitude: Double) -> Date {
        var minutes = 720 - 4 * longitude
        for _ in 0..<2 {
            let estimate = baseUTCMidnight.addingTimeInterval(minutes * 60)
            minutes = 720 - 4 * longitude - SolarGeometry.equationOfTime(julianCentury: JulianDay.century(of: estimate))
        }
        return baseUTCMidnight.addingTimeInterval(minutes * 60)
    }

    /// The instant the sun's centre crosses `altitude` on `day`, rising or
    /// setting, at a coordinate.
    ///
    /// Three passes: the declination and the equation of time are taken at
    /// the crossing itself, not at noon, because the sun's declination
    /// moves nearly half a degree a day near the equinoxes and a sunrise
    /// eight hours before noon is computed against where the sun will be,
    /// not where it is at lunchtime. NOAA does one refinement; the third
    /// pass costs nothing and settles the last few seconds.
    static func crossing(
        altitude: Double, rising: Bool, on day: Day, latitude: Double, longitude: Double
    ) -> SolarEvent {
        var minutes = 720 - 4 * longitude
        for _ in 0..<3 {
            let estimate = day.baseUTCMidnight.addingTimeInterval(minutes * 60)
            let t = JulianDay.century(of: estimate)
            let declination = SolarGeometry.declination(julianCentury: t)
            switch HourAngle.sweep(latitude: latitude, declination: declination, altitude: altitude) {
            case .alwaysAbove:
                return .polarDay
            case .alwaysBelow:
                return .polarNight
            case .angle(let angle):
                let equationOfTime = SolarGeometry.equationOfTime(julianCentury: t)
                minutes = 720 - 4 * (longitude + (rising ? angle : -angle)) - equationOfTime
            }
        }
        return .at(day.baseUTCMidnight.addingTimeInterval(minutes * 60))
    }
}

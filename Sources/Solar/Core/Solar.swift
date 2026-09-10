//
//  Solar.swift
//  Solar
//
//  The namespace: where the sun is, and when it does what, for a place and a day.
//

import Foundation

/// Sunrise, sunset, twilight and the sun's position, computed on the
/// device for any place and date.
///
/// The arithmetic is NOAA's solar calculator's — Meeus's *Astronomical
/// Algorithms* term for term — which is what the printed almanacs, the
/// weather apps and the USNO agree with to the minute. Nothing here needs a
/// network, an API key or a location permission: a coordinate and a date
/// are the whole input.
///
/// Every question about a day is asked in a time zone, because "21 June"
/// is a different span of instants in Sydney and in Reykjavik. The zone
/// defaults to UTC rather than to the machine's, so the same call gives
/// the same answer on every machine; pass the place's zone to get its
/// calendar day.
public enum Solar {

    /// Everything the sun does on the calendar day in `timeZone` that
    /// contains `date`, seen from `coordinate`.
    ///
    /// Rise and set are the sun's centre at -0.833°, the almanac definition
    /// (``SunPosition/altitude`` explains the number). Twilights are at
    /// -6°, -12° and -18°. Each event is a ``SolarEvent`` so a day with no
    /// sunset says so rather than lying with a time.
    public static func day(
        _ date: Date, at coordinate: Coordinate, in timeZone: TimeZone = .gmt
    ) -> SolarDay {
        let day = EventTimes.day(containing: date, in: timeZone, longitude: coordinate.longitude)
        let noon = day.solarNoon

        func crossing(_ altitude: Double, rising: Bool) -> SolarEvent {
            EventTimes.crossing(
                altitude: altitude, rising: rising, on: day,
                latitude: coordinate.latitude, longitude: coordinate.longitude
            )
        }

        let sunrise = crossing(HourAngle.horizon, rising: true)
        let sunset = crossing(HourAngle.horizon, rising: false)
        let dayLength: TimeInterval
        switch (sunrise, sunset) {
        case (.at(let rise), .at(let set)): dayLength = set.timeIntervalSince(rise)
        case (.polarDay, _), (_, .polarDay): dayLength = day.end.timeIntervalSince(day.start)
        default: dayLength = 0
        }

        return SolarDay(
            start: day.start, end: day.end, timeZone: timeZone, coordinate: coordinate,
            sunrise: sunrise, sunset: sunset, solarNoon: noon, dayLength: dayLength,
            civilDawn: crossing(Twilight.civil.altitude, rising: true),
            civilDusk: crossing(Twilight.civil.altitude, rising: false),
            nauticalDawn: crossing(Twilight.nautical.altitude, rising: true),
            nauticalDusk: crossing(Twilight.nautical.altitude, rising: false),
            astronomicalDawn: crossing(Twilight.astronomical.altitude, rising: true),
            astronomicalDusk: crossing(Twilight.astronomical.altitude, rising: false)
        )
    }

    /// Where the sun stands in the sky at `date`, from `coordinate`.
    public static func position(at date: Date, coordinate: Coordinate) -> SunPosition {
        let altitude = SunAngles.altitude(at: date, latitude: coordinate.latitude, longitude: coordinate.longitude)
        return SunPosition(
            altitude: altitude,
            apparentAltitude: altitude + SunAngles.refraction(altitude: altitude),
            azimuth: SunAngles.azimuth(at: date, latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
    }

    /// Whether the sun is up at `date`, from `coordinate`, by the same
    /// definition as ``SolarDay/sunrise``.
    ///
    /// Asked of the instant, not of the day's events, so it needs no zone
    /// and cannot disagree with the sunrise and sunset it sits between.
    public static func isDaylight(at date: Date, coordinate: Coordinate) -> Bool {
        SunAngles.altitude(at: date, latitude: coordinate.latitude, longitude: coordinate.longitude) > HourAngle.horizon
    }

    /// The golden hours of the day: the sun between 4° below the horizon
    /// and 6° above it, morning and evening.
    ///
    /// The window exists when the sun crosses -4° that day. When it never
    /// climbs to 6° — a December day in Tromsø, where it peaks at -3° and
    /// never rises at all, or an Edinburgh one where it peaks at 11° but
    /// only just — the window runs to solar noon and the evening one starts
    /// there, because the light is golden all day and saying "none" would
    /// be the wrong answer to a photographer.
    public static func goldenHour(
        on date: Date, at coordinate: Coordinate, in timeZone: TimeZone = .gmt
    ) -> SolarWindows {
        windows(on: date, at: coordinate, in: timeZone, lower: -4, upper: 6, upperFallsBackToNoon: true)
    }

    /// The blue hours of the day: the sun between 6° and 4° below the
    /// horizon, morning and evening.
    ///
    /// Both crossings must happen for the window to exist. A June night at
    /// 61° north, where the sun dips to -5° and comes back, is one
    /// continuous blue hour across midnight with no edges to report, and
    /// that reads as `nil` here rather than as a window that ends at 23:59.
    public static func blueHour(
        on date: Date, at coordinate: Coordinate, in timeZone: TimeZone = .gmt
    ) -> SolarWindows {
        windows(on: date, at: coordinate, in: timeZone, lower: -6, upper: -4, upperFallsBackToNoon: false)
    }

    /// The morning and evening windows between two altitudes.
    private static func windows(
        on date: Date, at coordinate: Coordinate, in timeZone: TimeZone,
        lower: Double, upper: Double, upperFallsBackToNoon: Bool
    ) -> SolarWindows {
        let day = EventTimes.day(containing: date, in: timeZone, longitude: coordinate.longitude)
        let noon = day.solarNoon

        func crossing(_ altitude: Double, rising: Bool) -> Date? {
            let event = EventTimes.crossing(
                altitude: altitude, rising: rising, on: day,
                latitude: coordinate.latitude, longitude: coordinate.longitude
            )
            if case .at(let instant) = event { return instant }
            return nil
        }

        func window(rising: Bool) -> DateInterval? {
            guard let edge = crossing(lower, rising: rising) else { return nil }
            let inner: Date
            if let reached = crossing(upper, rising: rising) {
                inner = reached
            } else if upperFallsBackToNoon {
                inner = noon
            } else {
                return nil
            }
            return rising ? DateInterval(start: edge, end: max(edge, inner)) : DateInterval(start: inner, end: max(inner, edge))
        }

        return SolarWindows(morning: window(rising: true), evening: window(rising: false))
    }
}

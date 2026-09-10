//
//  SolarDay.swift
//  Solar
//

import Foundation

/// Everything the sun does on one calendar day, at one place.
///
/// The day is a calendar day in ``timeZone`` — from ``start`` to ``end`` —
/// and every event is the one that belongs to that day's solar noon.
/// ``sunset`` is the sunset that ends this day's daylight, which at high
/// latitudes in summer lands after midnight: Reykjavik's sun on 21 June
/// rises at 02:55 and sets at 00:04 the next morning. Listing the sunset
/// that merely fell inside the date would pair this morning's sunrise with
/// last night's sunset, which is the wrong answer to "when does the sun
/// set today".
public struct SolarDay: Sendable, Hashable, Codable {

    /// First instant of the day, in ``timeZone``.
    public let start: Date

    /// First instant of the next day, in ``timeZone``. 24 hours after
    /// ``start`` except on the two days a year that a zone changes its
    /// clocks, when it is 23 or 25.
    public let end: Date

    /// The zone the day was cut in.
    public let timeZone: TimeZone

    /// Where the sun was observed from.
    public let coordinate: Coordinate

    /// The sun's centre reaching -0.833°, rising.
    public let sunrise: SolarEvent

    /// The sun's centre reaching -0.833°, setting.
    public let sunset: SolarEvent

    /// The instant the sun crosses the meridian, when it is highest.
    ///
    /// Not 12:00. Clock time is the zone's mean, and the sun runs up to
    /// 16 minutes ahead or behind it through the year, plus four minutes
    /// for every degree of longitude from the zone's meridian.
    public let solarNoon: Date

    /// Seconds from sunrise to sunset; the whole day for ``SolarEvent/polarDay``,
    /// zero for ``SolarEvent/polarNight``.
    public let dayLength: TimeInterval

    /// Sun's centre reaching -6°, rising.
    public let civilDawn: SolarEvent

    /// Sun's centre reaching -6°, setting.
    public let civilDusk: SolarEvent

    /// Sun's centre reaching -12°, rising.
    public let nauticalDawn: SolarEvent

    /// Sun's centre reaching -12°, setting.
    public let nauticalDusk: SolarEvent

    /// Sun's centre reaching -18°, rising. The end of full darkness.
    public let astronomicalDawn: SolarEvent

    /// Sun's centre reaching -18°, setting. The start of full darkness.
    public let astronomicalDusk: SolarEvent

    /// Builds a day by hand — for a fixture or a preview. ``Solar/day(_:at:in:)``
    /// is the way to get a real one.
    public init(
        start: Date, end: Date, timeZone: TimeZone, coordinate: Coordinate,
        sunrise: SolarEvent, sunset: SolarEvent, solarNoon: Date, dayLength: TimeInterval,
        civilDawn: SolarEvent, civilDusk: SolarEvent,
        nauticalDawn: SolarEvent, nauticalDusk: SolarEvent,
        astronomicalDawn: SolarEvent, astronomicalDusk: SolarEvent
    ) {
        self.start = start
        self.end = end
        self.timeZone = timeZone
        self.coordinate = coordinate
        self.sunrise = sunrise
        self.sunset = sunset
        self.solarNoon = solarNoon
        self.dayLength = dayLength
        self.civilDawn = civilDawn
        self.civilDusk = civilDusk
        self.nauticalDawn = nauticalDawn
        self.nauticalDusk = nauticalDusk
        self.astronomicalDawn = astronomicalDawn
        self.astronomicalDusk = astronomicalDusk
    }
}

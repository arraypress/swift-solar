//
//  SolarDayTests.swift
//  Solar
//
//  Rise, set, noon and twilight against the US Naval Observatory. Every
//  expected time below is quoted from
//  https://aa.usno.navy.mil/api/rstt/oneday?date=…&coords=…&tz=… as fetched on
//  2026-09-10, to the minute the API prints; the tolerance is two minutes.
//

import XCTest
@testable import Solar

final class SolarDayTests: XCTestCase {

    // MARK: - Greenwich

    /// USNO 2026-06-21, 51.4769,0.0000, tz=1: civil 03:55, rise 04:43,
    /// transit 13:02, set 21:21, civil end 22:09.
    func testGreenwichAtTheSummerSolstice() {
        let day = Solar.day(localNoon("2026-06-21", in: london), at: Place.greenwich, in: london)
        assertEvent(day.civilDawn, is: "2026-06-21 03:55", in: london)
        assertEvent(day.sunrise, is: "2026-06-21 04:43", in: london)
        assertTime(day.solarNoon, is: "2026-06-21 13:02", in: london)
        assertEvent(day.sunset, is: "2026-06-21 21:21", in: london)
        assertEvent(day.civilDusk, is: "2026-06-21 22:09", in: london)
    }

    func testGreenwichInJuneNeverReachesAstronomicalDarkness() {
        // The sun bottoms out near -15° at 51.5° north in June: nautical
        // twilight ends, astronomical never does.
        let day = Solar.day(localNoon("2026-06-21", in: london), at: Place.greenwich, in: london)
        XCTAssertTrue(day.nauticalDawn.occurred)
        XCTAssertTrue(day.nauticalDusk.occurred)
        XCTAssertEqual(day.astronomicalDawn, .polarDay)
        XCTAssertEqual(day.astronomicalDusk, .polarDay)
    }

    /// USNO 2026-12-21, tz=0: civil 07:23, rise 08:03, transit 11:58,
    /// set 15:53, civil end 16:33.
    func testGreenwichAtTheWinterSolstice() {
        let day = Solar.day(localNoon("2026-12-21", in: london), at: Place.greenwich, in: london)
        assertEvent(day.civilDawn, is: "2026-12-21 07:23", in: london)
        assertEvent(day.sunrise, is: "2026-12-21 08:03", in: london)
        assertTime(day.solarNoon, is: "2026-12-21 11:58", in: london)
        assertEvent(day.sunset, is: "2026-12-21 15:53", in: london)
        assertEvent(day.civilDusk, is: "2026-12-21 16:33", in: london)
    }

    func testTheTwilightsComeInOrderOnAnOrdinaryDay() throws {
        let day = Solar.day(localNoon("2026-12-21", in: london), at: Place.greenwich, in: london)
        let morning = try [day.astronomicalDawn, day.nauticalDawn, day.civilDawn, day.sunrise].map { try XCTUnwrap($0.date) }
        let evening = try [day.sunset, day.civilDusk, day.nauticalDusk, day.astronomicalDusk].map { try XCTUnwrap($0.date) }
        XCTAssertEqual(morning, morning.sorted())
        XCTAssertEqual(evening, evening.sorted())
        XCTAssertLessThan(morning.last!, day.solarNoon)
        XCTAssertGreaterThan(evening.first!, day.solarNoon)
    }

    func testDayLengthIsSunsetLessSunrise() throws {
        let day = Solar.day(localNoon("2026-12-21", in: london), at: Place.greenwich, in: london)
        let rise = try XCTUnwrap(day.sunrise.date), set = try XCTUnwrap(day.sunset.date)
        XCTAssertEqual(day.dayLength, set.timeIntervalSince(rise))
        // 07:50 on the shortest day in London.
        XCTAssertEqual(day.dayLength, 7 * 3600 + 50 * 60, accuracy: 120)
    }

    // MARK: - Southern hemisphere, and a day that starts on the previous UTC date

    /// USNO 2026-12-21, -33.8688,151.2093, tz=11: civil 05:11, rise 05:41,
    /// transit 12:53, set 20:05, civil end 20:35.
    func testSydneyAtItsSummerSolstice() {
        let day = Solar.day(localNoon("2026-12-21", in: sydney), at: Place.sydney, in: sydney)
        assertEvent(day.civilDawn, is: "2026-12-21 05:11", in: sydney)
        assertEvent(day.sunrise, is: "2026-12-21 05:41", in: sydney)
        assertTime(day.solarNoon, is: "2026-12-21 12:53", in: sydney)
        assertEvent(day.sunset, is: "2026-12-21 20:05", in: sydney)
        assertEvent(day.civilDusk, is: "2026-12-21 20:35", in: sydney)
    }

    // MARK: - The equator

    /// USNO 2026-03-20, -0.1807,-78.4678, tz=-5: civil 05:57, rise 06:18,
    /// transit 12:21, set 18:24, civil end 18:45.
    func testQuitoAtTheEquinox() {
        let day = Solar.day(localNoon("2026-03-20", in: guayaquil), at: Place.quito, in: guayaquil)
        assertEvent(day.civilDawn, is: "2026-03-20 05:57", in: guayaquil)
        assertEvent(day.sunrise, is: "2026-03-20 06:18", in: guayaquil)
        assertTime(day.solarNoon, is: "2026-03-20 12:21", in: guayaquil)
        assertEvent(day.sunset, is: "2026-03-20 18:24", in: guayaquil)
        assertEvent(day.civilDusk, is: "2026-03-20 18:45", in: guayaquil)
    }

    /// USNO 2026-03-20, 0,0, tz=0: rise 06:04, transit 12:07, set 18:11.
    func testTheEquinoxDayIsSymmetricAboutNoonAtTheEquator() throws {
        let day = Solar.day(localNoon("2026-03-20", in: utc), at: Place.equator, in: utc)
        assertEvent(day.sunrise, is: "2026-03-20 06:04", in: utc)
        assertTime(day.solarNoon, is: "2026-03-20 12:07", in: utc)
        assertEvent(day.sunset, is: "2026-03-20 18:11", in: utc)
        let rise = try XCTUnwrap(day.sunrise.date), set = try XCTUnwrap(day.sunset.date)
        let morning = day.solarNoon.timeIntervalSince(rise)
        let evening = set.timeIntervalSince(day.solarNoon)
        XCTAssertEqual(morning, evening, accuracy: 90)
        // Twelve hours plus the seven minutes refraction and the disc add.
        XCTAssertEqual(day.dayLength, 12 * 3600 + 7 * 60, accuracy: 120)
    }

    // MARK: - The midnight sun

    /// USNO 2026-06-21, 64.1466,-21.9426, tz=0: continuously above the
    /// twilight limit, set 00:04, rise 02:55, transit 13:30. The 00:04 set is
    /// the one that ends the 21st's daylight, so here it is on the 22nd.
    func testReykjavikInJuneSetsAfterMidnight() {
        let day = Solar.day(localNoon("2026-06-21", in: reykjavik), at: Place.reykjavik, in: reykjavik)
        assertEvent(day.sunrise, is: "2026-06-21 02:55", in: reykjavik)
        assertTime(day.solarNoon, is: "2026-06-21 13:30", in: reykjavik)
        assertEvent(day.sunset, is: "2026-06-22 00:04", in: reykjavik)
        XCTAssertGreaterThan(day.sunset.date!, day.end, "the sunset that ends this day falls in the next")
        XCTAssertEqual(day.dayLength, 21 * 3600 + 9 * 60, accuracy: 120)
    }

    func testReykjavikInJuneSetsButNeverGetsDark() {
        let day = Solar.day(localNoon("2026-06-21", in: reykjavik), at: Place.reykjavik, in: reykjavik)
        XCTAssertTrue(day.sunset.occurred)
        XCTAssertEqual(day.civilDawn, .polarDay)
        XCTAssertEqual(day.civilDusk, .polarDay)
        XCTAssertEqual(day.nauticalDawn, .polarDay)
        XCTAssertEqual(day.astronomicalDusk, .polarDay)
    }

    /// USNO 2026-06-21, 69.6492,18.9553, tz=2: continuously above the horizon
    /// and the twilight limit, transit 12:46.
    func testTromsoInJuneIsPolarDay() {
        let day = Solar.day(localNoon("2026-06-21", in: oslo), at: Place.tromso, in: oslo)
        XCTAssertEqual(day.sunrise, .polarDay)
        XCTAssertEqual(day.sunset, .polarDay)
        for twilight in Twilight.allCases {
            XCTAssertEqual(day.dawn(twilight), .polarDay)
            XCTAssertEqual(day.dusk(twilight), .polarDay)
        }
        assertTime(day.solarNoon, is: "2026-06-21 12:46", in: oslo)
        XCTAssertEqual(day.dayLength, 86_400)
    }

    /// USNO 2026-12-21, tz=1: continuously below the horizon, civil 09:31,
    /// civil end 13:53.
    func testTromsoInDecemberIsPolarNightWithTwilight() {
        let day = Solar.day(localNoon("2026-12-21", in: oslo), at: Place.tromso, in: oslo)
        XCTAssertEqual(day.sunrise, .polarNight)
        XCTAssertEqual(day.sunset, .polarNight)
        XCTAssertEqual(day.dayLength, 0)
        assertEvent(day.civilDawn, is: "2026-12-21 09:31", in: oslo)
        assertEvent(day.civilDusk, is: "2026-12-21 13:53", in: oslo)
        XCTAssertTrue(day.nauticalDawn.occurred)
        XCTAssertTrue(day.astronomicalDawn.occurred)
        XCTAssertLessThan(day.astronomicalDawn.date!, day.nauticalDawn.date!)
        XCTAssertLessThan(day.nauticalDawn.date!, day.civilDawn.date!)
    }

    // MARK: - The poles

    /// USNO 2026-06-21, 90,0, tz=0: continuously above the horizon and the
    /// twilight limit, transit 12:02.
    func testTheNorthPoleInJuneIsPolarDayToEveryAltitude() {
        let day = Solar.day(localNoon("2026-06-21", in: utc), at: Place.northPole, in: utc)
        XCTAssertEqual(day.sunrise, .polarDay)
        XCTAssertEqual(day.sunset, .polarDay)
        XCTAssertEqual(day.astronomicalDawn, .polarDay)
        assertTime(day.solarNoon, is: "2026-06-21 12:02", in: utc)
        XCTAssertEqual(day.dayLength, 86_400)
    }

    /// USNO 2026-12-21, 90,0, tz=0: continuously below the horizon and the
    /// twilight limit.
    func testTheNorthPoleInDecemberIsPolarNightToEveryAltitude() {
        let day = Solar.day(localNoon("2026-12-21", in: utc), at: Place.northPole, in: utc)
        XCTAssertEqual(day.sunrise, .polarNight)
        XCTAssertEqual(day.sunset, .polarNight)
        XCTAssertEqual(day.civilDawn, .polarNight)
        XCTAssertEqual(day.astronomicalDusk, .polarNight)
        XCTAssertEqual(day.dayLength, 0)
    }

    func testTheSouthPoleIsTheNorthPoleSixMonthsLater() {
        let june = Solar.day(localNoon("2026-06-21", in: utc), at: Place.southPole, in: utc)
        let december = Solar.day(localNoon("2026-12-21", in: utc), at: Place.southPole, in: utc)
        XCTAssertEqual(june.sunrise, .polarNight)
        XCTAssertEqual(june.dayLength, 0)
        XCTAssertEqual(december.sunrise, .polarDay)
        XCTAssertEqual(december.dayLength, 86_400)
    }

    /// USNO 2026-06-21, 61,0, tz=0: continuously above the twilight limit,
    /// rise 02:24, transit 12:02, set 21:40.
    func testSixtyOneNorthInJuneSetsButStaysInCivilTwilight() {
        let day = Solar.day(localNoon("2026-06-21", in: utc), at: Place.sixtyOneNorth, in: utc)
        assertEvent(day.sunrise, is: "2026-06-21 02:24", in: utc)
        assertEvent(day.sunset, is: "2026-06-21 21:40", in: utc)
        XCTAssertEqual(day.civilDawn, .polarDay)
        XCTAssertEqual(day.civilDusk, .polarDay)
    }

    // MARK: - The date line

    /// USNO 2026-06-21, 1.8721,-157.4278, tz=14: rise 06:24, transit 12:31,
    /// set 18:38. Kiritimati keeps a clock two hours ahead of its sun, and
    /// its calendar day starts on the previous UTC date.
    func testKiritimatiKeepsItsEventsInsideItsOwnDay() {
        let day = Solar.day(localNoon("2026-06-21", in: kiritimati), at: Place.kiritimati, in: kiritimati)
        assertEvent(day.sunrise, is: "2026-06-21 06:24", in: kiritimati)
        assertTime(day.solarNoon, is: "2026-06-21 12:31", in: kiritimati)
        assertEvent(day.sunset, is: "2026-06-21 18:38", in: kiritimati)
        XCTAssertGreaterThanOrEqual(day.solarNoon, day.start)
        XCTAssertLessThan(day.solarNoon, day.end)
    }

    func testLongitude180AndMinus180AreTheSamePlace() throws {
        let east = try Coordinate(latitude: 0, longitude: 180)
        let west = try Coordinate(latitude: 0, longitude: -180)
        let date = localNoon("2026-06-21", in: utc)
        let eastDay = Solar.day(date, at: east, in: utc)
        let westDay = Solar.day(date, at: west, in: utc)
        XCTAssertEqual(eastDay.solarNoon.timeIntervalSince(westDay.solarNoon), 0, accuracy: 1)
        XCTAssertEqual(try XCTUnwrap(eastDay.sunrise.date).timeIntervalSince(try XCTUnwrap(westDay.sunrise.date)), 0, accuracy: 1)
    }

    // MARK: - Day boundaries and clock changes

    func testOneMinuteEitherSideOfMidnightIsTwoDifferentDays() {
        let before = Solar.day(wall("2026-06-21 23:59", in: london), at: Place.greenwich, in: london)
        let after = Solar.day(wall("2026-06-22 00:01", in: london), at: Place.greenwich, in: london)
        XCTAssertEqual(before.start, wall("2026-06-21 00:00", in: london))
        XCTAssertEqual(after.start, wall("2026-06-22 00:00", in: london))
        XCTAssertEqual(before.end, after.start)
        XCTAssertNotEqual(before.sunrise, after.sunrise)
    }

    /// USNO 2026-03-29, tz=0: rise 05:42, set 18:28. The clocks go forward
    /// at 01:00 that morning, so the day is 23 hours long.
    func testTheDayTheClocksGoForwardIsTwentyThreeHours() {
        let day = Solar.day(localNoon("2026-03-29", in: london), at: Place.greenwich, in: london)
        XCTAssertEqual(day.end.timeIntervalSince(day.start), 23 * 3600)
        assertEvent(day.sunrise, is: "2026-03-29 05:42", in: utc)
        assertEvent(day.sunset, is: "2026-03-29 18:28", in: utc)
    }

    /// USNO 2026-10-25, tz=0: rise 06:41, set 16:46. Clocks go back at 02:00
    /// BST, so the day is 25 hours long.
    func testTheDayTheClocksGoBackIsTwentyFiveHours() {
        let day = Solar.day(localNoon("2026-10-25", in: london), at: Place.greenwich, in: london)
        XCTAssertEqual(day.end.timeIntervalSince(day.start), 25 * 3600)
        assertEvent(day.sunrise, is: "2026-10-25 06:41", in: utc)
        assertEvent(day.sunset, is: "2026-10-25 16:46", in: utc)
    }

    // MARK: - Other centuries and a leap day

    /// USNO 1900-06-21, tz=0: civil 02:55, rise 03:42, transit 12:01,
    /// set 20:21, civil end 21:08.
    func testGreenwichInNineteenHundred() {
        let day = Solar.day(localNoon("1900-06-21", in: utc), at: Place.greenwich, in: utc)
        assertEvent(day.civilDawn, is: "1900-06-21 02:55", in: utc)
        assertEvent(day.sunrise, is: "1900-06-21 03:42", in: utc)
        assertTime(day.solarNoon, is: "1900-06-21 12:01", in: utc)
        assertEvent(day.sunset, is: "1900-06-21 20:21", in: utc)
        assertEvent(day.civilDusk, is: "1900-06-21 21:08", in: utc)
    }

    /// USNO 2100-06-21, tz=0: rise 03:43, transit 12:02, set 20:21.
    func testGreenwichInTwentyOneHundred() {
        let day = Solar.day(localNoon("2100-06-21", in: utc), at: Place.greenwich, in: utc)
        assertEvent(day.sunrise, is: "2100-06-21 03:43", in: utc)
        assertTime(day.solarNoon, is: "2100-06-21 12:02", in: utc)
        assertEvent(day.sunset, is: "2100-06-21 20:21", in: utc)
    }

    /// USNO 2028-02-29, tz=0: civil 06:13, rise 06:46, transit 12:12,
    /// set 17:39, civil end 18:13.
    func testALeapDayIsAnOrdinaryDay() {
        let day = Solar.day(localNoon("2028-02-29", in: utc), at: Place.greenwich, in: utc)
        assertEvent(day.civilDawn, is: "2028-02-29 06:13", in: utc)
        assertEvent(day.sunrise, is: "2028-02-29 06:46", in: utc)
        assertTime(day.solarNoon, is: "2028-02-29 12:12", in: utc)
        assertEvent(day.sunset, is: "2028-02-29 17:39", in: utc)
        assertEvent(day.civilDusk, is: "2028-02-29 18:13", in: utc)
    }

    // MARK: - The API's own shape

    func testTheZoneDefaultsToUTC() {
        let date = instant("2026-06-21T12:00:00Z")
        XCTAssertEqual(Solar.day(date, at: Place.greenwich), Solar.day(date, at: Place.greenwich, in: .gmt))
        XCTAssertEqual(Solar.day(date, at: Place.greenwich).timeZone, .gmt)
    }

    func testTheDayRecordsWhatItWasAskedAbout() {
        let day = Solar.day(localNoon("2026-06-21", in: sydney), at: Place.sydney, in: sydney)
        XCTAssertEqual(day.coordinate, Place.sydney)
        XCTAssertEqual(day.timeZone, sydney)
        XCTAssertEqual(day.start, wall("2026-06-21 00:00", in: sydney))
        XCTAssertEqual(day.end, wall("2026-06-22 00:00", in: sydney))
    }

    func testDawnAndDuskByNameMatchTheProperties() {
        let day = Solar.day(localNoon("2026-12-21", in: london), at: Place.greenwich, in: london)
        XCTAssertEqual(day.dawn(.civil), day.civilDawn)
        XCTAssertEqual(day.dawn(.nautical), day.nauticalDawn)
        XCTAssertEqual(day.dawn(.astronomical), day.astronomicalDawn)
        XCTAssertEqual(day.dusk(.civil), day.civilDusk)
        XCTAssertEqual(day.dusk(.nautical), day.nauticalDusk)
        XCTAssertEqual(day.dusk(.astronomical), day.astronomicalDusk)
    }

    func testASolarDayRoundTripsThroughCodableWithAndWithoutEvents() throws {
        let ordinary = Solar.day(localNoon("2026-12-21", in: london), at: Place.greenwich, in: london)
        let polar = Solar.day(localNoon("2026-06-21", in: oslo), at: Place.tromso, in: oslo)
        XCTAssertEqual(try roundTrip(ordinary), ordinary)
        XCTAssertEqual(try roundTrip(polar), polar)
    }
}

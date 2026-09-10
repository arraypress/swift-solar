//
//  Fixtures.swift
//  Solar
//
//  Fixed places, fixed dates, and the almanac's answers. Every reference time
//  in this suite was fetched from the US Naval Observatory's API on 2026-09-10
//  and is quoted in the test that uses it, so a failure names the authority it
//  disagrees with.
//

import XCTest
@testable import Solar

let utc = TimeZone(identifier: "UTC")!
let london = TimeZone(identifier: "Europe/London")!
let sydney = TimeZone(identifier: "Australia/Sydney")!
let reykjavik = TimeZone(identifier: "Atlantic/Reykjavik")!
let oslo = TimeZone(identifier: "Europe/Oslo")!
let guayaquil = TimeZone(identifier: "America/Guayaquil")!
let kiritimati = TimeZone(identifier: "Pacific/Kiritimati")!

/// Places, latitude first, as the USNO query took them.
enum Place {
    static let greenwich = try! Coordinate(latitude: 51.4769, longitude: 0.0)
    static let sydney = try! Coordinate(latitude: -33.8688, longitude: 151.2093)
    static let reykjavik = try! Coordinate(latitude: 64.1466, longitude: -21.9426)
    static let tromso = try! Coordinate(latitude: 69.6492, longitude: 18.9553)
    static let quito = try! Coordinate(latitude: -0.1807, longitude: -78.4678)
    static let kiritimati = try! Coordinate(latitude: 1.8721, longitude: -157.4278)
    static let equator = try! Coordinate(latitude: 0, longitude: 0)
    static let northPole = try! Coordinate(latitude: 90, longitude: 0)
    static let southPole = try! Coordinate(latitude: -90, longitude: 0)
    static let sixtyOneNorth = try! Coordinate(latitude: 61, longitude: 0)
}

/// An instant from an ISO 8601 string ending in Z.
func instant(_ iso: String) -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    guard let date = formatter.date(from: iso) else { fatalError("bad fixture \(iso)") }
    return date
}

/// Noon by the clock on a calendar day in a zone — a safe instant to ask
/// about that day, since 12:00 exists on every day of every zone.
func localNoon(_ day: String, in zone: TimeZone) -> Date {
    wall("\(day) 12:00", in: zone)
}

/// A wall-clock time in a zone, from "yyyy-MM-dd HH:mm".
func wall(_ text: String, in zone: TimeZone) -> Date {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = zone
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    guard let date = formatter.date(from: text) else { fatalError("bad fixture \(text)") }
    return date
}

/// The wall-clock reading of an instant in a zone, for failure messages.
func clock(_ date: Date, in zone: TimeZone) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = zone
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: date)
}

/// Asserts an instant lands within `tolerance` of a wall-clock time in a zone.
func assertTime(
    _ date: Date, is expected: String, in zone: TimeZone, tolerance: TimeInterval = 120,
    file: StaticString = #filePath, line: UInt = #line
) {
    let target = wall(expected, in: zone)
    let difference = abs(date.timeIntervalSince(target))
    XCTAssertLessThanOrEqual(
        difference, tolerance,
        "expected \(expected), got \(clock(date, in: zone)) — \(Int(difference)) s out",
        file: file, line: line
    )
}

/// Asserts an event happened, within `tolerance` of a wall-clock time in a zone.
func assertEvent(
    _ event: SolarEvent, is expected: String, in zone: TimeZone, tolerance: TimeInterval = 120,
    file: StaticString = #filePath, line: UInt = #line
) {
    guard case .at(let date) = event else {
        XCTFail("expected \(expected), got \(event)", file: file, line: line)
        return
    }
    assertTime(date, is: expected, in: zone, tolerance: tolerance, file: file, line: line)
}

/// Encodes and decodes a value, returning what came back.
func roundTrip<T: Codable>(_ value: T) throws -> T {
    let data = try JSONEncoder().encode(value)
    return try JSONDecoder().decode(T.self, from: data)
}

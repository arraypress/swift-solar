//
//  MoonPhase.swift
//  Solar
//

import Foundation

/// The moon at one instant: how much of it is lit, which way it is going,
/// and when the next new and full moons are.
///
/// The moon's phase is the same everywhere on Earth at a given instant, so
/// unlike everything in ``SolarDay`` this needs no coordinate.
public struct MoonPhase: Sendable, Hashable, Codable {

    /// The lit fraction of the disc, 0 at new and 1 at full.
    public let illuminatedFraction: Double

    /// Days since the last new moon, 0 to about 29.5.
    ///
    /// Counted from the actual last new moon, not from the mean cycle: the
    /// moon's orbit is eccentric enough that the two disagree by up to
    /// half a day.
    public let age: Double

    /// Whether the lit part is growing. True from new moon to full.
    public let isWaxing: Bool

    /// Which eighth of the cycle this instant falls in.
    public let name: MoonPhaseName

    /// The new moon this age is counted from.
    public let lastNewMoon: Date

    /// The first new moon after this instant.
    public let nextNewMoon: Date

    /// The first full moon after this instant.
    public let nextFullMoon: Date

    /// Builds a phase by hand — for a fixture or a preview. ``Moon/phase(at:)``
    /// computes a real one.
    public init(
        illuminatedFraction: Double, age: Double, isWaxing: Bool, name: MoonPhaseName,
        lastNewMoon: Date, nextNewMoon: Date, nextFullMoon: Date
    ) {
        self.illuminatedFraction = illuminatedFraction
        self.age = age
        self.isWaxing = isWaxing
        self.name = name
        self.lastNewMoon = lastNewMoon
        self.nextNewMoon = nextNewMoon
        self.nextFullMoon = nextFullMoon
    }
}

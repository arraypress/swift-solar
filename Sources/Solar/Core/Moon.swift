//
//  Moon.swift
//  Solar
//
//  The moon's phase, which is the same from everywhere on Earth.
//

import Foundation

/// The phase of the moon, computed on the device.
///
/// Meeus's series for the moon's longitude and for the instants of new and
/// full moon, which put the instants within a couple of minutes of the
/// USNO's and the lit fraction within a hundredth. Rising and setting are
/// not here: they depend on the place, move by almost an hour a day, and
/// need the moon's parallax and distance — a different and larger piece of
/// work than a phase.
public enum Moon {

    /// The moon at `date`: lit fraction, age, phase name, and the next new
    /// and full moons.
    public static func phase(at date: Date) -> MoonPhase {
        let elongation = MoonGeometry.elongation(julianCentury: JulianDay.century(of: date))
        let lastNew = LunarPhases.lastNewMoon(before: date)
        let eighth = Int(((elongation + 22.5) / 45).rounded(.down)) % 8
        return MoonPhase(
            illuminatedFraction: MoonGeometry.illuminatedFraction(elongation: elongation),
            age: date.timeIntervalSince(lastNew) / 86_400,
            isWaxing: elongation < 180,
            name: MoonPhaseName.allCases[eighth],
            lastNewMoon: lastNew,
            nextNewMoon: LunarPhases.nextNewMoon(after: date),
            nextFullMoon: LunarPhases.nextFullMoon(after: date)
        )
    }
}

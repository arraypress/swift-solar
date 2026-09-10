//
//  Sweep.swift
//  Solar
//

import Foundation

/// The answer to "at what hour angle does the sun reach this altitude" —
/// including the two answers that are not an angle.
///
/// Internal twin of ``SolarEvent``: the same three outcomes before they are
/// turned into a time of day.
enum Sweep: Equatable {

    /// The sun reaches the altitude this many degrees of hour angle either
    /// side of solar noon.
    case angle(Double)

    /// The sun never gets down to the altitude that day.
    case alwaysAbove

    /// The sun never gets up to the altitude that day.
    case alwaysBelow
}

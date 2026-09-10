//
//  SolarEvent+Date.swift
//  Solar
//

import Foundation

extension SolarEvent {

    /// The instant, for callers that only want to format it and are happy
    /// to print nothing for a day that had no such event.
    public var date: Date? {
        if case .at(let instant) = self { return instant }
        return nil
    }

    /// Whether the crossing happened at all that day.
    public var occurred: Bool {
        date != nil
    }
}

//
//  LineChartDataPoint.swift
//
//
//  Created by Will Dale on 24/01/2021.
//

import SwiftUI

/**
 Data for a single data point.
 */
public struct LineChartDataPoint: CTStandardLineDataPoint, IgnoreMe {
  public let id: UUID = UUID()
  public var value: Double
  public var xAxisLabel: String?
  public var description: String?
  public var date: Date?
  public var pointColour: PointColour?
  public var anyData: Any?
  public var ignoreMe: Bool = false
  public var legendTag: String = ""
  
  /// Data model for a single data point with colour for use with a line chart.
  /// - Parameters:
  ///   - value: Value of the data point
  ///   - xAxisLabel: Label that can be shown on the X axis.
  ///   - description: A longer label that can be shown on touch input.
  ///   - date: Date of the data point if any data based calculations are required.
  ///   - pointColour: Colour of the point markers.
  ///   - anyData: Any Data
  public init(
    value: Double,
    xAxisLabel: String? = nil,
    description: String? = nil,
    date: Date? = nil,
    pointColour: PointColour? = nil,
    anyData: Any? = nil
  ) {
    self.value = value
    self.xAxisLabel = xAxisLabel
    self.description = description
    self.date = date
    self.pointColour = pointColour
    self.anyData = anyData
  }
}

// MARK: - Equatable and Hashable

extension LineChartDataPoint: Equatable, Hashable {
  public static func == (lhs: LineChartDataPoint, rhs: LineChartDataPoint) -> Bool {
    return lhs.id == rhs.id &&
    lhs.value == rhs.value &&
    lhs.xAxisLabel == rhs.xAxisLabel &&
    lhs.description == rhs.description &&
    lhs.date == rhs.date &&
    lhs.pointColour == rhs.pointColour &&
    lhs.legendTag == rhs.legendTag
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(value)
    hasher.combine(xAxisLabel)
    hasher.combine(description)
    hasher.combine(date)
    hasher.combine(pointColour)
    hasher.combine(legendTag)
  }
}

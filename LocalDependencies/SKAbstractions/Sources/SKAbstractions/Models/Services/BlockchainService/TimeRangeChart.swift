//
//  TimeRangeChart.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 31.05.2024.
//

import Foundation

/// Перечисление, представляющее временные диапазоны для запросов статистики или данных.
public enum TimeRangeChart: String {
  /// Диапазон времени один день.
  case day = "1day"
  /// Диапазон времени одна неделя.
  case week = "1week"
  /// Диапазон времени один месяц.
  case month = "1month"
  /// Диапазон времени один год.
  case year = "1year"
  /// Диапазон времени три года.
  case threeYears = "3years"
}

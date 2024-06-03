//
//  ChartSectionView+Model.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 07.05.2024.
//

import Foundation
import SwiftUICharts

// MARK: - Model

extension ChartSectionView {
  public struct Model {
    
    // MARK: - Public properties
    
    /// Часовой график
    public let hours: [Point]
    /// Дневной график
    public let days: [Point]
    /// Недельный график
    public let weeks: [Point]
    /// Месячный график
    public let months: [Point]
    /// Годовой график
    public let yearly: [Point]
    /// За все время график
    public let allTime: [Point]
    
    // MARK: - Initialization
    
    /// - Parameters:
    ///   - hours: Массив точек данных для часового графика.
    ///   - days: Массив точек данных для дневного графика.
    ///   - weeks: Массив точек данных для недельного графика.
    ///   - months: Массив точек данных для месячного графика.
    ///   - yearly: Массив точек данных для годового графика.
    ///   - allTime: Массив точек данных для графика за все время.
    public init(
      hours: [ChartSectionView.Point],
      days: [ChartSectionView.Point],
      weeks: [ChartSectionView.Point],
      months: [ChartSectionView.Point],
      yearly: [ChartSectionView.Point],
      allTime: [ChartSectionView.Point]
    ) {
      self.hours = hours
      self.days = days
      self.weeks = weeks
      self.months = months
      self.yearly = yearly
      self.allTime = allTime
    }
  }
}

// MARK: - Point

extension ChartSectionView {
  public struct Point {
    
    // MARK: - Public properties
    
    /// Текущая цена в валюте
    public let currentPriceInCurrency: Double
    /// Символ валюты
    public let currencySymbol: String
    /// Доход в процентах
    public let incomeAsPercentage: Double
    /// Доход в валюте
    public let incomeInCurrency: Double
    /// Текущая дата
    public let date: String
    
    // MARK: - Initialization
    
    /// - Parameters:
    ///  - currentPriceInCurrency: Текущая цена объекта в валюте.
    ///  - currencySymbol: Символ используемой валюты.
    ///  - incomeAsPercentage: Доход или убыток в процентном отношении от начальной цены.
    ///  - incomeInCurrency: Доход или убыток в абсолютном выражении в валюте.
    ///  - date: Строковое представление даты, соответствующей текущим значениям. "пт, 26 мая 18:39"
    public init(
      currentPriceInCurrency: Double,
      currencySymbol: String,
      incomeAsPercentage: Double,
      incomeInCurrency: Double,
      date: String
    ) {
      self.currentPriceInCurrency = currentPriceInCurrency
      self.currencySymbol = currencySymbol
      self.incomeAsPercentage = incomeAsPercentage
      self.incomeInCurrency = incomeInCurrency
      self.date = date
    }
  }
}

// MARK: - ChartType

extension ChartSectionView {
  public enum IncomeType {
    /// Цена пошла вверх
    case plus
    /// Цена пошла вниз
    case minus
    /// Цена на месте
    case none
  }
}

// MARK: - ChartType

extension ChartSectionView {
  public enum ChartType {
    /// Часовой график
    case hours
    /// Дневной график
    case days
    /// Недельный график
    case weeks
    /// Месячный график
    case months
    /// Годовой график
    case yearly
    /// За все время график
    case allTime
  }
}

// MARK: - MockModel

extension ChartSectionView {
  public static func mockModel() -> Model {
    let formatter = DateFormatter()
    formatter.dateFormat = "EE, d MMM HH:mm"
    formatter.locale = Locale(identifier: "ru_RU")
    let baseDate = Date()
    
    func generatePoints(type: ChartType, count: Int) -> [Point] {
      var points = [Point]()
      let calendar = Calendar.current
      var dateComponent: Calendar.Component
      
      switch type {
      case .hours:
        dateComponent = .hour
      case .days:
        dateComponent = .day
      case .weeks:
        dateComponent = .weekOfYear
      case .months:
        dateComponent = .month
      case .yearly:
        dateComponent = .year
      case .allTime:
        dateComponent = .year
      }
      
      for i in 0..<count {
        let date = calendar.date(byAdding: dateComponent, value: -i, to: baseDate)!
        let dateString = formatter.string(from: date)
        let point = Point(
          currentPriceInCurrency: Double.random(in: 100.0...500.0),
          currencySymbol: "$",
          incomeAsPercentage: Double.random(in: -5.0...5.0),
          incomeInCurrency: Double.random(in: -20.0...20.0),
          date: dateString
        )
        points.insert(point, at: 0)
      }
      return points
    }
    
    return Model(
      hours: generatePoints(type: .hours, count: 24), // 24 часовые точки
      days: generatePoints(type: .days, count: 7), // 7 дней
      weeks: generatePoints(type: .weeks, count: 4), // 4 недели
      months: generatePoints(type: .months, count: 12), // 12 месяцев
      yearly: generatePoints(type: .yearly, count: 5), // 5 лет
      allTime: generatePoints(type: .allTime, count: 10) // 10 лет, для примера
    )
  }
}


// MARK: - Mapping Point to LineChartDataPoint

extension ChartSectionView.Point {
  func mapTo() -> LineChartDataPoint {
    LineChartDataPoint(
      value: currentPriceInCurrency,
      anyData: self
    )
  }
}

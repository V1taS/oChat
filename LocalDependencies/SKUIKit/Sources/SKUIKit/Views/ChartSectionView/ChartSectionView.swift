//
//  ChartSectionView.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 05.05.2024.
//

import SwiftUI
import SwiftUICharts
import SKStyle
import SKFoundation

public struct ChartSectionView: View {
  
  // MARK: - Private properties
  
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  @State private var uniqueValue: Double?
  @State private var chartType: ChartSectionView.ChartType = .weeks
  @State private var currentPoints: [ChartSectionView.Point] = []
  @State private var selectedPoint: ChartSectionView.Point?
  @State private var incomeType: ChartSectionView.IncomeType = .none
  @State private var lineChartData: LineChartData = .init(dataSets: .init(dataPoints: []))
  
  @State private var maxCurrency: Double?
  @State private var minCurrency: Double?
  
  private let model: ChartSectionView.Model
  
  // MARK: - Initialization
  
  /// Инициализатор для создания основной кнопки
  /// - Parameters:
  ///   - style: Стиль вью
  public init(_ model: ChartSectionView.Model) {
    self.model = model
  }
  
  public var body: some View {
    VStack {
      HStack {
        VStack(alignment: .leading, spacing: .s1) {
          Text(formatPrimaryTitle())
            .multilineTextAlignment(.leading)
            .font(.fancy.text.title)
            .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
          
          HStack(spacing: .s2) {
            Text(formatSecondaryPercentageTitle())
              .multilineTextAlignment(.leading)
              .font(.fancy.text.regularMedium)
              .foregroundColor(getColorForIncome())
            
            Text(formatSecondaryCurrencyTitle())
              .multilineTextAlignment(.leading)
              .font(.fancy.text.regularMedium)
              .foregroundColor(getColorForIncome())
              .opacity(0.5)
          }
          
          HStack {
            Text(formatTertiaryTitle())
              .multilineTextAlignment(.leading)
              .font(.fancy.text.regularMedium)
              .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
            
            Spacer()
            
            if let maxCurrency {
              Text("\(String(format: "%.2f", maxCurrency).formattedWithSpaces()) \(currentPoints.first?.currencySymbol ?? "")")
                .multilineTextAlignment(.leading)
                .font(.fancy.text.regular)
                .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
            }
          }
        }
      }
      .padding(.horizontal, .s4)
      .padding(.top, .s2)
      
      VStack {
        ZStack {
          FilledLineChart(chartData: lineChartData)
            .touchOverlay(
              chartData: lineChartData,
              onChartDrag: { point in
                guard let point = point?.anyData as? ChartSectionView.Point else {
                  return
                }
                
                if self.uniqueValue != point.currentPriceInCurrency {
                  impactFeedback.impactOccurred()
                }
                
                self.uniqueValue = point.currentPriceInCurrency
                
                self.selectedPoint = point
                updateIncomeTypeWith(percentage: point.incomeAsPercentage)
                minCurrency = nil
                maxCurrency = nil
              },
              onEndedChartDrag: { _ in
                self.selectedPoint = nil
                updateIncomeTypeWith(percentage: currentPoints.last?.incomeAsPercentage)
                updateMaxAndMinCurrency()
              }
            )
            .id(lineChartData.id)
            .frame(height: 200)
          
          VStack {
            Spacer()
            HStack {
              Spacer()
              if let minCurrency {
                Text("\(String(format: "%.2f", minCurrency).formattedWithSpaces()) \(currentPoints.first?.currencySymbol ?? "")")
                  .multilineTextAlignment(.leading)
                  .font(.fancy.text.regular)
                  .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
              } else {
                Text(" ")
                  .multilineTextAlignment(.leading)
                  .font(.fancy.text.regular)
                  .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
              }
            }
          }
          .padding(.horizontal, .s4)
          
        }
      }
      createPeriodButtons()
    }
    .onAppear {
      lineChartData = getLineChartData(chartType: chartType)
      updateIncomeTypeWith(percentage: currentPoints.last?.incomeAsPercentage)
      updateMaxAndMinCurrency()
    }
  }
}

// MARK: - Private

private extension ChartSectionView {
  func createPeriodButtons() -> some View {
    HStack(spacing: .zero) {
      Spacer()
      if !model.hours.isEmpty {
        RoundButtonView(
          style: .custom(text: SKUIKitStrings.State.hours, backgroundColor: nil),
          isSelected: chartType == .hours,
          action: {
            chartType = .hours
            lineChartData = getLineChartData(chartType: chartType)
          }
        )
      }
      
      Spacer()
      
      if !model.days.isEmpty {
        RoundButtonView(
          style: .custom(text: SKUIKitStrings.State.days, backgroundColor: nil),
          isSelected: chartType == .days,
          action: {
            chartType = .days
            lineChartData = getLineChartData(chartType: chartType)
          }
        )
      }
      
      
      Spacer()
      
      if !model.weeks.isEmpty {
        RoundButtonView(
          style: .custom(text: SKUIKitStrings.State.weeks, backgroundColor: nil),
          isSelected: chartType == .weeks,
          action: {
            chartType = .weeks
            lineChartData = getLineChartData(chartType: chartType)
          }
        )
      }
      
      Spacer()
      
      if !model.months.isEmpty {
        RoundButtonView(
          style: .custom(text: SKUIKitStrings.State.months, backgroundColor: nil),
          isSelected: chartType == .months,
          action: {
            chartType = .months
            lineChartData = getLineChartData(chartType: chartType)
          }
        )
      }
      
      Spacer()
      
      if !model.yearly.isEmpty {
        RoundButtonView(
          style: .custom(text: SKUIKitStrings.State.yearly, backgroundColor: nil),
          isSelected: chartType == .yearly,
          action: {
            chartType = .yearly
            lineChartData = getLineChartData(chartType: chartType)
          }
        )
      }
      
      Spacer()
      
      if !model.allTime.isEmpty {
        RoundButtonView(
          style: .custom(text: SKUIKitStrings.State.allTime, backgroundColor: nil),
          isSelected: chartType == .allTime,
          action: {
            chartType = .allTime
            lineChartData = getLineChartData(chartType: chartType)
          }
        )
      }
      
      Spacer()
    }
  }
  
  func getLineChartData(chartType: ChartSectionView.ChartType) -> LineChartData {
    let lineChartDataPointModels = getLineChartDataPoint(chartType)
    let data = LineDataSet(
      dataPoints: lineChartDataPointModels,
      style: LineStyle(
        lineColour: .init(
          colours: [
            SKStyleAsset.constantAzure.swiftUIColor,
            .clear
          ],
          startPoint: .top,
          endPoint: .bottom
        ),
        lineType: .curvedLine,
        ignoreZero: true
      )
    )
    
    let chartStyle = LineChartStyle(
      markerType: .vertical(
        attachment: .line(
          dot: .style(
            .init(
              size: .s4,
              fillColour: SKStyleAsset.constantAzure.swiftUIColor,
              lineColour: SKStyleAsset.onyx.swiftUIColor
            )
          )
        ),
        colour: SKStyleAsset.constantAzure.swiftUIColor,
        style: StrokeStyle(lineWidth: 1, dash: [5])
      ),
      globalAnimation: .easeOut(duration: 1)
    )
    return LineChartData(dataSets: data, chartStyle: chartStyle)
  }
  
  func updateMaxAndMinCurrency() {
    let currentPoints = currentPoints.sorted { $0.currentPriceInCurrency > $1.currentPriceInCurrency }
    let maxCurrency = currentPoints.first?.currentPriceInCurrency ?? .zero
    let minCurrency = currentPoints.last?.currentPriceInCurrency ?? .zero
    self.minCurrency = minCurrency
    self.maxCurrency = maxCurrency
  }
  
  func getLineChartDataPoint(_ chartType: ChartSectionView.ChartType) -> [LineChartDataPoint] {
    switch chartType {
    case .hours:
      self.currentPoints = model.hours
      updateMaxAndMinCurrency()
      return model.hours.compactMap({ $0.mapTo() })
    case .days:
      self.currentPoints = model.days
      updateMaxAndMinCurrency()
      return model.days.compactMap({ $0.mapTo() })
    case .weeks:
      self.currentPoints = model.weeks
      updateMaxAndMinCurrency()
      return model.weeks.compactMap({ $0.mapTo() })
    case .months:
      self.currentPoints = model.months
      updateMaxAndMinCurrency()
      return model.months.compactMap({ $0.mapTo() })
    case .yearly:
      self.currentPoints = model.yearly
      updateMaxAndMinCurrency()
      return model.yearly.compactMap({ $0.mapTo() })
    case .allTime:
      self.currentPoints = model.allTime
      updateMaxAndMinCurrency()
      return model.allTime.compactMap({ $0.mapTo() })
    }
  }
  
  func updateIncomeTypeWith(percentage: Double?) {
    guard let percentage else {
      incomeType = .none
      return
    }
    
    if percentage < .zero {
      incomeType = .minus
    } else if percentage > .zero {
      incomeType = .plus
    } else {
      incomeType = .none
    }
  }
  
  func getColorForIncome() -> Color {
    switch incomeType {
    case .plus:
      return SKStyleAsset.constantLime.swiftUIColor
    case .minus:
      return SKStyleAsset.constantRuby.swiftUIColor
    case .none:
      return SKStyleAsset.ghost.swiftUIColor
    }
  }
  
  func formatTertiaryTitle() -> String {
    let selecteddate = selectedPoint?.date
    
    var result = SKUIKitStrings.State.price
    
    if let selecteddate {
      result = selecteddate
    }
    return result
  }
  
  func formatSecondaryCurrencyTitle() -> String {
    let currencySymbol = currentPoints.last?.currencySymbol ?? ""
    let currentIncomeAsPercentage = currentPoints.last?.incomeAsPercentage
    let selectedIncomeAsPercentage = selectedPoint?.incomeAsPercentage
    let currentPriceInCurrency = currentPoints.last?.currentPriceInCurrency
    let selectedPriceInCurrency = selectedPoint?.currentPriceInCurrency
    
    var result = ""
    
    if let currentIncomeAsPercentage, let currentPriceInCurrency {
      let percentageAmount = currentPriceInCurrency * (currentIncomeAsPercentage / 100)
      result = "\(String(format: "%.2f", abs(percentageAmount)).formattedWithSpaces()) \(currencySymbol)"
    }
    
    if let selectedIncomeAsPercentage, let selectedPriceInCurrency {
      let percentageAmount = selectedPriceInCurrency * (selectedIncomeAsPercentage / 100)
      result = "\(String(format: "%.2f", abs(percentageAmount)).formattedWithSpaces()) \(currencySymbol)"
    }
    return result
  }
  
  func formatSecondaryPercentageTitle() -> String {
    let currentIncomeAsPercentage = currentPoints.last?.incomeAsPercentage
    let selectedIncomeAsPercentage = selectedPoint?.incomeAsPercentage
    
    var result = ""
    
    if let currentIncomeAsPercentage {
      var sign = ""
      
      if currentIncomeAsPercentage < .zero {
        sign = "- "
      } else if currentIncomeAsPercentage > .zero {
        sign = "+ "
      }
      
      result = "\(sign)\(String(format: "%.1f", abs(currentIncomeAsPercentage)).formattedWithSpaces()) %"
    }
    
    if let selectedIncomeAsPercentage {
      var sign = ""
      
      if selectedIncomeAsPercentage < .zero {
        sign = "- "
      } else if selectedIncomeAsPercentage > .zero {
        sign = "+ "
      }
      
      result = "\(sign)\(String(format: "%.1f", abs(selectedIncomeAsPercentage)).formattedWithSpaces()) %"
    }
    
    return result
  }
  
  func formatPrimaryTitle() -> String {
    let currentPriceInCurrency = currentPoints.last?.currentPriceInCurrency
    let selectedPriceInCurrency = selectedPoint?.currentPriceInCurrency
    let currencySymbol = currentPoints.last?.currencySymbol
    
    var result = ""
    
    if let currentPriceInCurrency {
      result = String(format: "%.4f", currentPriceInCurrency).formattedWithSpaces()
    }
    
    if let selectedPriceInCurrency {
      result = String(format: "%.4f", selectedPriceInCurrency).formattedWithSpaces()
    }
    
    if let currencySymbol {
      result = result + " \(currencySymbol)"
    }
    return result
  }
}

// Используем тестовые данные
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      HStack {
        SKStyleAsset.onyx.swiftUIColor
      }
      
      ChartSectionView(ChartSectionView.mockModel())
    }
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}

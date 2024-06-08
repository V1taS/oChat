//
//  TouchOverlay.swift
//  LineChart
//
//  Created by Will Dale on 29/12/2020.
//

import SwiftUI

#if !os(tvOS)
/**
 Finds the nearest data point and displays the relevent information.
 */
internal struct TouchOverlay<T>: ViewModifier where T: CTChartData {
  
  @ObservedObject private var chartData: T
  let minDistance: CGFloat
  private let specifier: String
  private let formatter: NumberFormatter?
  private let unit: TouchUnit
  private var onChartDrag: ((T.DataPoint?) -> Void)?
  private var onEndedChartDrag: ((T.DataPoint?) -> Void)?
  
  internal init(
    chartData: T,
    specifier: String,
    formatter: NumberFormatter?,
    unit: TouchUnit,
    minDistance: CGFloat,
    onChartDrag: ((T.DataPoint?) -> Void)?,
    onEndedChartDrag: ((T.DataPoint?) -> Void)?
  ) {
    self.chartData = chartData
    self.minDistance = minDistance
    self.specifier = specifier
    self.formatter = formatter
    self.unit = unit
    self.onChartDrag = onChartDrag
    self.onEndedChartDrag = onEndedChartDrag
  }
  
  internal func body(content: Content) -> some View {
    Group {
      if chartData.isGreaterThanTwo() {
        GeometryReader { geo in
          ZStack {
            content
              .gesture(
                DragGesture(minimumDistance: minDistance, coordinateSpace: .local)
                  .onChanged { (value) in
                    chartData.setTouchInteraction(touchLocation: value.location,
                                                  chartSize: geo.frame(in: .local))
                    
                    if chartData.infoView.isTouchCurrent {
                      onChartDrag?(chartData.infoView.touchOverlayInfo.first)
                    }
                  }
                  .onEnded { _ in
                    if chartData.infoView.isTouchCurrent {
                      onEndedChartDrag?(chartData.infoView.touchOverlayInfo.first)
                    }
                    chartData.infoView.isTouchCurrent = false
                    chartData.infoView.touchOverlayInfo = []
                  }
              )
            if chartData.infoView.isTouchCurrent {
              chartData.getTouchInteraction(touchLocation: chartData.infoView.touchLocation,
                                            chartSize: geo.frame(in: .local))
            }
          }
        }
      } else { content }
    }
    .onAppear {
      self.chartData.infoView.touchSpecifier = specifier
      self.chartData.infoView.touchFormatter = formatter
      self.chartData.infoView.touchUnit = unit
    }
  }
}
#endif

extension View {
#if !os(tvOS)
  /**
   Adds touch interaction with the chart.
   
   Adds an overlay to detect touch and display the relivent information from the nearest data point.
   
   - Requires:
   If  ChartStyle --> infoBoxPlacement is set to .header
   then `.headerBox` is required.
   
   If  ChartStyle --> infoBoxPlacement is set to .infoBox
   then `.infoBox` is required.
   
   If  ChartStyle --> infoBoxPlacement is set to .floating
   then `.floatingInfoBox` is required.
   
   - Attention:
   Unavailable in tvOS
   
   - Parameters:
   - chartData: Chart data model.
   - specifier: Decimal precision for labels.
   - unit: Unit to put before or after the value.
   - minDistance: The distance that the touch event needs to travel to register.
   - Returns: A  new view containing the chart with a touch overlay.
   */
  public func touchOverlay<T: CTChartData>(
    chartData: T,
    specifier: String = "%.0f",
    formatter: NumberFormatter? = nil,
    unit: TouchUnit = .none,
    minDistance: CGFloat = 0,
    onChartDrag: ((T.DataPoint?) -> Void)? = nil,
    onEndedChartDrag: ((T.DataPoint?) -> Void)? = nil
  ) -> some View {
    self.modifier(TouchOverlay(chartData: chartData,
                               specifier: specifier,
                               formatter: formatter,
                               unit: unit,
                               minDistance: minDistance, 
                               onChartDrag: onChartDrag,
                               onEndedChartDrag: onEndedChartDrag))
  }
#elseif os(tvOS)
  /**
   Adds touch interaction with the chart.
   
   - Attention:
   Unavailable in tvOS
   */
  public func touchOverlay<T: CTChartData>(
    chartData: T,
    specifier: String = "%.0f",
    formatter: NumberFormatter? = nil,
    unit: TouchUnit = .none,
    minDistance: CGFloat = 0
  ) -> some View {
    self.modifier(EmptyModifier())
  }
#endif
}

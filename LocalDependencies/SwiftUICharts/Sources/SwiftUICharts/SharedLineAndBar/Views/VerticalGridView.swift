//
//  VerticalGridView.swift
//  
//
//  Created by Will Dale on 08/02/2021.
//

import SwiftUI

/**
 Sub view of the X axis grid view modifier.
 */
internal struct VerticalGridView<T>: View where T: CTLineBarChartDataProtocol {
    
    @ObservedObject private var chartData: T
    
    internal init(chartData: T) {
        self.chartData = chartData
    }
    
    @State private var startAnimation: Bool = false
    
    var body: some View {
        VerticalGridShape()
            .trim(to: animationValue)
            .stroke(chartData.chartStyle.xAxisGridStyle.lineColour,
                    style: StrokeStyle(lineWidth: chartData.chartStyle.xAxisGridStyle.lineWidth,
                                       dash: chartData.chartStyle.xAxisGridStyle.dash,
                                       dashPhase: chartData.chartStyle.xAxisGridStyle.dashPhase))
            .frame(width: chartData.chartStyle.xAxisGridStyle.lineWidth)
            .if(chartData.chartStyle.globalAnimation != nil, transform: { view in
              view
                .animateOnAppear(disabled: chartData.disableAnimation, using: chartData.chartStyle.globalAnimation ?? .default) {
                    self.startAnimation = true
                }
            })
            .if(chartData.chartStyle.globalAnimation != nil, transform: { view in
              view
                .animateOnDisappear(disabled: chartData.disableAnimation, using: chartData.chartStyle.globalAnimation ?? .default) {
                    self.startAnimation = false
                }
            })
    }
    
    var animationValue: CGFloat {
        if chartData.disableAnimation {
            return 1
        } else {
            return startAnimation ? 1 : 0
        }
    }
}

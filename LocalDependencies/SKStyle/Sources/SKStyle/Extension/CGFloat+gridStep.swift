//
//  CGFloat+gridStep.swift
//  SKStyle
//
//  Created by Vladimir Stepanchikov on 7/21/24.
//

import UIKit

extension CGFloat {
  public static let gridStep = CGFloat(4)
  public static func gridSteps(_ steps: Int) -> CGFloat {
    gridStep * CGFloat(steps)
  }
}

//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

import SKStyle
import SKUIKit
import SwiftUI

struct ___FILEBASENAMEASIDENTIFIER___: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: ___VARIABLE_productName___Presenter
  
  // MARK: - Body
  
  var body: some View {
    EmptyView()
  }
}

// MARK: - Private

private extension ___FILEBASENAMEASIDENTIFIER___ {}

// MARK: - Preview

struct ___FILEBASENAMEASIDENTIFIER____Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      ___VARIABLE_productName___Assembly().createModule().viewController
    }
  }
}

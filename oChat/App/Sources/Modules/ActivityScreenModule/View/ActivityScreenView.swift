//
//  ActivityScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import Lottie

struct ActivityScreenView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: ActivityScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .zero) {
          createContent()
        }
        .padding(.horizontal, .s4)
        .padding(.bottom, .s4)
      }
      .refreshable {
        presenter.refreshable()
      }
    }
  }
}

// MARK: - Private

private extension ActivityScreenView {
  func createContent() -> AnyView {
    if presenter.getListActivity().isEmpty {
      return AnyView(createEmptyState())
    } else {
      return AnyView(
        ForEach(presenter.getListActivity(), id: \.date) { model in
          HStack {
            TitleAndSubtitleView(
              title: .init(text: model.date),
              alignment: .leading,
              style: .standart
            )
            .padding(.top, .s4)
            Spacer()
          }
          
          ForEach(model.listActivity, id: \.id) { widgetsModel in
            WidgetCryptoView(widgetsModel)
              .padding(.top, .s3)
          }
        }
      )
    }
  }
  
  func createEmptyState() -> some View {
    LottieView(animation: .named(OChatAsset.emptyStateLottie.name))
      .resizable()
      .looping()
      .aspectRatio(contentMode: .fit)
  }
}

// MARK: - Preview

struct ActivityScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      ActivityScreenAssembly().createModule().viewController
    }
  }
}

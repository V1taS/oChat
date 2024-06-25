//
//  MessengerListScreenModuleView.swift
//  SafeKeeper
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions
import Lottie
import SKFoundation

struct MessengerListScreenModuleView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MessengerListScreenModulePresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      if presenter.stateWidgetModels.isEmpty {
        createEmptyState()
      } else {
        createContent()
      }
    }
  }
}

// MARK: - Private

private extension MessengerListScreenModuleView {
  func notificationsView() -> AnyView {
    if !presenter.stateIsNotificationsEnabled {
      return AnyView(
        ViewThatFits {
          TipsView(
            .init(
              text: MessengerSDKStrings.MessengerListScreenModuleLocalization
                .stateBannerPushNotificationTitle,
              style: .attention,
              isSelectableTips: true,
              actionTips: {
                presenter.requestNotification()
              },
              isCloseButton: false,
              closeButtonAction: {}
            )
          )
        }
          .padding(.vertical, .s4)
      )
      
    }
    return AnyView(EmptyView())
  }
  
  func createContent() -> some View {
    List {
      notificationsView()
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: .zero, leading: .s4, bottom: .zero, trailing: .s4))
        .listRowSeparator(.hidden)
      
      ForEach(presenter.stateWidgetModels.indices, id: \.self) { index in
        VStack(spacing: .zero) {
          WidgetCryptoView(presenter.stateWidgetModels[index])
            .clipShape(RoundedRectangle(cornerRadius: .s3))
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: .zero, leading: .s4, bottom: .zero, trailing: .s4))
        .listRowSeparator(.hidden)
      }
      .onDelete { indexSet in
        guard let index = indexSet.first else {
          return
        }
        presenter.removeContact(index: index)
      }
    }
    .background(Color.clear)
    .listStyle(PlainListStyle())
    .listRowSpacing(.s4)
    .padding(.vertical, .s4)
  }
  
  func createEmptyState() -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        notificationsView()
          .padding(.horizontal, .s4)
        
        Spacer()
        
        LottieView(
          animation: .asset(
            MessengerSDKAsset.emptyStateLottie.name,
            bundle: MessengerSDKResources.bundle
          )
        )
        .resizable()
        .looping()
        .aspectRatio(contentMode: .fit)
        Spacer()
      }
    }
  }
}

// MARK: - Preview

struct MessengerListScreenModuleView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerListScreenModuleAssembly().createModule(
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}

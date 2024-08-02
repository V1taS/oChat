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
              text: OChatStrings.MessengerListScreenModuleLocalization.State
                .Banner.PushNotification.title,
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
      
      ForEach(Array(presenter.stateWidgetModels.enumerated()), id: \.element.id) { index, model in
        VStack(spacing: .zero) {
          WidgetCryptoView(model)
            .clipShape(RoundedRectangle(cornerRadius: .s3))
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: .zero, leading: .s4, bottom: .zero, trailing: .s4))
        .listRowSeparator(.hidden)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
          Button {
            presenter.clearContact(index: index)
          } label: {
            Text(OChatStrings.MessengerListScreenModuleLocalization
              .SwipeActions.Clear.title)
          }
          .tint(.orange)
          
          Button {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
              Task {
                await presenter.moduleOutput?.suggestToRemoveContact(index: index)
              }
            }
          } label: {
            Text(OChatStrings.MessengerListScreenModuleLocalization
              .SwipeActions.Delete.title)
          }
          .tint(SKStyleAsset.constantRuby.swiftUIColor)
        }
      }
    }
    .background(Color.clear)
    .listStyle(PlainListStyle())
    .listRowSpacing(.s4)
    .listRowSeparator(.hidden)
  }
  
  func createEmptyState() -> some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack {
        notificationsView()
          .padding(.horizontal, .s4)
        
        Spacer()
        
        LottieView(
          animation: .asset(
            OChatAsset.emptyStateLottie.name,
            bundle: .main
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

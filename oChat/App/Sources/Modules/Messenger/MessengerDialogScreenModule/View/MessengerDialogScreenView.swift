//
//  MessengerDialogScreenView.swift
//  oChat
//
//  Created by Vitalii Sosin on 21.04.2024.
//

import SKStyle
import SKUIKit
import SwiftUI
import SKAbstractions

struct MessengerDialogScreenView: View {
  
  // MARK: - Internal properties
  @StateObject
  var presenter: MessengerDialogScreenPresenter
  
  // MARK: - Body
  
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(spacing: .zero) {
          ForEach(presenter.stateMessenges, id: \.id) { messengeModel in
            if messengeModel.messengeType == .own {
              HStack(spacing: .zero) {
                Spacer()
                Text(messengeModel.message)
                  .font(.fancy.text.regular)
                  .foregroundColor(SKStyleAsset.constantGhost.swiftUIColor)
                  .multilineTextAlignment(.leading)
                  .lineLimit(.max)
                  .truncationMode(.middle)
                  .roundedEdge(
                    backgroundColor: SKStyleAsset.azure.swiftUIColor
                  )
                  .allowsHitTesting(false)
              }
              .padding(.top, .s4)
            }
            
            if messengeModel.messengeType == .received {
              HStack(spacing: .zero) {
                Text(messengeModel.message)
                  .font(.fancy.text.regular)
                  .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
                  .multilineTextAlignment(.leading)
                  .lineLimit(.max)
                  .truncationMode(.middle)
                  .roundedEdge(
                    backgroundColor: SKStyleAsset.navy.swiftUIColor
                  )
                  .allowsHitTesting(false)
                
                Spacer()
              }
              .padding(.top, .s4)
            }
          }
        }
      }
      .refreshable {
        presenter.refreshable()
      }
      
      createSendMessageView()
    }
    .padding(.horizontal, .s4)
    .padding(.bottom, .s4)
  }
}

// MARK: - Private

private extension MessengerDialogScreenView {
  func createSendMessageView() -> some View {
    MultilineInputView(
      InputViewModel(
        text: presenter.stateInputMessengeText,
        placeholder: presenter.getPlaceholder(),
        bottomHelper: presenter.stateBottomHelper,
        isError: presenter.stateIsErrorInputText,
        isEnabled: presenter.stateIsEnabledInputText,
        maxLength: presenter.stateMaxLengthInputText,
        rightButtonType: .send(isEnabled: presenter.stateIsEnabledRightButton),
        rightButtonAction: {
          presenter.sendMessage()
        },
        onChange: { newMessage in
          presenter.stateInputMessengeText = newMessage
        }
      )
    )
  }
}

// MARK: - Preview

struct MessengerDialogScreenView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MessengerDialogScreenAssembly().createModule(
        dialogModel: .init(
          senderName: "",
          recipientName: "",
          messenges: [],
          costOfSendingMessage: "",
          isHiddenDialog: false
        ),
        services: ApplicationServicesStub()
      ).viewController
    }
  }
}

//
//  MessageView.swift
//  oChat
//
//  Created by Vitalii Sosin on 24.06.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SwiftUI
import SKStyle
import SKUIKit

public struct MessageView: View {
  
  // MARK: - Private properties
  
  private let model: MessageView.Model
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - model: Модель данных
  public init(_ model: MessageView.Model) {
    self.model = model
  }
  
  // MARK: - Body
  
  public var body: some View {
    VStack {
      messageView()
    }
  }
}

// MARK: - Private

private extension MessageView {
  func messageView() -> some View {
    VStack(spacing: .zero) {
      HStack(spacing: .zero) {
        if model.messageType == .outgoing {
          Spacer()
        }
        
        Text(model.text)
          .font(.fancy.text.regular)
          .foregroundColor(model.messageType.foregraundColor)
          .multilineTextAlignment(.leading)
          .lineLimit(.max)
          .truncationMode(.middle)
          .roundedEdge(
            backgroundColor: model.messageType.backgroundColor,
            boarderColor: .clear,
            paddingHorizontal: .s4,
            paddingVertical: .s2,
            paddingTrailing: model.messageType == . incoming ? .zero : .s4,
            cornerRadius: .s4
          )
          .overlay {
            VStack {
              Spacer()
              HStack {
                if model.messageType == .outgoing {
                  Spacer()
                }
                
                if model.hasTail {
                  Image(
                    uiImage: UIImage(
                      named: model.messageType == .incoming ? SKUIKitAsset.incomingTail.name : SKUIKitAsset.outgoingTail.name,
                      in: SKUIKitResources.bundle,
                      with: nil
                    ) ?? UIImage()
                  )
                  .resizable()
                  .renderingMode(.template)
                  .foregroundColor(
                    model.messageType == .incoming ?
                    SKStyleAsset.constantNavy.swiftUIColor :
                      SKStyleAsset.constantAzure.swiftUIColor
                  )
                  .aspectRatio(contentMode: .fit)
                  .frame(height: 12)
                  .offset(
                    x: model.messageType == .incoming ? 3 : -3,
                    y: model.messageType == .incoming ? .s1 : .s1
                  )
                }
                
                if model.messageType == .incoming {
                  Spacer()
                }
              }
            }
          }
          .overlay(content: {
            if model.messageType == .outgoing {
              VStack(spacing: .zero) {
                Spacer()
                HStack {
                  Spacer()
                  model.messageStatus.statusView
                    .padding(.trailing, .s2)
                    .padding(.bottom, .s2)
                }
              }
            }
          })
          .frame(
            maxWidth: 250,
            alignment: model.messageType == .incoming ? .leading : .trailing
          )
          .contextMenu {
            Text(SKUIKitStrings.State.messageContextMenuTitle)
            
            Button(action: {
              model.copyAction?()
            }) {
              Label(SKUIKitStrings.State.messageCopyButtonTitle, systemImage: "doc.on.doc")
            }
            
            if model.messageType == .outgoing && model.messageStatus == .failed {
              Button(action: {
                model.retrySendAction?()
              }) {
                Label(SKUIKitStrings.State.messageRetryButtonTitle, systemImage: "arrow.triangle.2.circlepath")
              }
            }
            
            Button(role: .destructive, action: {
              model.deleteAction?()
            }) {
              Label(SKUIKitStrings.State.messageDeleteButtonTitle, systemImage: "trash")
            }
          }
        
        if model.messageType == .incoming {
          Spacer()
        }
      }
    }
  }
}

// MARK: - Constants

private enum Constants {}

// MARK: - Preview

struct MessageView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MessageView(
        .init(
          id: "1",
          text: "Какой хорошийe",
          messageType: .outgoing,
          messageStatus: .sending,
          hasTail: true
        )
      )
      MessageView(
        .init(
          id: "1",
          text: "Какой хорошийe ewrghbejkqgnkqejrb qebgkjqebngjkwebg",
          messageType: .outgoing,
          messageStatus: .sent,
          hasTail: true
        )
      )
      MessageView(
        .init(
          id: "1",
          text: "Какой хорошийe",
          messageType: .outgoing,
          messageStatus: .failed,
          hasTail: true
        )
      )
      MessageView(
        .init(
          id: "1",
          text: "Какой хоheuifheuifheiufuirfeiufeirfeuirfierfь!",
          messageType: .incoming,
          messageStatus: .sending,
          hasTail: false
        )
      )
    }
    .padding(.horizontal)
    .background(SKStyleAsset.onyx.swiftUIColor)
  }
}

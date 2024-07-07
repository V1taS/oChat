//
//  WidgetCryptoView.swift
//
//
//  Created by Vitalii Sosin on 03.12.2023.
//

import SwiftUI
import SKStyle

@available(iOS 16.0, *)
public struct WidgetCryptoView: View {
  
  // MARK: - Private properties
  
  private var model: WidgetCryptoView.Model
  
  // MARK: - Initialization
  
  /// Инициализатор для создания виджета с криптовалютой
  /// - Parameters:
  ///   - model: Модель данных
  public init(_ model: WidgetCryptoView.Model) {
    self.model = model
  }
  
  // MARK: - Body
  
  public var body: some View {
    createWidgetCrypto(model: model)
  }
}

// MARK: - Private

@available(iOS 16.0, *)
private extension WidgetCryptoView {
  func createWidgetCrypto(model: WidgetCryptoView.Model) -> AnyView {
    AnyView(
      ZStack {
        TapGestureView(
          style: .flash,
          isSelectable: model.isSelectable,
          touchesEnded: { model.action?() }
        ) {
          model.backgroundColor ?? SKStyleAsset.navy.swiftUIColor
        }
        
        VStack(spacing: .zero) {
          HStack(alignment: .center, spacing: .s4) {
            createLeftSideImage(model: model)
            createLeftSideItem(model: model)
            
            VStack(spacing: .s1) {
              createFirstLineContent(model: model)
              createSecondLineContent(model: model)
            }
            .layoutPriority(2)
            
            createRightSideImage(model: model)
            createRightSideItem(model: model)
          }
          
          if let additionContent = model.additionCenterContent {
            additionContent
          }
          
          if let additionTextModel = model.additionCenterTextModel {
            Text(additionTextModel.textIsSecure ? Constants.secureText : additionTextModel.text)
              .font(.fancy.text.regular)
              .foregroundColor(additionTextModel.textStyle.color)
              .multilineTextAlignment(.center)
              .lineLimit(.max)
              .roundedEdge(backgroundColor: additionTextModel.textStyle.color.opacity(0.07))
              .padding(.top, .s4)
              .allowsHitTesting(false)
          }
        }
        .padding(.horizontal, .s4)
        .padding(.vertical, .s3)
      }
    )
  }
  
  func createLeftSideImage(model: WidgetCryptoView.Model) -> AnyView {
    AnyView(
      Group {
        if let imageModel = model.leftSide?.imageModel {
          let shape: some Shape = imageModel.roundedStyle == .circle ?
          AnyShape(Circle()) :
          AnyShape(RoundedRectangle(cornerRadius: .s3))
          
          if let image = imageModel.image {
            image
              .resizable()
              .frame(width: imageModel.size.width, height: imageModel.size.height)
              .aspectRatio(contentMode: .fit)
              .if(imageModel.imageColor?.foregroundColor != nil, transform: { view in
                view.foregroundColor(imageModel.imageColor ?? SKStyleAsset.constantAzure.swiftUIColor)
              })
              .if(imageModel.backgroundColor != nil, transform: { view in
                view.background(imageModel.backgroundColor ?? .clear)
              })
              .clipShape(shape)
              .allowsHitTesting(false)
          }
          
          if let imageURL = imageModel.imageURL {
            AsyncNetworkImageView(
              .init(
                imageUrl: imageURL,
                size: .init(width: imageModel.size.width, height: imageModel.size.height),
                cornerRadiusType: imageModel.roundedStyle == .circle ? .circle : .squircle
              )
            )
          }
        }
      }
    )
  }
  
  func createRightSideImage(model: WidgetCryptoView.Model) -> AnyView {
    AnyView(
      Group {
        if let imageModel = model.rightSide?.imageModel {
          let shape: some Shape = imageModel.roundedStyle == .circle ?
          AnyShape(Circle()) :
          AnyShape(RoundedRectangle(cornerRadius: .s3))
          
          if let image = imageModel.image {
            image
              .resizable()
              .frame(width: imageModel.size.width, height: imageModel.size.height)
              .aspectRatio(contentMode: .fit)
              .if(imageModel.imageColor?.foregroundColor != nil, transform: { view in
                view.foregroundColor(imageModel.imageColor ?? SKStyleAsset.constantAzure.swiftUIColor)
              })
              .if(imageModel.backgroundColor != nil, transform: { view in
                view.background(imageModel.backgroundColor ?? .clear)
              })
              .clipShape(shape)
              .allowsHitTesting(false)
          }
          
          if let imageURL = imageModel.imageURL {
            AsyncNetworkImageView(
              .init(
                imageUrl: imageURL,
                size: .init(width: imageModel.size.width, height: imageModel.size.height),
                cornerRadiusType: imageModel.roundedStyle == .circle ? .circle : .squircle
              )
            )
          }
        }
      }
    )
  }
  
  func createRightSideItem(model: WidgetCryptoView.Model) -> AnyView {
    if let itemModel = model.rightSide?.itemModel {
      return createItem(itemModel: itemModel)
    }
    return AnyView(EmptyView())
  }
  
  func createLeftSideItem(model: WidgetCryptoView.Model) -> AnyView {
    if let itemModel = model.leftSide?.itemModel {
      return createItem(itemModel: itemModel)
    }
    return AnyView(EmptyView())
  }
  
  func createFirstLineContent(model: WidgetCryptoView.Model) -> AnyView {
    AnyView(
      HStack(alignment: .center, spacing: .s2) {
        if let titleModel = model.leftSide?.titleModel {
          Text(titleModel.textIsSecure ? Constants.secureText : titleModel.text)
            .font(.fancy.text.regularMedium)
            .foregroundColor(titleModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleModel.lineLimit)
            .truncationMode(.middle)
            .allowsHitTesting(false)
        }
        
        if let titleAdditionModel = model.leftSide?.titleAdditionModel {
          Text(titleAdditionModel.text)
            .font(.fancy.text.regular)
            .foregroundColor(titleAdditionModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleAdditionModel.lineLimit)
            .truncationMode(.middle)
            .allowsHitTesting(false)
        }
        
        if let titleAdditionRoundedModel = model.leftSide?.titleAdditionRoundedModel {
          Text(titleAdditionRoundedModel.text)
            .font(.fancy.text.small)
            .foregroundColor(titleAdditionRoundedModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleAdditionRoundedModel.lineLimit)
            .truncationMode(.middle)
            .roundedEdge(backgroundColor: titleAdditionRoundedModel.textStyle.color.opacity(0.07))
            .allowsHitTesting(false)
        }
        
        Spacer()
        
        if let titleAdditionRoundedModel = model.rightSide?.titleAdditionRoundedModel {
          Text(titleAdditionRoundedModel.text)
            .font(.fancy.text.small)
            .foregroundColor(titleAdditionRoundedModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleAdditionRoundedModel.lineLimit)
            .truncationMode(.middle)
            .roundedEdge(backgroundColor: titleAdditionRoundedModel.textStyle.color.opacity(0.07))
            .allowsHitTesting(false)
        }
        
        if let titleAdditionModel = model.rightSide?.titleAdditionModel {
          Text(titleAdditionModel.text)
            .font(.fancy.text.regular)
            .foregroundColor(titleAdditionModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleAdditionModel.lineLimit)
            .truncationMode(.middle)
            .allowsHitTesting(false)
        }
        
        if let titleModel = model.rightSide?.titleModel {
          Text(titleModel.textIsSecure ? Constants.secureText : titleModel.text)
            .font(.fancy.text.regularMedium)
            .foregroundColor(titleModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleModel.lineLimit)
            .truncationMode(.middle)
            .allowsHitTesting(false)
        }
      }
    )
  }
  
  func createSecondLineContent(model: WidgetCryptoView.Model) -> AnyView {
    AnyView(
      HStack(alignment: .center, spacing: .s2) {
        if let titleModel = model.leftSide?.descriptionModel {
          Text(titleModel.textIsSecure ? Constants.secureText : titleModel.text)
            .font(.fancy.text.regular)
            .foregroundColor(titleModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleModel.lineLimit)
            .truncationMode(.middle)
            .allowsHitTesting(false)
        }
        
        if let titleAdditionModel = model.leftSide?.descriptionAdditionModel {
          Text(titleAdditionModel.text)
            .font(.fancy.text.regular)
            .foregroundColor(titleAdditionModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleAdditionModel.lineLimit)
            .truncationMode(.middle)
            .allowsHitTesting(false)
        }
        
        if let titleAdditionRoundedModel = model.leftSide?.descriptionAdditionRoundedModel {
          Text(titleAdditionRoundedModel.text)
            .font(.fancy.text.regular)
            .foregroundColor(titleAdditionRoundedModel.textStyle.color)
            .multilineTextAlignment(.leading)
            .lineLimit(titleAdditionRoundedModel.lineLimit)
            .truncationMode(.middle)
            .roundedEdge(backgroundColor: titleAdditionRoundedModel.textStyle.color.opacity(0.07))
            .allowsHitTesting(false)
        }
        
        Spacer()
        
        if let titleAdditionRoundedModel = model.rightSide?.descriptionAdditionRoundedModel {
          Text(titleAdditionRoundedModel.text)
            .font(.fancy.text.regular)
            .foregroundColor(titleAdditionRoundedModel.textStyle.color)
            .multilineTextAlignment(.trailing)
            .lineLimit(titleAdditionRoundedModel.lineLimit)
            .truncationMode(.middle)
            .roundedEdge(backgroundColor: titleAdditionRoundedModel.textStyle.color.opacity(0.07))
            .allowsHitTesting(false)
        }
        
        if let titleAdditionModel = model.rightSide?.descriptionAdditionModel {
          Text(titleAdditionModel.text)
            .font(.fancy.text.regular)
            .foregroundColor(titleAdditionModel.textStyle.color)
            .multilineTextAlignment(.trailing)
            .lineLimit(titleAdditionModel.lineLimit)
            .truncationMode(.middle)
            .allowsHitTesting(false)
        }
        
        if let titleModel = model.rightSide?.descriptionModel {
          Text(titleModel.textIsSecure ? Constants.secureText : titleModel.text)
            .font(.fancy.text.regular)
            .foregroundColor(titleModel.textStyle.color)
            .multilineTextAlignment(.trailing)
            .lineLimit(titleModel.lineLimit)
            .truncationMode(.middle)
            .allowsHitTesting(false)
        }
      }
    )
  }
  
  func createItem(itemModel: WidgetCryptoView.ItemModel) -> AnyView {
    switch itemModel {
    case let .custom(item, _, isHitTesting):
      return AnyView(
        item
          .frame(width: itemModel.size.width, height: itemModel.size.height)
          .allowsHitTesting(isHitTesting)
      )
    case let .switcher(initNewValue, isEnabled, action):
      return AnyView(
        SwitcherView(isOn: initNewValue, isEnabled: isEnabled, action: action)
          .allowsHitTesting(true)
      )
    case let .radioButtons(initNewValue, isChangeValue, action):
      return AnyView(
        CheckmarkView(
          text: nil,
          toggleValue: initNewValue,
          isChangeValue: isChangeValue,
          style: .circle,
          action: action
        )
        .allowsHitTesting(true)
        .layoutPriority(3)
      )
    case let .checkMarkButton(initNewValue, isChangeValue, action):
      return AnyView(
        CheckmarkView(
          text: nil,
          toggleValue: initNewValue,
          isChangeValue: isChangeValue,
          action: action
        )
        .allowsHitTesting(true)
      )
    case let .infoButton(action):
      return AnyView(
        Button(action: {
          action?()
        }, label: {
          Image(systemName: "info.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: itemModel.size.width, height: itemModel.size.height)
            .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
        })
      )
    }
  }
}

// MARK: - Constants

private enum Constants {
  static let secureText = "* * *"
  static let mockImageData = Image(systemName: "link.circle")
}

// MARK: - Preview

@available(iOS 16.0, *)
struct WidgetCryptoView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      WidgetCryptoView(
        .init(
          leftSide: .init(
            titleModel: .init(
              text: "ETH",
              textStyle: .standart
            )
          ),
          rightSide: .init(
            itemModel: .radioButtons(
              initNewValue: true,
              action: {_ in}
            )
          ),
          additionCenterTextModel: nil,
          additionCenterContent: nil,
          isSelectable: false,
          backgroundColor: nil,
          action: {}
        )
      )
      Spacer()
    }
    .padding(.top, .s26)
    .padding(.horizontal)
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}

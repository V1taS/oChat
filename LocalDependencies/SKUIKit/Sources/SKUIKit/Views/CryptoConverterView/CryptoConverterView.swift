//
//  CryptoConverterView.swift
//  SKUIKit
//
//  Created by Vitalii Sosin on 18.03.2024.
//

import SwiftUI
import SKStyle
import Combine

@available(iOS 16.0, *)
public struct CryptoConverterView: View {
  
  // MARK: - Private properties
  
  @Binding private var text: String
  @FocusState private var isTextFieldFocused: Bool
  private let model: CryptoConverterView.Model
  private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - model: Модель данных
  public init(_ model: CryptoConverterView.Model) {
    self.model = model
    self._text = model.text
  }
  
  // MARK: - Body
  
  public var body: some View {
    createWidgetCrypto(model: model)
      .background(SKStyleAsset.navy.swiftUIColor)
      .clipShape(RoundedRectangle(cornerRadius: .s5))
      .onChange(of: text) { newValue in
        model.onTextChange?(newValue)
      }
      .onChange(of: isTextFieldFocused) { newValue in
        model.onTextFieldFocusedChange?(newValue, text)
      }
  }
}

// MARK: - Private

@available(iOS 16.0, *)
private extension CryptoConverterView {
  func createWidgetCrypto(model: CryptoConverterView.Model) -> AnyView {
    AnyView(
      VStack(spacing: .s2) {
        createFirstLineContent(model: model)
        createSecondLineContent(model: model)
        createThirdLineContent(model: model)
      }
        .padding(.s4)
    )
  }
  
  func createFirstLineContent(model: CryptoConverterView.Model) -> AnyView {
    AnyView(
      HStack(alignment: .center, spacing: .s2) {
        Text(model.leftSide.title)
          .font(.fancy.text.title)
          .fontWeight(.bold)
          .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
          .multilineTextAlignment(.leading)
          .lineLimit(1)
          .truncationMode(.middle)
          .allowsHitTesting(false)
        
        Spacer()
        
        if let totalAmountModel = model.rightSide?.totalAmount {
          Button {
            totalAmountModel.applyMaximumAmount?()
            impactFeedback.impactOccurred()
          } label: {
            Text("\(totalAmountModel.totalCryptoTitle) \(totalAmountModel.totalCrypto)")
              .font(.fancy.text.regularMedium)
              .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
              .multilineTextAlignment(.leading)
              .lineLimit(1)
              .truncationMode(.middle)
              .allowsHitTesting(false)
          }
        }
      }
    )
  }
  
  func createSecondLineContent(model: CryptoConverterView.Model) -> AnyView {
    AnyView(
      HStack(alignment: .center, spacing: .s2) {
        if let shortFormCryptoName = model.leftSide.shortFormCryptoName {
          TapGestureView(
            style: .flash,
            isSelectable: model.leftSide.isSelectable,
            touchesEnded: {
              model.leftSide.action?()
            }) {
              HStack(alignment: .center, spacing: .s2) {
                AsyncNetworkImageView(
                  .init(
                    imageUrl: model.leftSide.imageCrypto,
                    size: .init(width: CGFloat.s10, height: .s10),
                    cornerRadiusType: .circle
                  )
                )
                .allowsHitTesting(true)

                Text(shortFormCryptoName)
                  .font(.fancy.text.title)
                  .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
                  .multilineTextAlignment(.leading)
                  .lineLimit(1)
                  .truncationMode(.middle)
                  .allowsHitTesting(true)
                
                if model.leftSide.isSelectable {
                  Image(systemName: "chevron.compact.down")
                    .resizable()
                    .frame(width: .s3, height: .s2)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
                    .background(.clear)
                    .allowsHitTesting(true)
                }
              }
            }
          
          Spacer()
        }
        
        HStack(alignment: .center, spacing: .s1) {
          createTextField(model: model)
          
          if let currency = model.rightSide?.fieldWithAmount.currency {
            Text("\(currency)")
              .font(.fancy.text.title)
              .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
              .lineLimit(1)
              .truncationMode(.middle)
              .allowsHitTesting(false)
          }
        }
      }
    )
  }
  
  func createThirdLineContent(model: CryptoConverterView.Model) -> AnyView {
    AnyView(
      HStack(alignment: .center, spacing: .s2) {
        if let longFormCryptoName = model.leftSide.longFormCryptoName {
          Text(longFormCryptoName)
            .font(.fancy.text.regular)
            .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
            .multilineTextAlignment(.leading)
            .lineLimit(1)
            .truncationMode(.middle)
            .allowsHitTesting(false)
          
          Spacer()
        }
        
        if let currencySwitcher = model.rightSide?.currencySwitcher {
          Button {
            currencySwitcher.switchCurrencyAction?()
            impactFeedback.impactOccurred()
          } label: {
            HStack(alignment: .center, spacing: .s2) {
              Text("\(Constants.approxSign) \(currencySwitcher.amountInCurrency)")
                .font(.fancy.text.regular)
                .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .truncationMode(.middle)
                .allowsHitTesting(false)
              
              Image(systemName: "arrow.up.arrow.down")
                .resizable()
                .frame(width: .s4, height: .s4)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
                .allowsHitTesting(false)
            }
          }
          .accentColor(SKStyleAsset.constantAzure.swiftUIColor)
        }
      }
    )
  }
  
  func createPlaceholderView() -> Text {
    return Text(model.placeholder)
      .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor.opacity(0.4))
  }
  
  func createTextField(model: CryptoConverterView.Model) -> AnyView {
    let isCryptocurrency = model.fieldType == .cryptocurrency
    
    return AnyView(
      TextField("", text: $text, prompt: createPlaceholderView(), axis: .vertical)
        .if(
          isCryptocurrency,
          transform: { view in
            view
              .multilineTextAlignment(.trailing)
              .keyboardType(.decimalPad)
              .font(.fancy.text.title)
          },
          else: { view in
            view
              .font(.fancy.text.regular)
              .keyboardType(.default)
          }
        )
        .autocorrectionDisabled(true)
        .lineLimit(.max)
        .focused($isTextFieldFocused)
        .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
        .truncationMode(.tail)
        .accentColor(SKStyleAsset.constantAzure.swiftUIColor)
        .onChange(of: text) { newValue in
          guard isCryptocurrency else {
            return
          }
          let filtered = String(newValue.map { $0 == "," ? "." : $0 }
            .filter { "0123456789.".contains($0) })
          if filtered != newValue {
            text = filtered
          }
        }
    )
  }
}

// MARK: - Constants

private enum Constants {
  static let approxSign = "\u{2248}"
}

// MARK: - Preview

@available(iOS 16.0, *)
struct CryptoConverterView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      Spacer()
      CryptoConverterView(.init(
        text: .constant(""),
        fieldType: .cryptocurrency,
        placeholder: "0",
        leftSide: .init(
          title: "Отправить",
          shortFormCryptoName: "ETH",
          longFormCryptoName: "Ethereum",
          imageCrypto: URL(string: ""),
          action: {}
        ),
        rightSide: .init(
          totalAmount: .init(
            totalCryptoTitle: "max:",
            totalCrypto: "100",
            applyMaximumAmount: {}
          ),
          fieldWithAmount: .init(
            currency: "$"
          ),
          currencySwitcher: .init(
            amountInCurrency: "554,9",
            switchCurrencyAction: {}
          )
        ),
        onTextChange: { newValue in }
      ))
      
      CryptoConverterView(.init(
        text: .constant(""),
        fieldType: .standart,
        placeholder: "Адрес или домен",
        leftSide: .init(title: "Кому"),
        rightSide: nil,
        onTextChange: { newValue in }
      ))
      
      CryptoConverterView(.init(
        text: .constant(""), 
        fieldType: .standart,
        placeholder: "Можно что-то написать",
        leftSide: .init(title: "Комментарий"),
        rightSide: nil,
        onTextChange: { newValue in }
      ))
      Spacer()
    }
    .padding(.top, .s26)
    .padding(.horizontal)
    .background(SKStyleAsset.onyx.swiftUIColor)
    .ignoresSafeArea(.all)
  }
}

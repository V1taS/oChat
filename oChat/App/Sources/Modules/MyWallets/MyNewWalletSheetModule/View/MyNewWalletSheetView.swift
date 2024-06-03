//
//  MyNewWalletSheetView.swift
//  oChat
//
//  Created by Vitalii Sosin on 08.05.2024.
//

import SKStyle
import SKUIKit
import SwiftUI

struct MyNewWalletSheetView: View {
  
  // MARK: - Internal properties
  
  @StateObject
  var presenter: MyNewWalletSheetPresenter
  
  // MARK: - Body
  
  var body: some View {
    CustomSheetView {
      VStack(spacing: .s4) {
        HStack {
          Text(presenter.getNewWalletHeaderTitle())
            .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
            .font(.fancy.text.regular)
          Spacer()
        }
        createSeedPhrase12View()
        createSeedPhrase24View()
        createImageHighTechView()
        
        HStack {
          Text(presenter.getImportWalletHeaderTitle())
            .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
            .font(.fancy.text.regular)
          Spacer()
        }
        createImportSeedPhraseWalletView()
        createImportImageHighTechWalletView()
        
        // TODO: - Добавлю позже этот функционал
        //        HStack {
        //          Text("Отслеживать")
        //            .foregroundColor(SKStyleAsset.constantSlate.swiftUIColor)
        //            .font(.fancy.text.regular)
        //          Spacer()
        //        }
        //        createTrackWalletView()
      }
    }
  }
}

// MARK: - Private

private extension MyNewWalletSheetView {
  func createSeedPhrase12View() -> some View {
    let model = presenter.getSeedPhrase12Model()
    return WidgetCryptoView(
      .init(
        leftSide: .init(
          imageModel: .custom(
            image: Image(systemName: model.walletSystemImageName),
            color: SKStyleAsset.azure.swiftUIColor
          ),
          titleModel: .init(text: model.walletTitle),
          descriptionModel: .init(
            text: model.walletDescription,
            textStyle: .netural
          )
        ),
        isSelectable: true,
        backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1),
        action: {
          presenter.moduleOutput?.openCreateStandartSeedPhrase12WalletScreen()
        }
      )
    )
  }
  
  func createSeedPhrase24View() -> some View {
    let model = presenter.getSeedPhrase24Model()
    return WidgetCryptoView(
      .init(
        leftSide: .init(
          imageModel: .custom(
            image: Image(systemName: model.walletSystemImageName),
            color: SKStyleAsset.azure.swiftUIColor
          ),
          titleModel: .init(text: model.walletTitle),
          descriptionModel: .init(
            text: model.walletDescription,
            textStyle: .netural
          )
        ),
        isSelectable: true,
        backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1),
        action: {
          presenter.moduleOutput?.openCreateIndestructibleSeedPhrase24WalletScreen()
        }
      )
    )
  }
  
  func createImageHighTechView() -> some View {
    let model = presenter.getImageHighTechModel()
    return WidgetCryptoView(
      .init(
        leftSide: .init(
          imageModel: .custom(
            image: Image(systemName: model.walletSystemImageName),
            color: SKStyleAsset.azure.swiftUIColor
          ),
          titleModel: .init(text: model.walletTitle),
          descriptionModel: .init(
            text: model.walletDescription,
            textStyle: .netural
          )
        ),
        isSelectable: true,
        backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1),
        action: {
          presenter.moduleOutput?.openCreateHighTechImageIDWalletScreen()
        }
      )
    )
  }
  
  func createImportSeedPhraseWalletView() -> some View {
    let model = presenter.getImportSeedPhraseWalletModel()
    return WidgetCryptoView(
      .init(
        leftSide: .init(
          imageModel: .custom(
            image: Image(systemName: model.walletSystemImageName),
            color: SKStyleAsset.azure.swiftUIColor
          ),
          titleModel: .init(text: model.walletTitle),
          descriptionModel: .init(
            text: model.walletDescription,
            textStyle: .netural
          )
        ),
        isSelectable: true,
        backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1),
        action: {
          presenter.moduleOutput?.openImportSeedPhraseWalletScreen()
        }
      )
    )
  }
  
  func createImportImageHighTechWalletView() -> some View {
    let model = presenter.getImportImageHighTechWalletModel()
    return WidgetCryptoView(
      .init(
        leftSide: .init(
          imageModel: .custom(
            image: Image(systemName: model.walletSystemImageName),
            color: SKStyleAsset.azure.swiftUIColor
          ),
          titleModel: .init(text: model.walletTitle),
          descriptionModel: .init(
            text: model.walletDescription,
            textStyle: .netural
          )
        ),
        isSelectable: true,
        backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1),
        action: {
          presenter.moduleOutput?.openImportImageHighTechWalletScreen()
        }
      )
    )
  }
  
  // TODO: - Добавлю позже этот функционал
  //  func createTrackWalletView() -> some View {
  //    let model = presenter.getTrackWalletModel()
  //    return WidgetCryptoView(
  //      .init(
  //        leftSide: .init(
  //          imageModel: .custom(
  //            image: Image(systemName: model.walletSystemImageName),
  //            color: SKStyleAsset.azure.swiftUIColor
  //          ),
  //          titleModel: .init(text: model.walletTitle),
  //          descriptionModel: .init(
  //            text: model.walletDescription,
  //            textStyle: .netural
  //          )
  //        ),
  //        isSelectable: true,
  //        backgroundColor: SKStyleAsset.constantSlate.swiftUIColor.opacity(0.1),
  //        action: {
  //          presenter.moduleOutput?.openImportTrackWalletWalletScreen()
  //        }
  //      )
  //    )
  //  }
}

// MARK: - Preview

struct MyNewWalletSheetView_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      MyNewWalletSheetAssembly().createModule().viewController
    }
  }
}

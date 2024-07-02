//
//  NavigationCustomView.swift
//
//
//  Created by Vitalii Sosin on 16.12.2023.
//

import SwiftUI
import SKFoundation
import SKStyle

@available(iOS 16.0, *)
public struct NavigationCustomView<Content: View>: View {
  
  // MARK: - Private properties
  
  private let title: String?
  
  private let leftSideItem: NavigationSideCustomModel?
  private let leftSideItemAction: (() -> Void)?
  
  private let centerItem: NavigationCenterCustomModel?
  private let centerItemAction: (() -> Void)?
  
  private let rightSideItem: NavigationSideCustomModel?
  private let rightSideItemAction: (() -> Void)?
  
  private let tabBarIsHidden: Bool
  private let isShowBackButton: Bool
  private let navigationDisplayMode: NavigationBarItem.TitleDisplayMode
  private let navigationBackgroundVisibility: Visibility
  private let backgroundContent: Color?
  private let loaderViewIsOn: Bool
  private let isEndEditing: Bool
  private let colorScheme: ColorScheme?
  private let content: () -> Content
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - title: Заголовок
  ///   - navigationDisplayMode: Большой или маленький заголовок
  ///   - leftSideItem: Контент в навигейшен баре слева
  ///   - leftSideItemAction: Действие в навигейшен баре слева
  ///   - centerItem: Контент в навигейшен баре по центру
  ///   - centerItemAction: Контент в навигейшен баре по центру
  ///   - rightSideItem: Контент в навигейшен баре справа
  ///   - rightSideItemAction: Действие в навигейшен баре справа
  ///   - tabBarIsHidden: скрыть нижний таб бар
  ///   - isShowBackButton: Показывать кнопку назад
  ///   - navigationBackgroundVisibility: Фон у навигейшен бара
  ///   - backgroundContent: Цвет фона для контента
  ///   - loaderViewIsOn: Лоадер для контента
  ///   - isEndEditing: Скрыть клавиатуру
  ///   - colorScheme: Тема приложения
  ///   - content: Контент
  public init(
    title: String? = nil,
    navigationDisplayMode: NavigationBarItem.TitleDisplayMode = .inline,
    leftSideItem: NavigationSideCustomModel? = nil,
    leftSideItemAction: (() -> Void)? = nil,
    centerItem: NavigationCenterCustomModel? = nil,
    centerItemAction: (() -> Void)? = nil,
    rightSideItem: NavigationSideCustomModel? = nil,
    rightSideItemAction: (() -> Void)? = nil,
    tabBarIsHidden: Bool = false,
    isShowBackButton: Bool = true,
    navigationBackgroundVisibility: Visibility = .visible,
    backgroundContent: Color? = nil,
    loaderViewIsOn: Bool = false,
    isEndEditing: Bool = false,
    colorScheme: ColorScheme? = nil,
    content: @escaping () -> Content
  ) {
    self.title = title
    self.navigationDisplayMode = navigationDisplayMode
    self.leftSideItem = leftSideItem
    self.leftSideItemAction = leftSideItemAction
    self.centerItem = centerItem
    self.centerItemAction = centerItemAction
    self.rightSideItem = rightSideItem
    self.rightSideItemAction = rightSideItemAction
    self.tabBarIsHidden = tabBarIsHidden
    self.isShowBackButton = isShowBackButton
    self.navigationBackgroundVisibility = navigationBackgroundVisibility
    self.backgroundContent = backgroundContent
    self.loaderViewIsOn = loaderViewIsOn
    self.isEndEditing = isEndEditing
    self.colorScheme = colorScheme
    self.content = content
  }
  
  public var body: some View {
    content()
      .navigationBarBackButtonHidden(!isShowBackButton)
      .background((backgroundContent ?? SKStyleAsset.onyx.swiftUIColor).edgesIgnoringSafeArea(.all))
      .navigationBarTitleDisplayMode(navigationDisplayMode)
      .if(title != nil, transform: { view in
        Group {
          if let title {
            view.navigationTitle(Text(title))
          }
        }
      })
      .toolbarBackground((backgroundContent ?? SKStyleAsset.onyx.swiftUIColor).opacity(0.8), for: .navigationBar)
      .toolbarBackground((backgroundContent ?? SKStyleAsset.onyx.swiftUIColor).opacity(0.8), for: .tabBar)
      .toolbarBackground((backgroundContent ?? SKStyleAsset.onyx.swiftUIColor).opacity(0.8), for: .bottomBar)
      .toolbar(tabBarIsHidden ? .hidden : .visible, for: .tabBar)
      .navigationViewStyle(StackNavigationViewStyle())
      .navigationBarHidden(navigationBackgroundVisibility == .hidden)
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarLeading) {
          if let leftSideItem = leftSideItem, let action = leftSideItemAction {
            getToolbarSideItemContent(for: leftSideItem, action: action)
          }
        }
        ToolbarItemGroup(placement: .principal) {
          if let centerItem {
            getToolbarCenterItemContent(for: centerItem, action: centerItemAction)
          }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          if let rightSideItem = rightSideItem, let action = rightSideItemAction {
            getToolbarSideItemContent(for: rightSideItem, action: action)
          }
        }
      }
      .if(loaderViewIsOn) { view in
        view
          .overlay {
            LoaderView()
          }
      }
      .if(isEndEditing) { view in
        view
          .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
          }
      }
      .preferredColorScheme(createPreferredColorScheme())
  }
}

// MARK: - Private

@available(iOS 16.0, *)
private extension NavigationCustomView {
  func createPreferredColorScheme() -> ColorScheme? {
    if let colorScheme {
      return colorScheme
    } else {
      if let isDarkMode = UserDefaults.standard.object(forKey: "darkModePreference") as? Bool {
        return isDarkMode ? .dark : .light
      } else {
        return nil
      }
    }
  }
  
  func getToolbarSideItemContent(for item: NavigationSideCustomModel, action: (() -> Void)?) -> AnyView {
    switch item {
    case .cancel, .done, .refresh, .share, .delete, .write:
      AnyView(
        TapGestureView(
          style: .flash,
          touchesEnded: {
            action?()
          },
          content: {
            item.image
              .foregroundColor(SKStyleAsset.constantAzure.swiftUIColor)
          }
        )
      )
    case let .custom(text, image):
      AnyView(
        RoundButtonView(
          style: .custom(image: image, text: text)
        ) {
          action?()
        }
      )
    case .none:
      AnyView(EmptyView())
    }
  }
  
  func getToolbarCenterItemContent(for item: NavigationCenterCustomModel, action: (() -> Void)?) -> AnyView {
    switch item {
    case let .widgetCryptoView(text, image, isSelectable):
      AnyView(
        TapGestureView(
          style: .flash,
          isSelectable: isSelectable,
          touchesEnded: {
            centerItemAction?()
          },
          content: {
            HStack(alignment: .center, spacing: .s2) {
              if let image {
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: .s4, height: .s4)
                  .allowsHitTesting(true)
              }
              
              Text(text)
                .font(.fancy.text.regularMedium)
                .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
                .allowsHitTesting(true)
              
              if isSelectable {
                Image(systemName: "chevron.down")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: .s3, height: .s2)
                  .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
                  .allowsHitTesting(true)
              }
            }
          }
        )
      )
    case .none:
      AnyView(EmptyView())
    }
  }
}

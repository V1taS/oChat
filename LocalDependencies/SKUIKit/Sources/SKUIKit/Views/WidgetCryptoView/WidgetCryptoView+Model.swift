//
//  WidgetCryptoView+Model.swift
//
//
//  Created by Vitalii Sosin on 13.12.2023.
//

import SwiftUI
import SKStyle

// MARK: - Model

@available(iOS 16.0, *)
extension WidgetCryptoView {
  public struct Model: Identifiable, Hashable {
    // MARK: - Public properties
    public let id: UUID
    public let leftSide: ContentModel?
    public let rightSide: ContentModel?
    public let additionCenterTextModel: TextModel?
    public let additionCenterContent: AnyView?
    public var isSelectable: Bool
    public let backgroundColor: Color?
    public let action: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки для виджета
    /// - Parameters:
    ///   - leftSide: Левая сторона виджета
    ///   - rightSide: Правая сторона виджета
    ///   - additionCenterTextModel: Дополнительный текст по центру
    ///   - additionCenterContent: Дополнительный контент по центру
    ///   - isSelectable: Можно ли нажать на ячейку
    ///   - backgroundColor: Цвет фона виджета
    ///   - action: Замыкание, которое будет выполняться при нажатии на виджет
    public init(leftSide: WidgetCryptoView.ContentModel?,
                rightSide: WidgetCryptoView.ContentModel? = nil,
                additionCenterTextModel: TextModel? = nil,
                additionCenterContent: AnyView? = nil,
                isSelectable: Bool = true,
                backgroundColor: Color? = nil,
                action: (() -> Void)? = nil) {
      self.id = UUID()
      self.leftSide = leftSide
      self.rightSide = rightSide
      self.additionCenterTextModel = additionCenterTextModel
      self.additionCenterContent = additionCenterContent
      self.isSelectable = isSelectable
      self.backgroundColor = backgroundColor
      self.action = action
    }
  }
}

// MARK: - LeftSide

@available(iOS 16.0, *)
extension WidgetCryptoView {
  public struct ContentModel: Equatable, Hashable {
    // MARK: - Public properties
    public let imageModel: ImageModel?
    public let itemModel: ItemModel?
    public let titleModel: TextModel?
    public let titleAdditionModel: TextModel?
    public let titleAdditionRoundedModel: TextModel?
    public let descriptionModel: TextModel?
    public let descriptionAdditionModel: TextModel?
    public let descriptionAdditionRoundedModel: TextModel?
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки для виджета
    /// - Parameters:
    ///   - imageModel: Иконка
    ///   - itemModel: Любой AnyView
    ///   - titleModel: Заголовок
    ///   - titleAdditionModel: Дополнительный заголовок
    ///   - titleAdditionRoundedModel: Дополнительный заголовок скругленного текста
    ///   - descriptionModel: Описание
    ///   - descriptionAdditionModel: Дополнительное описание
    ///   - descriptionAdditionRoundedModel: Дополнительное описание скругленного текста
    public init(
      imageModel: WidgetCryptoView.ImageModel? = nil,
      itemModel: ItemModel? = nil,
      titleModel: WidgetCryptoView.TextModel? = nil,
      titleAdditionModel: WidgetCryptoView.TextModel? = nil,
      titleAdditionRoundedModel: WidgetCryptoView.TextModel? = nil,
      descriptionModel: WidgetCryptoView.TextModel? = nil,
      descriptionAdditionModel: WidgetCryptoView.TextModel? = nil,
      descriptionAdditionRoundedModel: TextModel? = nil
    ) {
      self.imageModel = imageModel
      self.itemModel = itemModel
      self.titleModel = titleModel
      self.titleAdditionModel = titleAdditionModel
      self.titleAdditionRoundedModel = titleAdditionRoundedModel
      self.descriptionModel = descriptionModel
      self.descriptionAdditionModel = descriptionAdditionModel
      self.descriptionAdditionRoundedModel = descriptionAdditionRoundedModel
    }
  }
}

// MARK: - TextModel

@available(iOS 16.0, *)
extension WidgetCryptoView {
  public struct TextModel: Equatable, Hashable {
    // MARK: - Public properties
    public let text: String
    public let lineLimit: Int
    public let textStyle: TextStyle
    public let textIsSecure: Bool
    
    // MARK: - Initialization
    
    /// Инициализатор для создания модельки
    /// - Parameters:
    ///   - text: Заголовок
    ///   - lineLimit: Количество строк
    ///   - textStyle: Стиль заголовка
    ///   - textIsSecure: Заголовок скрыт
    public init(
      text: String,
      lineLimit: Int = 1,
      textStyle: WidgetCryptoView.TextStyle = .standart,
      textIsSecure: Bool = false
    ) {
      self.text = text
      self.lineLimit = lineLimit
      self.textStyle = textStyle
      self.textIsSecure = textIsSecure
    }
  }
}

// MARK: - TextStyle

@available(iOS 16.0, *)
extension WidgetCryptoView {
  /// Стиль текста в виджете
  public enum TextStyle: Equatable, Hashable {
    /// Цвет из стиля
    var color: Color {
      switch self {
      case .standart:
        return SKStyleAsset.ghost.swiftUIColor
      case .positive:
        return SKStyleAsset.constantLime.swiftUIColor
      case .negative:
        return SKStyleAsset.constantRuby.swiftUIColor
      case .attention:
        return SKStyleAsset.constantAmberGlow.swiftUIColor
      case .netural:
        return SKStyleAsset.constantSlate.swiftUIColor
      }
    }
    
    /// Стандартный белый цвет
    case standart
    /// Позитивный зеленый цвет
    case positive
    /// Негативный красный цвет
    case negative
    /// Внимание оранжевый цвет
    case attention
    /// Нетральный серый цвет
    case netural
  }
}

// MARK: - ItemModel

@available(iOS 16.0, *)
extension WidgetCryptoView {
  public enum ItemModel: Equatable, Hashable {
    public static func == (lhs: WidgetCryptoView.ItemModel, rhs: WidgetCryptoView.ItemModel) -> Bool {
      return lhs.size == rhs.size
    }
    
    var size: CGSize {
      switch self {
      case let .custom(_, size, _):
        switch size {
        case .standart:
          return .init(width: CGFloat.s4, height: .s4)
        case .large:
          return .init(width: CGFloat.s11, height: .s11)
        case let .custom(width, height):
          return .init(width: width ?? .infinity, height: height ?? .infinity)
        }
      case .switcher:
        return .init(width: .infinity, height: CGFloat.s4)
      case .radioButtons:
        return .init(width: CGFloat.s4, height: .s4)
      case .checkMarkButton:
        return .init(width: CGFloat.s4, height: .s4)
      case .infoButton:
        return .init(width: CGFloat.s6, height: .s6)
      }
    }
    
    /// Пользовательские настройки
    case custom(item: AnyView, size: Size = .large, isHitTesting: Bool = false)
    /// Переключатель
    case switcher(initNewValue: Bool = false, isEnabled: Bool = true, action: ((_ newValue: Bool) -> Void)?)
    /// Круглая кнопка
    case radioButtons(initNewValue: Bool = false, isChangeValue: Bool = true, action: ((_ newValue: Bool) -> Void)?)
    /// Кнопка выбора
    case checkMarkButton(initNewValue: Bool = false, isChangeValue: Bool = true, action: ((_ newValue: Bool) -> Void)?)
    /// Кнопка для получения дополнительной информации
    case infoButton(action: (() -> Void)?)
    
    public enum Size: Equatable {
      case standart
      case large
      case custom(width: CGFloat? = nil, height: CGFloat? = nil)
    }
  }
}

// MARK: - ImageModel

@available(iOS 16.0, *)
extension WidgetCryptoView {
  public enum ImageModel: Equatable, Hashable {
    var roundedStyle: WidgetCryptoView.ImageModel.RoundedStyle {
      switch self {
      case let .custom(_, _, _, _, _, roundedStyle):
        return roundedStyle
      case .chevron:
        return .circle
      }
    }
    
    var size: CGSize {
      switch self {
      case let .custom(_, _, _, _, size, _):
        switch size {
        case .standart:
          return .init(width: CGFloat.s4, height: .s4)
        case .large:
          return .init(width: CGFloat.s11, height: .s11)
        }
      case .chevron:
        return .init(width: CGFloat.s2, height: .s3)
      }
    }
    
    var backgroundColor: Color? {
      switch self {
      case let .custom(_, _, _, backgroundColor, _, _):
        return backgroundColor
      case .chevron:
        return nil
      }
    }
    
    var imageColor: Color? {
      switch self {
      case let .custom(_, _, color, _, _, _):
        return color ?? SKStyleAsset.ghost.swiftUIColor
      case .chevron:
        return SKStyleAsset.constantSlate.swiftUIColor
      }
    }
    
    var image: Image? {
      switch self {
      case let .custom(image, _, _, _, _, _):
        return image
      case .chevron:
        return Image(systemName: "chevron.right")
      }
    }
    
    var imageURL: URL? {
      switch self {
      case let .custom(_, imageURL, _, _, _, _):
        return imageURL
      default:
        return nil
      }
    }
    
    /// Пользовательские настройки
    case custom(
      image: Image? = nil,
      imageURL: URL? = nil,
      color: Color? = nil,
      backgroundColor: Color? = nil,
      size: Size = .large,
      roundedStyle: RoundedStyle = .circle
    )
    
    /// Шеврон (стрелочка вправо)
    case chevron
    
    public enum RoundedStyle: Equatable, Hashable {
      case circle
      case squircle
    }
    
    public enum Size: Equatable, Hashable {
      case standart
      case large
    }
  }
}

// MARK: - Equatable

@available(iOS 16.0, *)
extension WidgetCryptoView.Model: Equatable {
  public static func == (lhs: WidgetCryptoView.Model, rhs: WidgetCryptoView.Model) -> Bool {
    return lhs.id == rhs.id &&
    lhs.leftSide == rhs.leftSide &&
    lhs.rightSide == rhs.rightSide &&
    lhs.additionCenterTextModel == rhs.additionCenterTextModel &&
    lhs.isSelectable == rhs.isSelectable &&
    lhs.backgroundColor == rhs.backgroundColor
  }
}

// MARK: - Hashable Model

@available(iOS 16.0, *)
extension WidgetCryptoView.Model {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(leftSide)
    hasher.combine(rightSide)
    hasher.combine(additionCenterTextModel)
    hasher.combine(isSelectable)
    hasher.combine(backgroundColor)
  }
}

// MARK: - Hashable ItemModel

@available(iOS 16.0, *)
extension WidgetCryptoView.ItemModel {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .custom(_, _, let isHitTesting):
      hasher.combine("custom")
      hasher.combine(isHitTesting)
      
    case let .switcher(initNewValue, _, _):
      hasher.combine("switcher")
      hasher.combine(initNewValue)
      
    case let .radioButtons(initNewValue, _, _):
      hasher.combine("radioButtons")
      hasher.combine(initNewValue)
      
    case let .checkMarkButton(initNewValue, _, _):
      hasher.combine("checkMarkButton")
      hasher.combine(initNewValue)
      
    case .infoButton(_):
      hasher.combine("infoButton")
    }
  }
}

// MARK: - Hashable ImageModel

@available(iOS 16.0, *)
extension WidgetCryptoView.ImageModel {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case let .custom(_, _, color, backgroundColor, size, roundedStyle):
      hasher.combine("custom")
      hasher.combine(color)
      hasher.combine(backgroundColor)
      hasher.combine(size)
      hasher.combine(roundedStyle)
      
    case .chevron:
      hasher.combine("chevron")
    }
  }
}

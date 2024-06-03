//
//  InitialStoriesScreenPage.swift
//  oChat
//
//  Created by Vitalii Sosin on 13.01.2024.
//  Copyright © 2024 SosinVitalii.com. All rights reserved.
//

import SKStoriesWidget
import SwiftUI
import SKStyle
import SKUIKit
import Lottie

/// Переиспользуемая страница для сторис
struct InitialStoriesScreenPage: View {
  
  // MARK: - Private properties
  
  @Binding private var progress: CGFloat
  private let title: String
  private let subtitle: String
  private let storiesType: InitialStoriesScreenModel
  
  @State private var titleIsIsAnimating = false
  @State private var titleIsHidden = true
  @State private var subtitleIsIsAnimating = false
  @State private var subtitleIsHidden = true
  
  // MARK: - Initialization
  
  /// Инициализатор
  /// - Parameters:
  ///   - progress: Прогресс выполнения. Начинается с 1 и идет к 0
  ///   - title: Заголовок у сторис
  ///   - subtitle: Описание сторис
  ///   - storiesType: Тип сторис. Какой экран показать
  public init(
    progress: Binding<CGFloat>,
    title: String,
    subtitle: String,
    storiesType: InitialStoriesScreenModel
  ) {
    self._progress = progress
    self.title = title
    self.subtitle = subtitle
    self.storiesType = storiesType
  }
  
  var body: some View {
    screenBuilder()
  }
}

// MARK: - Private

private extension InitialStoriesScreenPage {
  @ViewBuilder
  func screenBuilder() -> AnyView {
    AnyView(
      NavigationCustomView {
        VStack(spacing: .s8) {
          switch storiesType {
          case .first:
            titleBuilder()
          default:
            titleAndSubtitleBuilder()
          }
          
          imageBuilder()
        }
        .padding(.top, .s20)
        .onChange(of: progress) { newValue in
          if newValue < 0.01 {
            withAnimation(nil) {
              resetSubtitleAnimation()
            }
          }
        }
        .onChange(of: storiesType) { _ in
          setSubtitleAnimation()
          setTitleAnimation()
        }
        .onAppear {
          setSubtitleAnimation()
          setTitleAnimation()
        }
      }
    )
  }
  
  func imageBuilder(paddingSize: CGFloat = .s4) -> AnyView {
    return AnyView(
      Group {
        switch storiesType {
        case .first:
          OChatAsset.storiesLogo.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
        case .second:
          LottieView(animation: .named(OChatAsset.storiesImpenetrableProtection.name))
            .resizable()
            .looping()
            .aspectRatio(contentMode: .fit)
        case .third:
          LottieView(animation: .named(OChatAsset.storiesConfidentialityGuaranteed.name))
            .resizable()
            .looping()
            .aspectRatio(contentMode: .fit)
        case .fourth:
          LottieView(animation: .named(OChatAsset.storiesEncryption.name))
            .resizable()
            .looping()
            .aspectRatio(contentMode: .fit)
        case .fifth:
          LottieView(animation: .named(OChatAsset.storiesMoreThanThousandCryptocurrencies.name))
            .resizable()
            .looping()
            .aspectRatio(contentMode: .fit)
        }
      }
        .allowsHitTesting(false)
        .padding(.horizontal, paddingSize)
    )
  }
  
  func titleBuilder() -> some View {
    Text(title)
      .font(.fancy.text.largeTitle)
      .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
      .multilineTextAlignment(.center)
      .offset(y: titleIsIsAnimating ? 0 : 50)
      .opacity(titleIsHidden ? .zero : 1)
      .allowsHitTesting(false)
      .padding(.horizontal, .s4)
  }
  
  func titleAndSubtitleBuilder() -> some View {
    Group {
      VStack(spacing: .s4) {
        Text(title)
          .font(.fancy.text.largeTitle)
          .foregroundColor(SKStyleAsset.ghost.swiftUIColor)
          .multilineTextAlignment(.center)
          .offset(y: titleIsIsAnimating ? 0 : 50)
          .opacity(titleIsHidden ? .zero : 1)
          .allowsHitTesting(false)
        
        Text(subtitle)
          .font(.fancy.text.regularMedium)
          .foregroundColor(SKStyleAsset.slate.swiftUIColor)
          .multilineTextAlignment(.center)
          .offset(y: subtitleIsIsAnimating ? 0 : 50)
          .opacity(subtitleIsHidden ? .zero : 1)
          .allowsHitTesting(false)
      }
      .padding(.horizontal, .s4)
    }
  }
  
  func setTitleAnimation() {
    resetSubtitleAnimation()
    
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
      withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
        titleIsIsAnimating = true
        titleIsHidden = false
      }
    }
  }
  
  func setSubtitleAnimation() {
    resetSubtitleAnimation()
    
    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
      withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
        subtitleIsIsAnimating = true
        subtitleIsHidden = false
      }
    }
  }
  
  func resetSubtitleAnimation() {
    subtitleIsIsAnimating = false
    subtitleIsHidden = true
    
    titleIsIsAnimating = false
    titleIsHidden = true
  }
}

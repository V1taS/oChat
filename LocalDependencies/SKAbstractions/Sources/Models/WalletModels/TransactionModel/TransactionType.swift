//
//  TransactionType.swift
//  SKAbstractions
//
//  Created by Vitalii Sosin on 07.05.2024.
//

// MARK: - TransactionType

extension TransactionModel {
  /// Тип транзакции, описывающий её текущее состояние.
  public enum TransactionType {
    /// Транзакция отправлена.
    case sent
    
    /// Транзакция получена.
    case received
    
    /// Транзакция отклонена.
    case declined
    
    /// Транзакция отменена.
    case cancelled
    
    /// Транзакция не была отправлена.
    case notSent
  }
}

// MARK: - TransactionType

extension TransactionModel.TransactionType {
  /// Возвращает название транзакции
  public var title: String {
    switch self {
    case .sent:
      return SKAbstractionsStrings.TransactionModelLocalization
        .State.Sent.title
    case .received:
      return SKAbstractionsStrings.TransactionModelLocalization
        .State.Received.title
    case .declined:
      return SKAbstractionsStrings.TransactionModelLocalization
        .State.Declined.title
    case .cancelled:
      return SKAbstractionsStrings.TransactionModelLocalization
        .State.Cancelled.title
    case .notSent:
      return SKAbstractionsStrings.TransactionModelLocalization
        .State.NotSent.title
    }
  }
  
  /// Возвращает знак транзакции в зависимости от её типа.
  public var sign: String {
    switch self {
    case .sent:
      return "-"
    case .received:
      return "+"
    case .declined, .cancelled, .notSent:
      return ""
    }
  }
}

// MARK: - IdentifiableAndCodable

extension TransactionModel.TransactionType: IdentifiableAndCodable {}

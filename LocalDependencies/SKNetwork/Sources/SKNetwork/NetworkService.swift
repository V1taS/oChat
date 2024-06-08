//
//  NetworkService.swift
//
//
//  Created by Vitalii Sosin on 30.04.2022.
//

import Foundation

/// Сервис по работе с сетью
public protocol INetworkService {
  
  /// Сделать запрос в сеть
  ///  - Parameters:
  ///   - urlString: Адрес запроса
  ///   - queryItems: Query параметры
  ///   - httpMethod: Метод запроса
  ///   - headers: Хедеры
  ///   - Returns: Результат выполнения
  func performRequestWith(urlString: String,
                          queryItems: [URLQueryItem],
                          httpMethod: NetworkMethod,
                          headers: [HeadersType],
                          completion: ((Result<Data?, NetworkError>) -> Void)?)
  
  /// Делает маппинг из `JSON` в структуру данных типа `Generic`
  /// - Parameters:
  ///  - result: модель данных с сервера
  ///  - to: В какой тип данных маппим
  /// - Returns: Результат маппинга в структуру `Generic`
  func map<ResponseType: Codable>(_ result: Data?,
                                  to _: ResponseType.Type) -> ResponseType?
}

/// Исполнитель запроса сеанса URL
public final class NetworkService {
  // MARK: - Private variable
  
  private var session: URLSession
  private let networkReachability: NetworkReachability? = DefaultNetworkReachability()
  
  // MARK: - Initialization
  
  public init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = Appearance().timeOutInterval
    configuration.timeoutIntervalForResource = Appearance().timeOutInterval
    self.session = URLSession(configuration: configuration)
  }
}

// MARK: - NetworkService

extension NetworkService: INetworkService {
  public func performRequestWith(urlString: String,
                                 queryItems: [URLQueryItem],
                                 httpMethod: NetworkMethod,
                                 headers: [HeadersType],
                                 completion: ((Result<Data?, NetworkError>) -> Void)?) {
    DispatchQueue.global().async { [weak self] in
      guard self?.networkReachability?.isReachable ?? false else {
        DispatchQueue.main.async {
          completion?(.failure(.noInternetConnection))
        }
        return
      }
      
      guard var components = URLComponents(string: urlString) else {
        DispatchQueue.main.async {
          completion?(.failure(.invalidURLRequest))
        }
        return
      }
      components.queryItems = queryItems
      
      guard let url = components.url else {
        DispatchQueue.main.async {
          completion?(.failure(.invalidURLRequest))
        }
        return
      }
      
      var requestURL = URLRequest(url: url)
      requestURL.httpMethod = httpMethod.rawValue
      
      // Обработка данных в теле запроса для POST, PUT и PATCH
      switch httpMethod {
      case let .post(data), let .put(data), let .patch(data):
        requestURL.httpBody = data
      default: break
      }
      
      headers.forEach { headersType in
        headersType.headers.forEach {
          requestURL.setValue($0, forHTTPHeaderField: $1)
        }
      }
      
#if DEBUG
      print("\n\nRequest:\n\(requestURL.curlString)")
#endif
      
      let task = self?.session.dataTask(with: requestURL) { data, response, error in
        if let error = error {
          let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
          DispatchQueue.main.async {
            completion?(.failure(.unacceptedHTTPStatus(code: statusCode,
                                                       localizedDescription: error.localizedDescription)))
          }
        } else {
          DispatchQueue.main.async {
            completion?(.success(data))
          }
        }
      }
      task?.resume()
    }
  }
  
  public func map<ResponseType: Codable>(_ result: Data?, to _: ResponseType.Type) -> ResponseType? {
    guard let data = result else {
      return nil
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(ResponseType.self, from: data)
    } catch {
      return nil
    }
  }
}

// MARK: - Appearance

private extension NetworkService {
  struct Appearance {
    let timeOutInterval: Double = 60
  }
}

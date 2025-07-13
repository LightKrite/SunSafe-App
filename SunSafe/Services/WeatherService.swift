import Foundation

/// Сервис для получения текущей погоды и прогноза по API weatherapi.com
final class WeatherService {
    
    /// Конфигурационный менеджер для безопасного доступа к API ключам
    private let config = ConfigurationManager.shared
    
    /// Инициализация сервиса с проверкой конфигурации
    init() {
        #if DEBUG
        // В debug режиме проверяем корректность конфигурации
        if !config.validateConfiguration() {
            print("⚠️ Weather service initialized with invalid configuration")
        }
        #endif
    }
    
    /// Универсальный метод для выполнения HTTP запросов
    private func performRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = config.networkTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        // Добавляем User-Agent для идентификации
        request.setValue("SunSafe/1.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Проверяем HTTP статус код
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    let error = NSError(
                        domain: "HTTPError", 
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"]
                    )
                    completion(.failure(error))
                    return
                }
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "No data received from server"
                ])))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ JSON Decode Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    /// Загружает текущую погоду для указанного города
    /// - Parameters:
    ///   - city: Название города
    ///   - completion: Замыкание с результатом (WeatherResponse или ошибка)
    func fetchCurrentWeather(for city: String = "", completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let cityName = city.isEmpty ? config.defaultCity : city
        let urlString = "\(config.baseURL)/current.json?key=\(config.weatherAPIKey)&q=\(cityName)&aqi=no"

        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else {
            completion(.failure(NSError(domain: "InvalidURLError", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create valid URL for city: \(cityName)"
            ])))
            return
        }

        performRequest(url: url, completion: completion)
    }
    
    /// Загружает прогноз UV по часам для указанного города (первый день)
    /// - Parameters:
    ///   - city: Название города
    ///   - completion: Замыкание с результатом (ForecastResponse или ошибка)
    func fetchForecast(for city: String = "", completion: @escaping (Result<ForecastResponse, Error>) -> Void) {
        let cityName = city.isEmpty ? config.defaultCity : city
        let urlString = "\(config.baseURL)/forecast.json?key=\(config.weatherAPIKey)&q=\(cityName)&days=1&aqi=no"
        
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else {
            completion(.failure(NSError(domain: "InvalidURLError", code: 1002, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create valid URL for forecast: \(cityName)"
            ])))
            return
        }

        performRequest(url: url, completion: completion)
    }
}

// MARK: - URL Validation
private extension WeatherService {
    /// Проверяет корректность URL перед запросом
    func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http" else {
            return false
        }
        return true
    }
}
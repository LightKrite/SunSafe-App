import Foundation

/// Сервис для получения текущей погоды и прогноза по API weatherapi.com
final class WeatherService {
    private func performRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// API ключ для доступа к weatherapi.com
    private let apiKey = "d48cbea92d9e4e9e9d5122837251006"
    /// Базовый URL для запроса текущей погоды
    private let baseURL = "https://api.weatherapi.com/v1/current.json"

    /// Загружает текущую погоду для указанного города
    /// - Parameters:
    ///   - city: Название города
    ///   - completion: Замыкание с результатом (WeatherResponse или ошибка)
    func fetchCurrentWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)?key=\(apiKey)&q=\(city)&aqi=no"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1001)))
            return
        }

        performRequest(url: url, completion: completion)
    }
    
    /// Загружает прогноз UV по часам для указанного города (первый день)
    /// - Parameters:
    ///   - city: Название города
    ///   - completion: Замыкание с результатом (ForecastResponse или ошибка)
    func fetchForecast(for city: String, completion: @escaping (Result<ForecastResponse, Error>) -> Void) {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(city)&days=1&aqi=no"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        performRequest(url: url, completion: completion)
    }
}

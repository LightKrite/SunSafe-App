import Foundation

final class WeatherService {
    private let apiKey = "d48cbea92d9e4e9e9d5122837251006"
    private let baseURL = "https://api.weatherapi.com/v1/current.json"

    func fetchCurrentWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)?key=\(apiKey)&q=\(city)&aqi=no"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1001)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 1002)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchForecast(for city: String, completion: @escaping (Result<[HourForecast], Error>) -> Void) {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(city)&days=1&aqi=no"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ForecastResponse.self, from: data)
                let hourly = decoded.forecast.forecastday.first?.hour ?? []
                completion(.success(hourly))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

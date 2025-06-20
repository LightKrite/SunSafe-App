import Foundation

final class MainViewModel {

    private let weatherService = WeatherService()
    
    private let currentWeatherKey = "cachedCurrentWeather"
    private let currentWeatherTimestampKey = "cachedCurrentWeatherTimestamp"
    
    private let forecastKey = "cachedForecast"
    private let forecastTimestampKey = "cachedForecastTimestamp"

    /// Передаём данные для главного экрана
    var onDataUpdate: ((String, String, String) -> Void)?
    var onError: ((String) -> Void)?
    
    /// Новое: почасовой прогноз UV
    var onForecastUpdate: (([HourForecast]) -> Void)?
    
    private func cacheWeather(_ response: WeatherResponse, for city: String) {
        if let encoded = try? JSONEncoder().encode(response) {
            UserDefaults.standard.set(encoded, forKey: "\(currentWeatherKey)_\(city)")
            UserDefaults.standard.set(Date(), forKey: "\(currentWeatherTimestampKey)_\(city)")
        }
    }
    private func loadCachedWeather(for city: String) -> (WeatherResponse, Date)? {
        guard let data = UserDefaults.standard.data(forKey: "\(currentWeatherKey)_\(city)"),
              let timestamp = UserDefaults.standard.object(forKey: "\(currentWeatherTimestampKey)_\(city)") as? Date,
              let response = try? JSONDecoder().decode(WeatherResponse.self, from: data)
        else { return nil }
        return (response, timestamp)
    }
    
    private func cacheForecast(_ hours: [HourForecast], for city: String) {
        if let encoded = try? JSONEncoder().encode(hours) {
            UserDefaults.standard.set(encoded, forKey: "\(forecastKey)_\(city)")
            UserDefaults.standard.set(Date(), forKey: "\(forecastTimestampKey)_\(city)")
        }
    }
    private func loadCachedForecast(for city: String) -> ([HourForecast], Date)? {
        guard let data = UserDefaults.standard.data(forKey: "\(forecastKey)_\(city)"),
              let timestamp = UserDefaults.standard.object(forKey: "\(forecastTimestampKey)_\(city)") as? Date,
              let hours = try? JSONDecoder().decode([HourForecast].self, from: data)
        else { return nil }
        return (hours, timestamp)
    }

    /// Загружает текущую погоду для указанного города и передаёт результат через onDataUpdate или ошибку через onError.
    func fetchWeather(for city: String = "Belgrade") {
        // Проверяем кэш
        if let (cached, timestamp) = loadCachedWeather(for: city), Date().timeIntervalSince(timestamp) < 600 {
            let temp = "\(cached.current.temp_c)°C"
            let condition = cached.current.condition.text
            let uv = "UV: \(cached.current.uv)"
            DispatchQueue.main.async {
                self.onDataUpdate?(temp, condition, uv)
            }
            return
        }

        weatherService.fetchCurrentWeather(for: city) { [weak self] result in
            switch result {
            case .success(let response):
                self?.cacheWeather(response, for: city)
                let temp = "\(response.current.temp_c)°C"
                let condition = response.current.condition.text
                let uv = "UV: \(response.current.uv)"
                DispatchQueue.main.async {
                    self?.onDataUpdate?(temp, condition, uv)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onError?("Ошибка погоды: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Загружает почасовой прогноз погоды для указанного города и передаёт результат через onForecastUpdate или ошибку через onError.
    func fetchForecast(for city: String = "Belgrade") {
        if let (cached, timestamp) = loadCachedForecast(for: city), Date().timeIntervalSince(timestamp) < 600 {
            DispatchQueue.main.async {
                self.onForecastUpdate?(cached)
            }
            return
        }
        
        weatherService.fetchForecast(for: city) { [weak self] result in
            switch result {
            case .success(let hours):
                self?.cacheForecast(hours, for: city)
                DispatchQueue.main.async {
                    self?.onForecastUpdate?(hours)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onError?("Ошибка прогноза: \(error.localizedDescription)")
                }
            }
        }
    }
}

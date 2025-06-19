import Foundation

final class MainViewModel {

    private let weatherService = WeatherService()

    // 🔹 Передаём данные для главного экрана
    var onDataUpdate: ((String, String, String) -> Void)?
    var onError: ((String) -> Void)?
    
    // 🔹 Новое: почасовой прогноз UV
    var onForecastUpdate: (([HourForecast]) -> Void)?

    func fetchWeather(for city: String = "Belgrade") {
        weatherService.fetchCurrentWeather(for: city) { [weak self] result in
            switch result {
            case .success(let response):
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

    func fetchForecast(for city: String = "Belgrade") {
        weatherService.fetchForecast(for: city) { [weak self] result in
            switch result {
            case .success(let hours):
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

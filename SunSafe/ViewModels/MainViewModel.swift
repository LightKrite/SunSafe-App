import Foundation

final class MainViewModel {

    private let weatherService = WeatherService()
    
    /// Передаём данные для главного экрана
    var onDataUpdate: ((WeatherResponse) -> Void)?
    var onError: ((String) -> Void)?
    
    /// Новое: почасовой прогноз UV
    var onForecastUpdate: ((ForecastResponse) -> Void)?
    
    /// Загружает текущую погоду для указанного города и передаёт результат через onDataUpdate или ошибку через onError.
    func fetchWeather(for city: String = "Belgrade") {
        weatherService.fetchCurrentWeather(for: city) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.onDataUpdate?(response)
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
        weatherService.fetchForecast(for: city) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.onForecastUpdate?(response)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onError?("Ошибка прогноза: \(error.localizedDescription)")
                }
            }
        }
    }
}

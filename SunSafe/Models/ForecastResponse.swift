import Foundation

/// Корневая структура ответа прогноза погоды.
/// Содержит объект прогноза.
struct ForecastResponse: Codable {
    /// Детальная информация о прогнозе
    let forecast: Forecast
}

/// Структура прогноза: содержит список прогнозов на дни
struct Forecast: Codable {
    /// Массив ежедневных прогнозов
    let forecastday: [ForecastDay]
}

/// Прогноз на конкретный день (почасовой)
struct ForecastDay: Codable {
    /// Массив почасовых прогнозов
    let hour: [HourForecast]
}

/// Почасовой прогноз: содержит время и UV-индекс
struct HourForecast: Codable {
    /// Время, к которому относится прогноз (строка)
    let time: String
    /// Значение UV-индекса
    let uv: Double
}

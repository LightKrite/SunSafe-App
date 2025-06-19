import Foundation

struct ForecastResponse: Codable {
    let forecast: Forecast
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let hour: [HourForecast]
}

struct HourForecast: Codable {
    let time: String
    let uv: Double
}


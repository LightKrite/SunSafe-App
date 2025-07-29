import Foundation

/// Корневой объект ответа с текущей погодой от API
/// Содержит информацию о локации и текущем состоянии
struct WeatherResponse: Codable {
    /// Информация о локации
    let location: Location
    /// Текущая погода
    let current: CurrentWeather
}

/// Структура с описанием локации (город, локальное время)
struct Location: Codable {
    /// Название города
    let name: String
    /// Локальное время
    let localtime: String
}

/// Текущие погодные условия (температура, UV, состояние)
struct CurrentWeather: Codable {
    /// Температура воздуха в градусах Цельсия
    let temp_c: Double
    /// Описание погодного состояния
    let condition: WeatherCondition
    /// Значение UV-индекса
    let uv: Double
}

/// Описание погодного состояния, включая текст и иконку
struct WeatherCondition: Codable {
    /// Текстовое описание
    let text: String
    /// URL или имя иконки погоды
    let icon: String
}
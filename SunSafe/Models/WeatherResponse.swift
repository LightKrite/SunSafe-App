import Foundation

struct WeatherResponse: Decodable {
    let location: Location
    let current: CurrentWeather
}

struct Location: Decodable {
    let name: String
    let localtime: String
}

struct CurrentWeather: Decodable {
    let temp_c: Double
    let condition: WeatherCondition
    let uv: Double
}

struct WeatherCondition: Decodable {
    let text: String
    let icon: String
}

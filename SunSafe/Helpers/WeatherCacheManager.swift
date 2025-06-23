import Foundation

final class WeatherCacheManager {

    enum CacheKey: String {
        case forecast = "cached_forecast"
        case forecastDate = "cached_forecast_date"

        case currentWeather = "cached_current_weather"
        case currentWeatherDate = "cached_current_weather_date"
    }

    private let cacheLifetime: TimeInterval = 60 * 60  // 1 час (в секундах)

    private let userDefaults = UserDefaults.standard

    // MARK: Save

    func save<T: Codable>(_ object: T, for key: CacheKey) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            userDefaults.set(encoded, forKey: key.rawValue)
            userDefaults.set(Date(), forKey: dateKey(for: key))
            print("✅ Saved \(key.rawValue), date: \(Date())")
        } else {
            print("⚠️ Failed to encode object for key: \(key.rawValue)")
        }
    }

    // MARK: Load

    func load<T: Codable>(_ type: T.Type, for key: CacheKey) -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            print("ℹ️ No cached data for key: \(key.rawValue)")
            return nil
        }

        guard let date = userDefaults.object(forKey: dateKey(for: key)) as? Date else {
            print("⚠️ No cache date for key: \(key.rawValue), ignoring cache")
            return nil
        }

        if Date().timeIntervalSince(date) > cacheLifetime {
            print("⚠️ Cache expired for key: \(key.rawValue)")
            return nil
        }

        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(type, from: data) {
            print("✅ Loaded \(key.rawValue) from cache, age: \(Date().timeIntervalSince(date)) sec")
            return decoded
        } else {
            print("⚠️ Failed to decode cached data for key: \(key.rawValue)")
            return nil
        }
    }

    // MARK: Clear

    func clear(for key: CacheKey) {
        userDefaults.removeObject(forKey: key.rawValue)
        userDefaults.removeObject(forKey: dateKey(for: key))
        print("🗑️ Cleared cache for key: \(key.rawValue)")
    }

    func clearAll() {
        clear(for: .forecast)
        clear(for: .currentWeather)
    }

    // MARK: Helpers

    private func dateKey(for key: CacheKey) -> String {
        return key.rawValue + "_date"
    }
}

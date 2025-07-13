import Foundation

final class WeatherCacheManager {

    enum CacheKey: String {
        case forecast = "cached_forecast"
        case forecastDate = "cached_forecast_date"

        case currentWeather = "cached_current_weather"
        case currentWeatherDate = "cached_current_weather_date"
    }

    /// Время жизни кеша берем из конфигурации
    private let cacheLifetime: TimeInterval
    private let userDefaults = UserDefaults.standard
    
    /// Инициализация с использованием конфигурационного менеджера
    init() {
        self.cacheLifetime = ConfigurationManager.shared.cacheLifetime
    }

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
            clearExpiredCache(for: key)
            return nil
        }

        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(type, from: data) {
            print("✅ Loaded \(key.rawValue) from cache, age: \(Date().timeIntervalSince(date)) sec")
            return decoded
        } else {
            print("⚠️ Failed to decode cached data for key: \(key.rawValue)")
            clearCorruptedCache(for: key)
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
    
    /// Очищает просроченный кеш
    private func clearExpiredCache(for key: CacheKey) {
        clear(for: key)
        print("🧹 Cleared expired cache for key: \(key.rawValue)")
    }
    
    /// Очищает поврежденный кеш
    private func clearCorruptedCache(for key: CacheKey) {
        clear(for: key)
        print("🔧 Cleared corrupted cache for key: \(key.rawValue)")
    }

    // MARK: Helpers

    private func dateKey(for key: CacheKey) -> String {
        return key.rawValue + "_date"
    }
    
    /// Проверяет актуальность кеша без загрузки данных
    func isCacheValid(for key: CacheKey) -> Bool {
        guard let date = userDefaults.object(forKey: dateKey(for: key)) as? Date else {
            return false
        }
        return Date().timeIntervalSince(date) <= cacheLifetime
    }
    
    /// Возвращает время последнего обновления кеша
    func lastUpdateTime(for key: CacheKey) -> Date? {
        return userDefaults.object(forKey: dateKey(for: key)) as? Date
    }
}
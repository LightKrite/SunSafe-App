import Foundation

/// Менеджер для безопасного доступа к конфигурационным данным приложения
/// Поддерживает обфускацию API ключей и чтение из plist файлов
final class ConfigurationManager {
    
    /// Синглтон для глобального доступа
    static let shared = ConfigurationManager()
    
    private var configuration: [String: Any] = [:]
    
    private init() {
        loadConfiguration()
    }
    
    /// Загружает конфигурацию из Configuration.plist
    private func loadConfiguration() {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("⚠️ Configuration.plist not found. Using fallback configuration.")
            loadFallbackConfiguration()
            return
        }
        
        configuration = plist
        print("✅ Configuration loaded successfully")
    }
    
    /// Резервная конфигурация для случаев, когда Configuration.plist отсутствует
    private func loadFallbackConfiguration() {
        // В production приложении здесь должны быть значения по умолчанию
        // или код должен падать с четким сообщением об ошибке
        configuration = [
            "WeatherAPIKey": "CONFIGURATION_FILE_MISSING",
            "BaseURL": "https://api.weatherapi.com/v1"
        ]
    }
    
    /// Возвращает API ключ для Weather API с деобфускацией
    var weatherAPIKey: String {
        guard let obfuscatedKey = configuration["WeatherAPIKey"] as? String else {
            fatalError("Weather API key not found in configuration")
        }
        
        // Если ключ обфусцирован, деобфусцируем его
        if obfuscatedKey.hasPrefix("OBF:") {
            return deobfuscate(String(obfuscatedKey.dropFirst(4)))
        }
        
        return obfuscatedKey
    }
    
    /// Возвращает базовый URL для API
    var baseURL: String {
        return configuration["BaseURL"] as? String ?? "https://api.weatherapi.com/v1"
    }
    
    /// Возвращает таймаут для сетевых запросов
    var networkTimeout: TimeInterval {
        return configuration["NetworkTimeout"] as? TimeInterval ?? 30.0
    }
    
    /// Возвращает время жизни кеша в секундах
    var cacheLifetime: TimeInterval {
        return configuration["CacheLifetime"] as? TimeInterval ?? 3600 // 1 час
    }
    
    /// Возвращает город по умолчанию
    var defaultCity: String {
        return configuration["DefaultCity"] as? String ?? "Belgrade"
    }
    
    // MARK: - Обфускация
    
    /// Обфускация строки простым XOR с ключом
    func obfuscate(_ string: String) -> String {
        let key: UInt8 = 0x42 // Простой ключ для обфускации
        let obfuscated = string.utf8.map { byte in
            return byte ^ key
        }
        return Data(obfuscated).base64EncodedString()
    }
    
    /// Деобфускация строки
    private func deobfuscate(_ obfuscatedString: String) -> String {
        guard let data = Data(base64Encoded: obfuscatedString) else {
            print("⚠️ Failed to decode base64 string")
            return obfuscatedString
        }
        
        let key: UInt8 = 0x42
        let deobfuscated = data.map { byte in
            return byte ^ key
        }
        
        return String(data: Data(deobfuscated), encoding: .utf8) ?? obfuscatedString
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension ConfigurationManager {
    /// Возвращает обфусцированную версию API ключа для безопасного хранения
    func getObfuscatedAPIKey(for plainKey: String) -> String {
        return "OBF:" + obfuscate(plainKey)
    }
    
    /// Проверяет конфигурацию на корректность
    func validateConfiguration() -> Bool {
        let requiredKeys = ["WeatherAPIKey", "BaseURL"]
        
        for key in requiredKeys {
            if configuration[key] == nil {
                print("❌ Missing required configuration key: \(key)")
                return false
            }
        }
        
        // Проверяем, что API ключ не является дефолтным значением
        if weatherAPIKey == "CONFIGURATION_FILE_MISSING" {
            print("❌ Weather API key is not configured properly")
            return false
        }
        
        print("✅ Configuration validation passed")
        return true
    }
}
#endif
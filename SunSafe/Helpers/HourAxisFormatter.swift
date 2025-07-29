import Charts
import DGCharts

/// Форматтер для оси X графика: преобразует индексы в подписи вида '6h', '7h', ... '22h'.
/// Используется для почасовой шкалы на графике UV.
final class HourAxisFormatter: IndexAxisValueFormatter {

    /// Подписи для оси X: массив строк с часами ("6h", "7h" и т.д.)
    private let labels: [String]

    /// Инициализирует форматтер для диапазона часов (по умолчанию 6-22).
    init(startHour: Int = 6, endHour: Int = 20) {
        self.labels = (startHour...endHour).map { "\($0)h" }
        super.init(values: labels)
    }

    /// Формирует строку для отображения часа в формате 'HH:00' по X-координате графика.
    /// - Parameters:
    ///   - x: Индекс значения на оси X.
    ///   - startHour: Начальный час (по умолчанию 6).
    /// - Returns: Строка вида '07:00', '08:00' и т.д.
    static func display(for x: Double, startHour: Int = 6) -> String {
        let hour = Int(x) + startHour
        return String(format: "%02d:00", hour)
    }
}

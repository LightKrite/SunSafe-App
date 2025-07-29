import Charts
import DGCharts

/// Форматирует подписи оси X: «6h», «7h», … «22h».
final class HourAxisFormatter: IndexAxisValueFormatter {

    private let labels: [String]

    init(startHour: Int = 6, endHour: Int = 22) {
        self.labels = (startHour...endHour).map { "\($0)h" }
        super.init(values: labels)
    }

    /// Удобно для маркера («14:00» и т.д.)
    static func display(for x: Double, startHour: Int = 6) -> String {
        let hour = Int(x) + startHour
        return String(format: "%02d:00", hour)
    }
}

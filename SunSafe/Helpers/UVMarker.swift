import UIKit
import Charts
import DGCharts

/// Кастомное всплывающее окно для графика UV: отображает время и значение UV для выбранной точки.
final class UVMarker: MarkerView {

    /// Метка для отображения времени (час)
    private let timeLabel = UILabel()
    /// Метка для отображения значения UV-индекса
    private let uvLabel   = UILabel()

    /// Инициализация и настройка внешнего вида маркера
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.shadowOpacity = 0.15
        layer.shadowRadius  = 3
        layer.shadowOffset  = .init(width: 0, height: 2)

        timeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        uvLabel.font   = .systemFont(ofSize: 12, weight: .regular)

        [timeLabel, uvLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            uvLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            uvLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            uvLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }

    /// Не используется (создание через storyboard не поддерживается)
    required init?(coder: NSCoder) { fatalError() }

    /// Обновляет содержимое маркера при выделении новой точки на графике
    /// - Parameters:
    ///   - entry: Текущая выбранная точка
    ///   - highlight: Информация о выделении
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        timeLabel.text = HourAxisFormatter.display(for: entry.x)
        uvLabel.text   = "UV \(Int(entry.y))"
        layoutIfNeeded()
    }

    /// Смещает маркер так, чтобы он появлялся над выделенной точкой
    /// - Parameter point: Координата точки
    /// - Returns: Смещение для корректного отображения
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        CGPoint(x: -bounds.width/2, y: -bounds.height - 8)
    }
}


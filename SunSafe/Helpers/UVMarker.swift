import UIKit
import Charts
import DGCharts

/// Кастомное всплывающее окно для графика UV: отображает время и значение UV для выбранной точки.
final class UVMarker: MarkerView {

    /// Метка для отображения времени (час)
    private let timeLabel = UILabel()
    /// Метка для отображения значения UV-индекса
    private let uvLabel   = UILabel()
    
    private let horizontalPadding: CGFloat = 16

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

        addSubview(timeLabel)
        addSubview(uvLabel)
    }

    /// Не используется (создание через storyboard не поддерживается)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Расположение timeLabel: центр сверху с отступом 6
        let timeSize = timeLabel.intrinsicContentSize
        timeLabel.frame = CGRect(
            x: (bounds.width - timeSize.width) / 2,
            y: 6,
            width: timeSize.width,
            height: timeSize.height
        )
        
        // Расположение uvLabel: центр под timeLabel с отступом 2
        let uvSize = uvLabel.intrinsicContentSize
        uvLabel.frame = CGRect(
            x: (bounds.width - uvSize.width) / 2,
            y: timeLabel.frame.maxY + 2,
            width: uvSize.width,
            height: uvSize.height
        )
    }

    /// Обновляет содержимое маркера при выделении новой точки на графике
    /// - Parameters:
    ///   - entry: Текущая выбранная точка
    ///   - highlight: Информация о выделении
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        timeLabel.text = HourAxisFormatter.display(for: entry.x)
        uvLabel.text   = "UV \(Int(entry.y))"
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        self.frame.size.height = 6 + timeLabel.intrinsicContentSize.height + 2 + uvLabel.intrinsicContentSize.height + 6
    }

    /// Смещает маркер так, чтобы он появлялся над выделенной точкой
    /// - Parameter point: Координата точки
    /// - Returns: Смещение для корректного отображения
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        CGPoint(x: -bounds.width/2, y: -bounds.height - 8)
    }
    
    override var intrinsicContentSize: CGSize {
        let timeWidth = timeLabel.intrinsicContentSize.width
        let uvWidth = uvLabel.intrinsicContentSize.width
        let dynamicWidth = max(timeWidth, uvWidth) + horizontalPadding * 2
        let width = max(80, dynamicWidth) // минимум 80

        let timeHeight = timeLabel.intrinsicContentSize.height
        let uvHeight = uvLabel.intrinsicContentSize.height
        let height = 6 + timeHeight + 2 + uvHeight + 6

        return CGSize(width: width, height: height)
    }
}

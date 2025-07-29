import UIKit
import Charts
import DGCharts

final class UVMarker: MarkerView {

    private let timeLabel = UILabel()
    private let uvLabel   = UILabel()

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

    required init?(coder: NSCoder) { fatalError() }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        timeLabel.text = HourAxisFormatter.display(for: entry.x)
        uvLabel.text   = "UV \(Int(entry.y))"
        layoutIfNeeded()
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        CGPoint(x: -bounds.width/2, y: -bounds.height - 8)
    }
}

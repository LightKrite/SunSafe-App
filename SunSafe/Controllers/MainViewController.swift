import UIKit
import DGCharts
import Charts

/// Основной экран: показывает текущую погоду, UV индекс и график почасового UV-прогноза.
class MainViewController: UIViewController {

    /// ViewModel для управления данными и бизнес-логикой
    private let viewModel = MainViewModel()
    private let weatherCache = WeatherCacheManager()

    /// Метка для отображения температуры
    private let temperatureLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textAlignment = .center
        l.text = "--°C"
        return l
    }()

    /// Метка для отображения погодного описания
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .medium)
        l.textAlignment = .center
        l.text = "Описание"
        return l
    }()

    /// Метка для отображения UV индекса
    private let uvIndexLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .regular)
        l.textAlignment = .center
        l.text = "UV: --"
        return l
    }()

    /// Индикатор загрузки данных
    private let loader: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.hidesWhenStopped = true
        ind.color = .gray
        return ind
    }()

    /// График UV‑индекса (BarChartView вместо LineChartView)
    private let chartView: BarChartView = {
        let chart = BarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.chartDescription.enabled = false
        chart.legend.enabled = false
        chart.rightAxis.enabled = false                // только левая ось
        chart.leftAxis.axisMinimum = 0
        chart.leftAxis.axisMaximum = 12
        chart.xAxis.labelPosition = .bottom
        return chart
    }()

    /// Инициализация экрана и запуск загрузки данных
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupChartStyle()
        setupBinding()

        if let cachedForecast: ForecastResponse = weatherCache.load(ForecastResponse.self, for: .forecast) {
            let hourly = cachedForecast.forecast.forecastday.first?.hour ?? []
            viewModel.onForecastUpdate?(cachedForecast)
        } else {
            print("🔄 No valid forecast cache, loading from API")
        }
        if let cachedCurrent: WeatherResponse = weatherCache.load(WeatherResponse.self, for: .currentWeather) {
            self.temperatureLabel.text = "\(cachedCurrent.current.temp_c)°C"
            self.descriptionLabel.text = cachedCurrent.current.condition.text
            self.uvIndexLabel.text = "UV: \(cachedCurrent.current.uv)"
        } else {
            print("🔄 No valid current weather cache, loading from API")
        }

        showLoader()
        viewModel.fetchWeather()
        viewModel.fetchForecast()
    }

    /// Настраивает расположение UI-элементов
    private func setupLayout() {
        [temperatureLabel, descriptionLabel, uvIndexLabel, loader].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            temperatureLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 16),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            uvIndexLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            uvIndexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        view.addSubview(chartView)
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    /// Настраивает визуальный стиль графика
    private func setupChartStyle() {
        // Оси
        let x = chartView.xAxis
        x.drawGridLinesEnabled = false
        x.labelFont = .systemFont(ofSize: 11, weight: .medium)
        x.valueFormatter = HourAxisFormatter()         // «6h» … «22h»

        let y = chartView.leftAxis
        y.drawGridLinesEnabled = false
        y.labelFont = .systemFont(ofSize: 11, weight: .medium)
        y.labelCount = 4

        // Поведение
        chartView.doubleTapToZoomEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)

        // Кастомный маркер-тултип
        chartView.marker = UVMarker(frame: .zero)
        chartView.highlightPerTapEnabled = true
    }

    /// Привязывает обработчики обновления данных и ошибок от ViewModel
    private func setupBinding() {
        viewModel.onDataUpdate = { [weak self] weatherResponse in
            self?.temperatureLabel.text = "\(weatherResponse.current.temp_c)°C"
            self?.descriptionLabel.text = weatherResponse.current.condition.text
            self?.uvIndexLabel.text = "UV: \(weatherResponse.current.uv)"
            self?.weatherCache.save(weatherResponse, for: .currentWeather)
            self?.hideLoader()
        }

        viewModel.onError = { [weak self] msg in
            self?.hideLoader()
            self?.showAlert(title: "Ошибка", message: msg)
        }

        viewModel.onForecastUpdate = { [weak self] forecastResponse in
            let hourly = forecastResponse.forecast.forecastday.first?.hour ?? []
            let filtered = hourly.filter {
                let hour = Int($0.time.suffix(5).prefix(2)) ?? 0
                return hour >= 6 && hour <= 22
            }
            self?.weatherCache.save(forecastResponse, for: .forecast)
            self?.updateChart(with: filtered)
        }
    }

    /// Обновляет данные на графике UV-прогноза
    private func updateChart(with data: [HourForecast]) {
        let entries: [BarChartDataEntry] = data.enumerated().map { idx, item in
            BarChartDataEntry(x: Double(idx), y: item.uv)
        }

        let dataSet = BarChartDataSet(entries: entries, label: "")
        dataSet.drawValuesEnabled = false
        dataSet.highlightEnabled  = true
        dataSet.barShadowColor    = .clear
        dataSet.barBorderWidth    = 0

        // Цвет по градиенту: 0 — зелёный, 12 — бордово-красный
        dataSet.colors = data.map { hour in
            Self.color(forUV: hour.uv)
        }

        let chartData = BarChartData(dataSet: dataSet)
        chartData.barWidth = 0.85

        chartView.data = chartData
        chartView.animate(yAxisDuration: 0.8, easingOption: .easeOutCubic)
    }

    /// Показывает индикатор загрузки
    private func showLoader() { loader.startAnimating() }
    /// Скрывает индикатор загрузки
    private func hideLoader() { loader.stopAnimating() }

    /// Показывает всплывающее сообщение об ошибке
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    /// Генерирует цвет по градиенту от зелёного (0) до бордово-красного (12)
    private static func color(forUV uv: Double) -> UIColor {
        let clampedUV = min(max(uv, 0), 12)
        let t = CGFloat(clampedUV / 12.0)
        // Цвета: зелёный → жёлтый → оранжевый → красный → бордово-красный
        // Ключевые точки: 0, 3, 6, 9, 12
        let colors: [UIColor] = [
            UIColor.systemGreen,
            UIColor.systemYellow,
            UIColor.systemOrange,
            UIColor.systemRed,
            UIColor(red: 0.5, green: 0, blue: 0, alpha: 1) // бордово-красный
        ]
        let stops: [CGFloat] = [0, 0.25, 0.5, 0.75, 1]
        // Находим между какими двумя ключевыми точками находится t
        for i in 1..<stops.count {
            if t <= stops[i] {
                let t0 = stops[i-1]
                let t1 = stops[i]
                let localT = (t - t0) / (t1 - t0)
                return blend(colors[i-1], colors[i], fraction: localT)
            }
        }
        return colors.last!
    }
    /// Линейная интерполяция двух цветов
    private static func blend(_ c1: UIColor, _ c2: UIColor, fraction: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let r = r1 + (r2 - r1) * fraction
        let g = g1 + (g2 - g1) * fraction
        let b = b1 + (b2 - b1) * fraction
        let a = a1 + (a2 - a1) * fraction
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

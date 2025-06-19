import UIKit
import DGCharts
import Charts

class MainViewController: UIViewController {

    private let viewModel = MainViewModel()

    private let temperatureLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textAlignment = .center
        l.text = "--°C"
        return l
    }()

    
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .medium)
        l.textAlignment = .center
        l.text = "Описание"
        return l
    }()

    private let uvIndexLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .regular)
        l.textAlignment = .center
        l.text = "UV: --"
        return l
    }()

    private let loader: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.hidesWhenStopped = true
        ind.color = .gray
        return ind
    }()

    // MARK: – график
    private let chartView: LineChartView = {
        let chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.chartDescription.enabled = false
        chart.legend.enabled = false
        chart.rightAxis.enabled = false                // только левая ось
        chart.leftAxis.axisMinimum = 0
        chart.leftAxis.axisMaximum = 11
        chart.xAxis.labelPosition = .bottom
        return chart
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupChartStyle()
        setupBinding()

        showLoader()
        viewModel.fetchWeather()
        viewModel.fetchForecast()
    }

    // MARK: – UI Layout
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

    // MARK: – Chart look & feel
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
        chartView.marker = UVMarker(frame: CGRect(x: 0, y: 0, width: 80, height: 44))
        chartView.highlightPerTapEnabled = true
    }

    // MARK: – Binding
    private func setupBinding() {
        viewModel.onDataUpdate = { [weak self] temperature, condition, uv in
            self?.temperatureLabel.text = temperature
            self?.descriptionLabel.text = condition
            self?.uvIndexLabel.text = uv
            self?.hideLoader()
        }

        viewModel.onError = { [weak self] msg in
            self?.hideLoader()
            self?.showAlert(title: "Ошибка", message: msg)
        }

        viewModel.onForecastUpdate = { [weak self] hourly in
            let filtered = hourly.filter {
                let hour = Int($0.time.suffix(5).prefix(2)) ?? 0
                return hour >= 6 && hour <= 22
            }
            self?.updateChart(with: filtered)
        }
    }

    // MARK: – Chart data
    private func updateChart(with data: [HourForecast]) {

        let entries = data.enumerated().map { idx, item in
            ChartDataEntry(x: Double(idx), y: item.uv)
        }

        let dataSet = LineChartDataSet(entries: entries, label: "")
        dataSet.mode               = .cubicBezier
        dataSet.lineWidth          = 2
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled  = false
        dataSet.setColor(UIColor.label)

        // градиент-заливка
        let colors = [UIColor.systemGreen.cgColor,
                      UIColor.systemYellow.cgColor,
                      UIColor.systemRed.cgColor]

        if let gradient = CGGradient(colorsSpace: nil,
                                     colors: colors as CFArray,
                                     locations: [0, 0.25, 1]) {

            // 2. Создаём *конкретный* Fill
            let gradientFill = LinearGradientFill(gradient: gradient, angle: 90)

            // 3. Применяем к датасету
            dataSet.fill              = gradientFill   // ✅ теперь тип совпадает
            dataSet.drawFilledEnabled = true
            dataSet.fillAlpha         = 1
        }

        chartView.data = LineChartData(dataSet: dataSet)
        chartView.animate(xAxisDuration: 0.6)
    }

    // MARK: – UX helpers
    private func showLoader() { loader.startAnimating() }
    private func hideLoader() { loader.stopAnimating() }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

import UIKit

class MainViewController: UIViewController {

    private let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // Пример иконки (можно заменить на сетевую)
        imageView.image = UIImage(systemName: "sun.max.fill")
        imageView.tintColor = .systemYellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.text = "+23°C"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.text = "Ясно, солнечно"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let uvIndexLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "UV-индекс: 8 (Очень высокий)"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let adviceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .systemRed
        label.text = "☀️ Сегодня рекомендуется использовать SPF!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(weatherIconImageView)
        view.addSubview(temperatureLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(uvIndexLabel)
        view.addSubview(adviceLabel)
        
        NSLayoutConstraint.activate([
            weatherIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 90),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 90),
            
            temperatureLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 20),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            uvIndexLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 28),
            uvIndexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            adviceLabel.topAnchor.constraint(equalTo: uvIndexLabel.bottomAnchor, constant: 24),
            adviceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            adviceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
}


//
//  ViewController.swift
//  WeatherApplication
//
//  Created by jhchoi on 2023/06/13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var firstCityName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func firstButton(_ sender: UIButton) {
        
        if let firstCityName = self.firstCityName.text {
            self.getWeather(cityName: firstCityName)
        }
    }
    
    func getWeather(cityName: String) {
        let apiKey = "a8c1d55d8c112dbe5f0576f243f507ac"
        
        var components = URLComponents()
        
        let scheme = "https"
        let host = "api.openweathermap.org"
        
        components.scheme = scheme
        components.host = host
        components.path = "/data/2.5/weather"
        components.queryItems = [URLQueryItem(name: "q", value: cityName), URLQueryItem(name: "appid", value: apiKey)]
        
        let url = components.url!
        
        var request = URLRequest(url: url)
        
        let session = URLSession(configuration: .default)
    
        guard let resultViewController = self.storyboard?.instantiateViewController(identifier: "ResultViewController") as? ResultViewController else {return}
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            guard let weatherModel = try? decoder.decode(WeatherModel.self, from: data) else { return }
            // debugPrint(weatherModel)
            guard let weatherDictionary = self.encodeModelToDictionary(model: weatherModel) else { return }
            resultViewController.weatherInfo = weatherDictionary
            debugPrint(weatherDictionary)
            // 메인 스레드에서 작업
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(resultViewController, animated: true)
            }
        }.resume()
    }
    
    func encodeModelToDictionary<T: Codable>(model: T) -> [String: Any]? {
        guard let jsonData = try? JSONEncoder().encode(model) else {
               return nil
           }
        guard let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else {
               return nil
           }
        return dictionary
    }
}


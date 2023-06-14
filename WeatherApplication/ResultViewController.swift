//
//  ResultViewController.swift
//  WeatherApplication
//
//  Created by jhchoi on 2023/06/13.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    var weatherInfo: [String:Any]?
    
    var weatherKeys: [String] = []
    var weatherValues: [Any] = []
    
    var mainDict: [String: Any] = [:]
    var windDict: [String: Any] = [:]
    var weatherDict: [String: Any] = [:]
    var coordDict: [String: Any] = [:]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherKeyValue()
        resultTableView.dataSource = self
        
        cityNameLabel.text = weatherInfo?["name"] as? String
        
        if let temp = mainDict["temp"] as? Double {
            tempLabel.text = "\(String(temp))°F"
        } else {
            tempLabel.text = nil
        }
        
        descriptionLabel.text = weatherDict["description"] as? String
        
        if let minTemp = mainDict["temp_min"] as? Double {
            minTempLabel.text = "H:" + String(minTemp) + "°F"
        } else {
            minTempLabel.text = nil
        }
        
        if let maxTemp = mainDict["temp_max"] as? Double {
            maxTempLabel.text = "L:" + String(maxTemp) + "°F"
        } else {
            maxTempLabel.text = nil
        }
        
        if let icon = weatherDict["icon"] as? String {
            getWeatherImage(icon: icon) { image in
                self.iconImageView.image = image
            }
        }
    }
    
    func getWeatherKeyValue() {
        if let weatherInfo = weatherInfo {
            for (key, value) in weatherInfo {
                weatherKeys.append(key)
                weatherValues.append(value)
            }
        }
        
        if let dictionary = weatherInfo,
           let mainDictionary = dictionary["main"] as? [String: Any],
           let windDictionary = dictionary["wind"] as? [String: Any],
           let weatherArray = dictionary["weather"] as? [Any],
           let weatherDictionary = weatherArray.first as? [String: Any],
           let coordDictionary = dictionary["coord"] as? [String: Any] {
            mainDict = mainDictionary
            windDict = windDictionary
            coordDict = coordDictionary
            var weatherValues: [String: Any] = [:]
                for (key, value) in weatherDictionary {
                    weatherValues[key] = value
                }
            weatherDict = weatherValues
        }
    }
    
    func getWeatherImage(icon: String, closure: @escaping (UIImage) -> Void) {
        // https://openweathermap.org/img/wn/10d@2x.png
        
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") else { return }
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else { return }
            
            DispatchQueue.main.async {
                 closure(image)
            }
        }.resume()
    }
}

extension ResultViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return weatherKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionKey = weatherKeys[section]
        
        switch sectionKey {
        case "name":
            return 1
        case "coord":
            return coordDict.keys.count
        case "wind":
            return windDict.keys.count
        case "weather":
            return weatherDict.keys.count
        case "main":
            return mainDict.keys.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let sectionKey = weatherKeys[indexPath.section]
        
        if sectionKey == "name", let sectionData = weatherInfo?[sectionKey] {
            cell.textLabel?.text = "\(sectionData)"
        } else if sectionKey == "coord" {
            if indexPath.row == 0, let lat = coordDict["lat"] as? Double {
                cell.textLabel?.text = "위도 : \(lat)"
            } else if indexPath.row == 1, let lon = coordDict["lon"] as? Double {
                cell.textLabel?.text = "경도 : \(lon)"
            }
        } else if sectionKey == "wind" {
            if indexPath.row == 0, let speed = windDict["speed"] as? Double {
                cell.textLabel?.text = "풍속 : \(speed)"
            } else if indexPath.row == 1, let deg = windDict["deg"] as? Int {
                cell.textLabel?.text = "바람의 방향 : \(deg)"
            }
        } else if sectionKey == "weather" {
            if indexPath.row == 0, let id = weatherDict["id"] as? Int {
                cell.textLabel?.text = "id : \(id)"
            } else if indexPath.row == 1, let main = weatherDict["main"] as? String {
                cell.textLabel?.text = "주요 날씨 : \(main)"
            } else if indexPath.row == 2, let description = weatherDict["description"] as? String {
                cell.textLabel?.text = "날씨 요약 : \(description)"
            } else if indexPath.row == 3, let icon = weatherDict["icon"] as? String {
                cell.textLabel?.text = "아이콘 : \(icon)"
            }
        } else {
            if indexPath.row == 0, let temp = mainDict["temp"] as? Double {
                cell.textLabel?.text = "현재 온도 : \(temp)"
            } else if indexPath.row == 1, let feelsLike = mainDict["feels_like"] as? Double {
                cell.textLabel?.text = "체감 온도 : \(feelsLike)"
            } else if indexPath.row == 2, let minTemp = mainDict["temp_min"] as? Double {
                cell.textLabel?.text = "최저 기온 : \(minTemp)"
            } else if indexPath.row == 3, let maxTemp = mainDict["temp_max"] as? Double {
                cell.textLabel?.text = "최고 기온 : \(maxTemp)"
            } else if indexPath.row == 4, let humidity = mainDict["humidity"] as? Int {
                cell.textLabel?.text = "습도 : \(humidity)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionKey = weatherKeys[section]
        
        switch sectionKey {
        case "name":
            return "지명"
        case "coord":
            return "위치 정보"
        case "wind":
            return "바람"
        case "weather":
            return "날씨 정보"
        case "main":
            return "온도 및 습도"
        default:
            return "비어 있는 값"
        }
    }
}

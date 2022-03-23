//
//  ViewController.swift
//  weatherDemoStarter
//
//  Created by Rabia on 2022-03-16.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var fahrenheitButton: UIButton!
    let locationManager = CLLocationManager()
    var imageName: String!
    var imageCode: Int!
    var config: UIImage.SymbolConfiguration!
    var Celsius: String!
    var Fahrenheit: String!
    var configCelsius: UIButton.Configuration!
    var configFahreheit: UIButton.Configuration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        locationManager.delegate = self
    }
    
    @IBAction func onCelsiusClick(_ sender: UIButton) {
        self.temperatureLabel.text = Celsius
        celsiusButtonConfig()
            
     
        
    }
    @IBAction func onFahrenheitClick(_ sender: UIButton) {
        if ( Fahrenheit != nil){
        self.temperatureLabel.text = Fahrenheit
        } else {
            self.temperatureLabel.text = "Temp"
        }
        configFahreheit = UIButton.Configuration.filled()
        configFahreheit.title = "F"
        sender.configuration = configFahreheit
        
        configCelsius = UIButton.Configuration.tinted()
        configCelsius.title = "C"
        celsiusButton.configuration = configCelsius
                  
    }
    
    func celsiusButtonConfig(){
        configFahreheit = UIButton.Configuration.tinted()
        configFahreheit.title = "F"
        fahrenheitButton.configuration = configFahreheit
        
        configCelsius = UIButton.Configuration.filled()
        configCelsius.title = "C"
        celsiusButton.configuration = configCelsius
    }
    
    func getImageName(imageCode: Int) -> String {
        
        switch imageCode{
        case 1000: imageName = "sun.max"
        case 1003,1009,1030: imageName = "cloud.sun.fill"
        case 1006: imageName = "cloud.fill"
        case 1063,1072,1153,1150,1069,1168,1171,1180,1183,1189,1195,1198,1201,1204,1207,1240,1243,1246,1249,1252:
            imageName = "cloud.drizzle.fill"
        case 1066,1114,1210,1213,1216,1219,1222,1225,1255,1258,1261,1264: imageName = "cloud.snow"
        case 1087,1276,1279,1282: imageName = "cloud.bolt.fill"
        case 1135,1147: imageName = "cloud.fog.fill"
        default: imageName = "cloud.sun"
            
        }
        return imageName
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        print(textField.text ?? "")
        getWeather(search: searchTextField.text!)
        return true
    }

    @IBAction func onSearchTapped(_ sender: UIButton) {
        searchTextField.endEditing(true)
        print("location on tapped \(searchTextField.text!)")
        getWeather(search: searchTextField.text!)
    }
    
    @IBAction func onLocationTapped(_ sender: UIButton) {
       // displayLocation(location: "London")
        searchTextField.text = ""
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
       }
    
    
    private func getWeather(search: String?)
    {
        guard let search = search else {
        return
    }
        // step 1: get url
        let url = getUrl(search: search)
        
        guard let url = url else {
            print("could not get URL")
            return
        }
        
        // step 2: session create
        let session = URLSession.shared
        
        // step 3: task for session
        let dataTask = session.dataTask(with: url) { data, response, error in
            // network call
            print("network call finished")
            
            guard error == nil else {
                print("received error")
                return
            }
            guard let data = data else {
                print("no data found")
                return
            }
            
            if let weather = self.parseJson(data: data){
                print("loaction name \(weather.location.name)")
               
                DispatchQueue.main.async {
                    self.locationLabel.text = weather.location.name
                    self.temperatureLabel.text = "\(weather.current.temp_c)"
                    self.celsiusButtonConfig()
                    
                    self.Celsius = "\(weather.current.temp_c)"
                    self.Fahrenheit = "\(weather.current.temp_f)"
                    self.conditionLabel.text = weather.current.condition.text
                    self.imageCode = weather.current.condition.code
                    self.imageName = self.getImageName(imageCode: self.imageCode)
                   if (self.imageCode == 1000){
                        self.config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemBlue, .systemTeal])
                   } else {
                       self.config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow, .systemTeal])
                   }
                    self.weatherImage.preferredSymbolConfiguration  = self.config
                    //print("image name is \(self.imageName)")
                    self.weatherImage.image = UIImage(systemName: self.imageName)
                }
             
            }
        }
        
        // step 4: start the task
        dataTask.resume()
        
}
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weatherResponse: WeatherResponse?
        
        do {
            weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
        } catch{
            print("error passing weather ")
            print(error)
        }
         return weatherResponse
    }
    
    private func getUrl(search: String) -> URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndPoint = "current.json"
        let apiKey = "e827954f67964bbbb0a210314221603"
        let search = search.trimmingCharacters(in: .whitespaces)
 
        let url = "\(baseUrl)\(currentEndPoint)?key=\(apiKey)&q=\(search)"
        print(url)
        return URL(string: url)

    }
    
    private func displayLocation(location: String){
        print("current location lat and long \(location)")
        getWeather(search: location)
         
     }
}

struct WeatherResponse : Decodable{
    let location: Location
    let current: Weather
}

struct Location: Decodable {
    let name: String
}

struct Weather: Decodable{
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}


extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            print("got location")
            if let location = locations.last {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                print("location latitude is: \(latitude) and longitude \(longitude)")
                self.displayLocation(location: "\(latitude),\(longitude)")
                
            }
        }
        
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
        }
    
}


//
//  ViewController.swift
//  Hot
//
//  Created by Manasi Ganti on 8/11/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        mapView.delegate = self
        
        /*
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322)
        annotation.title = "hi"
        annotation.subtitle = "test"
        mapView.addAnnotation(annotation)
        */
        
        let region=MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322), latitudinalMeters: 400000,longitudinalMeters: 1240000)
        mapView.setRegion(region, animated: true)
        
        
        
        
        guard let url = URL(string: "https://www.fire.ca.gov/umbraco/Api/IncidentApi/GetIncidents") else
        {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.addValue("your_api_key", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.httpBody = payload

        URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let data = data else { print("Empty data"); return }

            // Incidents: [{"Name", "Latitude", "longigude", "IsActive",}, {} , ...]
         /*   if let dictionary = jsonWithObjectRoot as? [String: Any] {
                if let incidents = dictionary["Incidents"] as? Double {
                    // access individual value in dictionary
                }

                for (key, value) in dictionary {
                    // access all key / value pairs in dictionary
                } */
            if var str = String(data: data, encoding: .utf8) {
                //print(str)
                let currentindex = str.range(of: "AllYearIncidents")
               // print(currentindex)
               // var datastring = str.substring(with: currentindex!)
                var datastring = String(str[..<currentindex!.lowerBound])
                //print(datastring)
                var array = datastring.components(separatedBy: "},{")
                let str1 = array[0]
                //print(str1)
                //let startIndex = str1.firstIndex(of: "[")!
                let startIndex = str1.startIndex
                let cutIndex = str1.index(startIndex, offsetBy: 15)
                //let endCutIndex = str1.index(
                array[0] = (String)(str1[cutIndex..<str1.endIndex])
                //print(array[0])
                
                
                for incident in array{
                    var fields = incident.components(separatedBy: ",");
                    //print(incident)
                    var latitude = 0.0
                    var longitude = 0.0
                    var name = ""
                    var description = ""
                    
                    for key_value in fields {
                        var pair = key_value.components(separatedBy: ":");
                      //  print(pair)
                        //pair[1] = self.cutQuotes(str: pair[1])
                        if pair[0] == "\"Name\"" {
                            name = self.cutQuotes(str: pair[1])
                            //print("NAME" + name)
                            //name = pair[1]
                            //name = (String)(pair[1][quoteIndexStart..<quoteIndexEnd])
                            // name = pair[1].components(separatedBy: "\"")[0]

                        }
                        if pair[0] == "\"Latitude\"" {
                            latitude = (Double)(pair[1])!
                        }
                        if pair[0] == "\"Longitude\"" {
                            longitude = (Double)(pair[1])!
                        }
                        if pair[0] == "\"Location\"" {
                            description += self.cutQuotes(str: pair[1]) + "\n"
                            //description += pair[1] + "\n"
                        }
                        if pair[0] == "\"AcresBurned\"" && pair[1] != "null" {
                            description += "Acres: " + self.cutQuotes(str: pair[1]) + "\n"
                            //description += pair[1] + "\n"
                        }
                        if pair[0] == "\"PercentContained\"" && pair[1] != "null" {
                            description += "Contained: " + self.cutQuotes(str: pair[1]) + "\n"
                            //description += pair[1] + "\n"
                        }
                        if pair[0] == "\"Started\"" {
                            //description += self.cutQuotes(str: pair[1])
                            //description += pair[1] + "\n"
                        }
                        if pair[0] == "\"Active\"" && pair[1] == "true" {
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            annotation.title = name
                            annotation.subtitle = description
                            self.mapView.addAnnotation(annotation)
                            //print("ANNOTATION")
                            break
                        }
                        
                    }
                }
                
            }
 
        }.resume()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        annotationView.markerTintColor = UIColor(red: (251.0/255), green: (112.0/255), blue: (92.0/255), alpha: 1.0)
        annotationView.glyphImage = UIImage(named: "fireicon")
        annotationView.glyphTintColor = UIColor(red: (250.0/255), green: (240.0/255), blue: (228.0/255), alpha: 1.0)
    //    annotationView.markerTintColor = UIColor.blue
        return annotationView
    }
    
    func cutQuotes(str:String ) -> String{
        
        let quoteIndexStart:String.Index;
        let quoteIndexEnd:String.Index;
        if(str.contains("\"")){
            quoteIndexStart = str.index(str.firstIndex(of: "\"")!, offsetBy: 1)
            if (str.lastIndex(of: "\"") != str.startIndex){
                quoteIndexEnd = str.lastIndex(of: "\"")!
            }
            else{
                quoteIndexEnd = str.endIndex
            }
        }
        else {
            quoteIndexStart = str.startIndex
            quoteIndexEnd = str.endIndex
        }
        var newStr = (String)(str.prefix(upTo: quoteIndexEnd))//(str[..<quoteIndexEnd])
        newStr = String(newStr.suffix(from: quoteIndexStart))//(String)(str[quoteIndexStart<..])
        return newStr
    }
 
    
}
/* struct Response: Decodable {
    var incidents: [Array]<Incident>?
}

struct Incident: Decodable {
    var unique_id: String?
    var name:String?
    var location: String?
    var latitude: String?
    var longitude: String?
    var acres_burned: Int?
    var fuel_type: String?
    var percent_contained: Int?
    var control_statement: String?
    var condition_statement: String?


    

} */

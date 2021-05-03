//
//  ViewController.swift
//  places-autocomplete-swift-uikit
//
//  Created by Andrew Vo-Nguyen on 29/4/21.
//
//


import UIKit
import GooglePlaces

class ViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var TextField: UITextField!
  
  override func viewDidLoad() {
    // Get API key from api-keys.plist
    guard let filePath = Bundle.main.path(forResource: "api-keys", ofType: "plist") else {
          fatalError("Couldn't find file 'api-keys.plist'.")
        }
    let plist = NSDictionary(contentsOfFile: filePath)
    let value = plist?.object(forKey: "GOOGLE_PLACES") as? String
    // Set api key for google maps spi
    GMSPlacesClient.provideAPIKey(value!)
    // Set textfield delagate to self
    TextField.delegate = self
    // Add handler for onPress
    TextField.addTarget(self, action: #selector(textFieldPressHandler), for: UIControl.Event.touchDown)
  }

  // Intercept editing of text field and show google's autocomplete ui component
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      textFieldPressHandler()
      return false
  }
  
  // Present the Autocomplete view controller when the button is pressed.
  @objc func textFieldPressHandler() {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self

    // Specify the place data types to return.
    let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                UInt(GMSPlaceField.placeID.rawValue))
    autocompleteController.placeFields = fields

    // Specify a filter.
    let filter = GMSAutocompleteFilter()
    filter.type = .city
    
    autocompleteController.autocompleteFilter = filter

    // Display the autocomplete view controller.
    present(autocompleteController, animated: true, completion: nil)
  }
}

extension ViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    print("Place name: \(String(describing: place.name))")
    print("Place ID: \(String(describing: place.placeID))")
    print("Place attributions: \(String(describing: place.attributions))")
    
    TextField.text = place.name
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}

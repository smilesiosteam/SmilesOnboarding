//
//  CountriesListViewController.swift
//  
//
//  Created by Shahroze Zaheer on 01/07/2023.
//

import UIKit
import SmilesUtilities
import SmilesLanguageManager
import SmilesSharedServices

public protocol CountrySelectionDelegate: AnyObject {
    func didSelectCountry(_ country: CountryList)
}

public class CountriesListViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.layer.cornerRadius = 16
            headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            headerView.clipsToBounds = true
        }
    }
    @IBOutlet weak var crossButton: UIButton! {
        didSet {
            crossButton.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var searchView: UIView! {
        didSet {
            searchView.layer.borderWidth = 1
            searchView.layer.borderColor = .init(red: 206/255, green: 204/255, blue: 207/255, alpha: 1)
            searchView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.fontTextStyle = .smilesBody3
            searchTextField.placeholder = "selectCountry".localizedString
        }
    }
    
    var countriesList: CountryListResponse?
    public var countryList: [CountryList] = []
    public weak var delegate: CountrySelectionDelegate?
    public var showCountryCodeInList = true
    
    private var sections = [(title: String, countries: [CountryList])]()
    private var sectionTitles = [String]()
    private var filteredCountries = [CountryList]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        generateSections()
        if SmilesLanguageManager.shared.currentLanguage == .ar {
            searchTextField.textAlignment = .right
        }
    }
    
    @IBAction func crossBtnTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func generateSections() {
        // Clear the existing sections and section titles
        sections.removeAll()
        sectionTitles.removeAll()
        
        // Create a dictionary to group countries by their first letter
        var countriesDictionary: [String: [CountryList]] = [:]
        
        // Iterate through the countries list and group them by the first letter of their name
        var countriesLists: [CountryList] = []
        if let list = countriesList?.countryList {
            countriesLists = list
        } else {
            countriesLists = countryList
        }
        let countriesToUse = filteredCountries.isEmpty ? countriesLists : filteredCountries
        for country in countriesToUse {
            guard let firstLetter = country.countryName?.prefix(1).uppercased() else {
                continue
            }
            
            // Add the country to the corresponding array in the dictionary
            if var countries = countriesDictionary[String(firstLetter)] {
                countries.append(country)
                countriesDictionary[String(firstLetter)] = countries
            } else {
                countriesDictionary[String(firstLetter)] = [country]
            }
        }
        
        // Sort the keys of the dictionary to get the section titles in alphabetical order
        let sortedKeys = countriesDictionary.keys.sorted()
        
        // Create the sections array using the sorted keys
        for key in sortedKeys {
            guard let countries = countriesDictionary[key] else {
                continue
            }
            
            // Add the section title and the corresponding countries to the sections array
            sections.append((title: key, countries: countries))
            sectionTitles.append(key)
        }
        
        // Reload the table view to reflect the updated sections and data
        tableView.reloadData()
    }
}

extension CountriesListViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].countries.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath) as? CountryTableViewCell else {return UITableViewCell()}
        
        let country = sections[indexPath.section].countries[indexPath.row]
        cell.countryName.text = country.countryName
        cell.countryCode.text = "+" + (country.iddCode ?? "")
        cell.countryimage.sd_setImage(with: URL(string: country.flagIconUrl ?? ""))
        cell.countryCode.isHidden = !showCountryCodeInList
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = sections[indexPath.section].countries[indexPath.row]
        delegate?.didSelectCountry(country)
        self.dismiss(animated: true)
    }
}

extension CountriesListViewController: UITextFieldDelegate {
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        filterCountries(with: textField.text)
        generateSections()
        tableView.reloadData()
    }
    
    func filterCountries(with searchText: String?) {
        let sourceCountries = countriesList?.countryList ?? countryList
        
        if let text = searchText, !text.isEmpty {
            filteredCountries = sourceCountries.filter { $0.countryName.lowercased().contains(text.lowercased()) }
        } else {
            filteredCountries = sourceCountries
        }
        
        generateSections()
    }
}

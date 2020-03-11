//
//  DictionaryLoader.swift
//  nlumi
//
//  Created by Paulo Custódio on 25/02/2020.
//  Copyright © 2020 Paulo Custódio. All rights reserved.
//

import Foundation

//load data from json and turn it into my data structure on Dictionary.swift
public class DictionaryLoader {
    
    //store all the data that is retrieved from json file
    //@Published is an optional tag
    @Published var dictionary = [Dictionary]()
    
    //run our load & sort functions when our class DictionaryLoader is created
    init() {
        load()
        sort()
    }
    
    //load our data
    func load() {
        //access file location of local json file
        //if file is accessed code inside is run
        if let fileLocation = Bundle.main.url(forResource: "dictionary", withExtension: "json") {
            //run do catch in case of an error
            do {
                //try to get data from json file
                let data = try Data(contentsOf: fileLocation)
                //decode our json
                let jsonDecoder = JSONDecoder()
                //get data from json file using decoder
                let dataFromJson = try jsonDecoder.decode([Dictionary].self, from: data)
                //set it to out dictionary array (line 16)
                self.dictionary = dataFromJson
                print(data)
            } catch {
                print(error)
            }
        }
    }
    
    //sort our data
    func sort() {
        //sort by pt String field in ascending sequence (alphabetically) and ignore accents
        self.dictionary = self.dictionary.sorted { $0.pt.localizedCaseInsensitiveCompare($1.pt) == ComparisonResult.orderedAscending }
    }
    
}

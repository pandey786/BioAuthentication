//
//  DataModelClass.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 28/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import Foundation

class DataModelClass {
    static let  instance = DataModelClass()
    
    // -------------------------------------------------------------------------------------------------------------------------
    // getDocumentsDirectory
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as  NSString
        let plistPath = documentsDirectory.appendingPathComponent("data.plist")
        
        let fileManager = FileManager.default
        
        // Check if file exists
        if(!fileManager.fileExists(atPath: plistPath)) {
            let emptyArr:NSMutableArray = NSMutableArray()
            emptyArr.write(toFile: plistPath, atomically: true)
        }
        
        // Return Path
        return plistPath
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // saveDetailsOfPerson
    
    func saveDetailsOfPerson(guuid: String, nameStr:String) {
        // Get path
        let path:String = self.getDocumentsDirectory()
        
        let myDict:NSMutableDictionary = NSMutableDictionary()
        myDict.setValue(nameStr, forKey: "name")
        myDict.setValue(guuid, forKey: Constants.ValuesKey.identificationKey)
        
        // Get Array then save dict in that
        let myArr:NSMutableArray = NSMutableArray(contentsOfFile: path)!
        myArr.add(myDict)
        myArr.write(toFile: path, atomically: true)
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // saveUserAudio
    
    func saveUserAudio(guuid: String) {
        // Get path
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as  NSString
        let folderPath = documentsDirectory.appendingPathComponent("AudioFiles") as NSString
        
        let fileManager = FileManager.default
        
        // Check if file exists
        if(!fileManager.fileExists(atPath: folderPath as String)) {
            do {
                try FileManager.default.createDirectory(atPath: folderPath as String, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        
        let userIdFolder = folderPath.appendingPathComponent("\(guuid).wav")
                
        // Get the audio file
        let olderFile = documentsDirectory.appendingPathComponent("recording.wav")
        
        do {
            try FileManager.default.moveItem(atPath: olderFile, toPath: userIdFolder as String)
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // getUserAudio
    
    func getUserAudio(guuid: String) -> String {
        // Get path
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as  NSString
        let folderPath = documentsDirectory.appendingPathComponent("AudioFiles") as NSString
        let audioFilename = folderPath.appendingPathComponent("\(guuid).wav")
        
        return audioFilename
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // getEnrolledUsersList
    
    func getEnrolledUsersList() -> NSArray {
        let path:String = self.getDocumentsDirectory() as String
        let myArr:NSMutableArray = NSMutableArray(contentsOfFile: path)!
        
        // return list
        return myArr
    }
}

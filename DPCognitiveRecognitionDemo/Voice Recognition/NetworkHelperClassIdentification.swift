//
//  NetworkHelperClassIdentification.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 19/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import Foundation

class NetworkHelperClassIdentification:NSObject ,URLSessionDataDelegate {
    static let  instance = NetworkHelperClassIdentification()
    
    // ---------------------------------------------------------------------------------------------------------------------------------------
    // makeApiCall
    
    func makeApiCall(urlStr: String, content_type:String, methodType:String, className:String)  {
        // Create URl
        let url = URL(string: urlStr)
        let request = NSMutableURLRequest(url:url! as URL)
        request.httpMethod = methodType
        
        // Set Header
        request.setValue(content_type, forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.MicrosoftServiceKeys.key_one, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        // Check class type and set body
        if className == Constants.ApiClassesName.createIdentificationClass{
            // Body params
            let params:NSMutableDictionary = NSMutableDictionary()
            params.setValue("en-US", forKey: "locale")
            
            do {
                let serializeData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                request.httpBody = serializeData
            } catch {
                print("error in JSONSerialization")
            }
        }
        else if className == Constants.ApiClassesName.enrollIdentificationVoice || className == Constants.ApiClassesName.identifyVoice {
            
            // Get the audio file
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as  NSString
            let audioFilename = documentsDirectory.appendingPathComponent("recording.wav")
            
            // Convert it to NSData
            let myAudioData:NSData = NSData(contentsOfFile: audioFilename)!
            
            // Attach boundary
            let boundary = "--------14737809831466499882746641449----"
            let beginningBoundary = "--\(boundary)"
            let endingBoundary = "--\(boundary)--"
            
            // We could just use currentFilename if we wanted
            let header = "Content-Disposition: form-data; name=\"recording\"; filename=\"recording.wav\"\r\n"
            
            let body = NSMutableData()
            body.append(("\(beginningBoundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append((header as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append(("Content-Type: application/octet-stream \r\n\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            body.append(myAudioData as Data) // adding the recording here
            body.append(("\r\n\(endingBoundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
            
            request.addValue("\(body.length)", forHTTPHeaderField: "Content-Length")
            request.httpBody = body as Data
        }
        
        // Create session and call API
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil{
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            
            if className == Constants.ApiClassesName.enrollIdentificationVoice || className == Constants.ApiClassesName.identifyVoice {
                if let httpResponse = response as? HTTPURLResponse {
                    if let operationUrl = httpResponse.allHeaderFields["Operation-Location"] as? String {
                        // Call to get operation status
                        DispatchQueue.main.async {
                            self.operationStatus(urlStr: operationUrl)
                        }
                    }
                }
            }
            else{
                // Convert server json response to NSDictionary
                do {
                    if let convertedJsonDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        
                        // Create profile with name and image and GUID
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.createIdentificationProfileSuccess), object: convertedJsonDict)
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        
        // Task Start
        task.resume()
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // createProfile
    
    func createProfile() {
        let pathURl = Constants.MicrosoftServiceIdentificationApi.createProfileApi
        
        // Call method to make api call
        self.makeApiCall(urlStr: pathURl, content_type:"application/json", methodType: "POST", className: Constants.ApiClassesName.createIdentificationClass)
    }
    
    
    // -------------------------------------------------------------------------------------------------------------------------
    // enrollVoice
    
    func enrollVoice(_ guuid:String) {
        var pathURl = Constants.MicrosoftServiceIdentificationApi.enrollVoiceApi
        pathURl = pathURl.appending(guuid)
        pathURl = pathURl.appending("/enroll")
        
        let paramsArr:NSArray = [
            "shortAudio=true"
        ]
        let params:String = paramsArr.componentsJoined(by: "&")
        pathURl = pathURl.appending("?\(params)")
        
        let boundary = "--------14737809831466499882746641449----"
        let contentType = "multipart/form-data;boundary=\(boundary)"
        self.makeApiCall(urlStr: pathURl, content_type: contentType, methodType: "POST", className: Constants.ApiClassesName.enrollIdentificationVoice)
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // verifyVoice
    
    func verifyVoice(_ guuid:String) {
        var pathURl = Constants.MicrosoftServiceIdentificationApi.verifyVoiceApi
        let paramsArr:NSArray = [
            "identificationProfileIds=\(guuid)",
            "shortAudio=true"
        ]
        let params:String = paramsArr.componentsJoined(by: "&")
        pathURl = pathURl.appending("?\(params)")
        
        let boundary = "--------14737809831466499882746641449----"
        let contentType = "multipart/form-data;boundary=\(boundary)"
        self.makeApiCall(urlStr: pathURl, content_type: contentType, methodType: "POST", className: Constants.ApiClassesName.identifyVoice)
    }
    
    // -------------------------------------------------------------------------------------------------------------------------------------
    // operationStatus
    
    func operationStatus(urlStr:String)  {
        let myUrl = URL(string: urlStr)
        let request = NSMutableURLRequest(url:myUrl! as URL)
        request.httpMethod = "GET"
        
        // Set Header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.MicrosoftServiceKeys.key_one, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        // Make session call
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil{
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            
            // Convert server json response to NSDictionary
            do {
                let convertedJsonIntoArr: Any? = try JSONSerialization.jsonObject(with: data!, options: [])
                
                if convertedJsonIntoArr is NSDictionary {
                    let dictionaryVersion = convertedJsonIntoArr as! NSDictionary
                    var messg:String!
                    if dictionaryVersion["status"] != nil && dictionaryVersion["status"] as! String == "succeeded" {
                        if dictionaryVersion["processingResult"] != nil{
                            let processingResult:NSDictionary = dictionaryVersion["processingResult"] as! NSDictionary
                            if processingResult["enrollmentStatus"] != nil{
                                messg = processingResult["enrollmentStatus"] as! String
                                if messg != "Enrolled"{
                                    if let httpResponse = response as? HTTPURLResponse {
                                        let opurlStr = httpResponse.url
                                        self.operationStatus(urlStr: (opurlStr?.absoluteString)!)
                                    }
                                }
                                else if messg == "Enrolled"{
                                    DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.enrollIdentificationVoiceSuccess), object:messg)
                                    }
                                }
                            }
                            if processingResult["identifiedProfileId"] != nil{
                                messg = processingResult["identifiedProfileId"] as! String
                                
                                // Create profile with name and image and GUID
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.verifyVoiceForIdentificationSuccess), object:messg)
                                }
                            }
                        }
                    }
                    else{
                        if dictionaryVersion["status"] != nil{
                            messg = dictionaryVersion["status"] as! String
                            
                            if let httpResponse = response as? HTTPURLResponse {
                                let opurlStr = httpResponse.url
                                self.operationStatus(urlStr: (opurlStr?.absoluteString)!)
                            }
                        }
                        else if dictionaryVersion["error"] != nil{
                            DispatchQueue.main.async {
                                AlertHandler.instance.showInfoAlert(title: "API Limit Exceeded", message: "Please try again after 2 mins interval")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.apiLimitExceeded), object:nil)
                            }
                        }
                    }
                    /*DispatchQueue.main.async {
                     /*AlertHandler.instance.showInfoAlert(title: "Enrollment Status", message: messg)
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsName.enrollIdentificationVoiceSuccess), object:messg)*/
                    }*/
                }
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }
}

//
//  Constant.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 14/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import Foundation

struct Constants {
    struct MicrosoftServiceKeys {
        // Pragati
        static let key_one = "f5f0e175773540239fe92ab6419e4b1c"
        static let key_two = "0a5be7c8a9df4d169e275fa6fa6743c4"
        
        // Pragati II
       // static let key_one = "2ca9d204dd784a108ad929afadc8d902"
    }
    
    struct MicrosoftServiceApi {
        static let createProfileApi = "https://api.projectoxford.ai/spid/v1.0/verificationProfiles"
        static let getAllPhrasesApi = "https://api.projectoxford.ai/spid/v1.0/verificationPhrases?locale=en-US"
        static let enrollVoiceApi = "https://api.projectoxford.ai/spid/v1.0/verificationProfiles/"
        static let verifyVoiceApi = "https://api.projectoxford.ai/spid/v1.0/verify?verificationProfileId="
    }
    
    struct MicrosoftServiceIdentificationApi {
        static let createProfileApi = "https://api.projectoxford.ai/spid/v1.0/identificationProfiles"
        static let enrollVoiceApi = "https://api.projectoxford.ai/spid/v1.0/identificationProfiles/"
        static let verifyVoiceApi = "https://api.projectoxford.ai/spid/v1.0/identify"
    }
    
    struct NotificationsName {
        static let createVerificationProfileSuccess = "NotificationCreateVerificationProfileSuccess"
        static let getPhrasesSuccess = "NotificationGetPhrasesSuccess"
        static let enrollVerificationVoiceSuccess = "NotificationEnrollVerificationVoiceSuccess"
        static let createIdentificationProfileSuccess = "NotificationCreateIdentificationProfileSuccess"
        static let enrollIdentificationVoiceSuccess = "NotificationEnrollIdentificationVoiceSuccess"
        static let verifyVoiceForVerificationSuccess = "NotificationVerifyVoiceForVerificationSuccess"
        static let verifyVoiceForIdentificationSuccess = "NotificationverifyVoiceForIdentificationSuccess"
        static let apiLimitExceeded = "apiLimitExceeded"
    }
    
    struct ValuesKey {
        static let verificationKey = "verificationProfileId"
        static let identificationKey = "identificationProfileId"
    }
    
    struct NetworkConnectionKeys {
        static let contentType = "Content-Type"
        static let subscriptionKey = "Ocp-Apim-Subscription-Key"
    }
    
    struct ApiClassesName {
        static let createIdentificationClass = "createIdentificationClass"
        static let enrollIdentificationVoice = "enrollIdentificationVoice"
        static let identifyVoice = "identifyVoice"
    }

}

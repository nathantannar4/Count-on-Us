//
//  Constants.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import Foundation

/* TODO: Try struct format for constants */
struct Constants {
    struct PF {
        struct Installation {
            static let ClassName = "_Installation"
        }
    }
}

let DEFAULT_TAB							= 0


/* All */
let SAP_COLOR                           = UIColor(red: 7.0/255, green:67.0/255.0, blue:131.0/255, alpha: 1)
let OFFICES                             = ["Vancouver, Canada"]
let PF_CREATEDAT                        = "createdAt"               // Date
let PF_OBJECTID                         = "objectId"                // Pointer to User Class

/* Installation */
let PF_INSTALLATION_CLASS_NAME			= "_Installation"           //	Class name
let PF_INSTALLATION_OBJECTID			= "objectId"				//	String
let PF_INSTALLATION_USER				= "user"					//	Pointer to User Class

/* User */
let PF_USER_CLASS_NAME					= "_User"                   //	Class name
let PF_USER_OBJECTID					= "objectId"				//	String
let PF_USER_USERNAME					= "username"				//	String
let PF_USER_PASSWORD					= "password"				//	String
let PF_USER_EMAIL						= "email"                   //	String
let PF_USER_FULLNAME					= "fullname"				//	String
let PF_USER_FULLNAME_LOWER				= "fullname_lower"          //	String
let PF_USER_PICTURE						= "picture"                 //	File
let PF_USER_PHONE                       = "phone"                   //	String
let PF_USER_TITLE                       = "title"                   //	String
let PF_USER_OFFICE                      = "office"                  //	String
let PF_USER_INFO                        = "info"                    //	String

/* Business */
let PF_BUSINESS_NAME                    = "company"                 //  String
let PF_BUSINESS_WEBSITE                 = "companyWebsite"          //  String
let PF_BUSINESS_DEALDAY                 = "dealDay"                 //  Array
let PF_BUSINESS_STARTTIME               = "startTime"               //  Number
let PF_BUSINESS_ENDTIME                 = "endTime"                 //  Number
let PF_BUSINESS_PHONE                   = "phoneNumber"             //  String
let PF_BUSINESS_REVIEW                  = "reviewLink"              //  String
let PF_BUSINESS_LAT                     = "latitude"                //  String
let PF_BUSINESS_LONG                    = "longitude"               //  String
let PF_BUSINESS_INFO                    = "info"                    //  String
let PF_BUSINESS_MORE_INFO               = "additionalInfo"          //  String

/* Chat */
let PF_CHAT_CLASS_NAME					= "Chat"					//	Class name
let PF_CHAT_USER						= "user"					//	Pointer to User Class
let PF_CHAT_GROUPID						= "groupId"                 //	String
let PF_CHAT_TEXT						= "text"					//	String
let PF_CHAT_PICTURE						= "picture"                 //	File
let PF_CHAT_VIDEO						= "video"                   //	File
let PF_CHAT_CREATEDAT					= "createdAt"               //	Date

/* Groups */
let PF_GROUPS_CLASS_NAME				= "Groups"                  //	Class name
let PF_GROUPS_NAME                      = "name"					//	String

/* Messages*/
let PF_MESSAGES_CLASS_NAME				= "Messages"				//	Class name
let PF_MESSAGES_USER					= "user"					//	Pointer to User Class
let PF_MESSAGES_GROUPID					= "groupId"                 //	String
let PF_MESSAGES_DESCRIPTION				= "description"             //	String
let PF_MESSAGES_LASTUSER				= "lastUser"				//	Pointer to User Class
let PF_MESSAGES_LASTMESSAGE				= "lastMessage"             //	String
let PF_MESSAGES_COUNTER					= "counter"                 //	Number
let PF_MESSAGES_UPDATEDACTION			= "updatedAction"           //	Date

/* Notification */
let NOTIFICATION_APP_STARTED			= "NCAppStarted"
let NOTIFICATION_USER_LOGGED_IN			= "NCUserLoggedIn"
let NOTIFICATION_USER_LOGGED_OUT		= "NCUserLoggedOut"
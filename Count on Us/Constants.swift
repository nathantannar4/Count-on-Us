//
//  Constants.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

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
let VERSION = "BETA 1.05"
let MESSAGE_INVITE						= "Check out SwiftParseChat on GitHub: https://github.com/nathantannar4/WESST"
let WESST_COLOR                         = UIColor(red: 153.0/255, green:62.0/255.0, blue:123.0/255, alpha: 1)
let allSchools = ["University of Victoria", "UBC Vancouver", "UBC Okanagan", "SFU Burnaby", "SFU Surrey", "BCIT", "UNBC", "University of Calgary", "University of Alberta", "University of Saskatchewan", "University of Regina", "University of Manitoba"]
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
let PF_USER_EMAILCOPY					= "emailCopy"               //	String
let PF_USER_FULLNAME					= "fullname"				//	String
let PF_USER_FULLNAME_LOWER				= "fullname_lower"          //	String
let PF_USER_PICTURE						= "picture"                 //	File
let PF_USER_THUMBNAIL					= "thumbnail"               //	File
let PF_USER_RESUME                      = "resume"                  //	File
let PF_USER_PHONE                       = "phone"                   //	String
let PF_USER_TITLE                       = "title"                   //	String
let PF_USER_SCHOOL                      = "school"                  //	String
let PF_USER_INFO                        = "info"                    //	String
let PF_USER_GENDER                      = "gender"                  //	String
let PF_USER_BIRTHDAY                    = "birthday"                //	Date
let PF_USER_ADMIN                       = "admin"                   //  Array
let PF_USER_MASTER                      = "master"                  //  Bool
let PF_USER_YEAR                        = "year"                    //	String
let PF_USER_OPTION                      = "option"                  //	String
let PF_USER_WALKTHROUGH                 = "walkthrough"             //  Bool

/* Posts */
let POSTS_CLASS_NAME                     = "Posts"                   //  Class name


/* School */
let SCHOOL_COVER_IMAGE                  = "coverimage"              //  File
let SCHOOL_LOGO_IMAGE                   = "logoimage"               //  File
let SCHOOL_NAME                         = "name"                    //  String
let SCHOOL_INFO                         = "info"                    //  String
let SCHOOL_PHONE                        = "phone"                   //  String
let SCHOOL_GREEN                        = "green"                   //  Float
let SCHOOL_RED                          = "red"                   //  Float
let SCHOOL_BLUE                         = "blue"                   //  Float
let SCHOOL_URL                    = "url"                     //  String
let SCHOOL_ADDRESS                = "address"                 //  String
let SCHOOL_EMAIL                = "email"                 //  String

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
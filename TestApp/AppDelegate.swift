//
//  AppDelegate.swift
//  TestApp
//
//  Created by Uli Kusterer on 29.07.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		Swift.print( "Swift Test:" )
		Swift.print( TestfileStrings.faveNumber(42, 42.0009) )
		Swift.print( TestfileStrings.welcomeFormat("Sandy" as NSString) )
		Swift.print( TestfileStrings.welcomeToStrings )
		Swift.print( TestfileStrings.welcomeLoggedOut )
		Swift.print( "" )
		
		OCSTest.runObjCTest()
		
		NSApplication.shared().terminate(self)
	}
}


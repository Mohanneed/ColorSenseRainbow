//
//  WhiteSeeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-08-05.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class WhiteSeeker: Seeker {
    
    override init () {
        super.init()

        var error : NSError?
        
        var regex: NSRegularExpression?
        
        
        // Swift

        let commonSwiftRegex = "hite:\\s*" + swiftFloatColourConst + "\\s*,\\s*alpha:\\s*" + swiftAlphaConst + "\\s*\\)"
        
        do {
            regex = try NSRegularExpression ( pattern: "(?:NS|UI)Color" + swiftInit + "\\s*\\(\\s*w" + commonSwiftRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift White float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            regex = try NSRegularExpression ( pattern: "NSColor" + swiftInit + "\\s*\\(\\s*(?:calibrated|device|genericGamma22)W" + commonSwiftRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Swift NSColor calibrated, device, genericGamma22 white float regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        // Objective-C - Only functions with alpha defined

        let commonObjCRegex = "White:\\s*" + objcFloatColourConst + "\\s*alpha:\\s*" + objcAlphaConst + "\\s*\\]"
        
        do {
            regex = try NSRegularExpression ( pattern: "\\[\\s*(?:NS|UI)Color\\s*colorWith" + commonObjCRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C White float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
        
        
        do {
            // Don't care about saving the Calibrated, Device, or genericGamma22 since we assume that any function that
            // replace the values will do so selectively instead of overwriting the whole string.
        
            regex = try NSRegularExpression ( pattern: "\\[\\s*NSColor\\s*colorWith(?:Calibrated|Device|GenericGamma22)" + commonObjCRegex, options: [])
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if regex == nil {
            print ( "Error creating Objective-C calibrated, device, genericGamma22 white float with alpha regex = \(error?.localizedDescription)" )
        } else {
            regexes.append( regex! )
        }
    }
    
    
    override func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        // We'll always have two matches right now but if ever the alpha becomes optional
        // then it will be either one or two and this function will have to look like
        // the others.
        
        if ( match.numberOfRanges == 3 ) {
            
            let matchString = stringFromRange( match.range, line: line )
            let whiteString = stringFromRange( match.rangeAtIndex( 1 ), line: line )
            let alphaString = stringFromRange( match.rangeAtIndex( 2 ), line: line )
            let capturedStrings = [ matchString, whiteString, alphaString ]
            
            
            let whiteValue = CGFloat ( ( whiteString as NSString).doubleValue )
            let alphaValue = CGFloat ( ( alphaString as NSString).doubleValue )
            
            let whiteColor = NSColor ( calibratedWhite: whiteValue, alpha: alphaValue )
            if let color = whiteColor.colorUsingColorSpace( NSColorSpace.genericRGBColorSpace() ) {
            
                var searchResult = SearchResult ( color: color, textCheckingResult: match, capturedStrings: capturedStrings )
                searchResult.creationType = .DefaultWhite
                
                return searchResult
            }
        }
        
        return nil
    }
}

//
//  Seeker.swift
//  ColorSenseRainbow
//
//  Created by Reid Gravelle on 2015-04-19.
//  Copyright (c) 2015 Northern Realities Inc. All rights reserved.
//

import AppKit

class Seeker {

    var regexes : [NSRegularExpression] = []
    
    
    // Constants that define how numbers will be searched for in regular expressions. Define them once here so that if they need to be changed then it only needs to be done once instead of in all of the Seeker subclasses.  If a definition is only used in one subclass then define it there to minimize the memory required but make a note here that the subclass has at least one. That way if something changes it won't be missed.
 
    // Defines how the alpha component of the colour is specified for floating point values between 0 and 1 inclusive.
    // Valid values: 0; 1; 0.0; 1.0; 0.9; 0.25; 0.97453
    
    let swiftAlphaConst = "([01]|[01]\\.[0-9]+)"

    
    // Defines how the RGB component of the colour is specified for floating point values between 0 and 1 inclusive. It's defined separately in case it needs to be different in the future.
    // Valid values: 0; 1; 0.0; 1.0; 0.9; 0.25; 0.97453
    
    let swiftFloatColourConst = "([01]|[01]\\.[0-9]+)"
    
    
    // Defines how the RGB component of the colour is specified for numbers >= zero. Numbers may be integer or floating point and intended to be between 0 and 255 inclusive but no bounds checking is performed.
    // Valid values: 0; 0.0; 255; 127.55
    // TODO: - Have it so that if there's nothing after the decimal then the search fails.

    let swiftRBGComponentConst = "([0-9]+|[0-9]+\\.[0-9]+)"
    
    
    // Defines how the HSB component of the colour is specified for numbers >= zero. Numbers may be integer and no bounds checking is performed. Values for hue (H) are intended to be between 0 and 359 inclusive while saturation (S) and brightness (B) represent percentages which range from 0 and 100 inclusive.
    // Valid values: 0; 255 (only for hue); 10
    
    let swiftHSBComponentConst = "([0-9]+)"
    
    
    // rainbowIntColourConst - Defined in RainbowIntSeeker.swift
    
    
    // Declares the optional use of the init function call
    
    let swiftInit = "(?:\\.init)?"
    

    // Defines how the alpha component of the colour is specified for floating point values between 0 and 1 inclusive.
    // Valid values: 0; 1; 0.0; 1.0; 0.9; 0.25; 0.97453; 0f
    
    let objcAlphaConst = "([01]|[01]?\\.[0-9]+)f?"
    
    
    let objcFloatColourConst = "([01]|[01]?\\.[0-9]+)f?"

    
    /**
    Look for an object of color being created in the line of text being passed in using regular expressions.  If found it returns back an object of NSColor and the location in the line where the text occurs.
    
    - parameter line:      The text to search for a color being created.
    - parameter lineRange: Where in the line the caret of the NSTextView is placed.
    
    - returns: A SearchResult object containing a NSColor and a NSRange if a match is found.
    */
    
    func searchForColor ( line : String, selectedRange : NSRange ) -> SearchResult? {

        for regex in ( regexes ) {
            let range = NSMakeRange( 0, line.characters.count )

            let matches = regex.matchesInString( line, options: [], range: range ) 
            if ( matches.count > 0 ) {
                for match in matches {
                    if ( self.matchRangeContainsLineRange( match.range, selectedRange: selectedRange ) == true ) {
                        if let searchResult = processMatch( match, line: line ) {
                            return searchResult
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    
    /**
    Determines whether or not that the caret (as specified by the selectedRange) is within the text found to create a color object.
    
    - parameter matchRange:     The range of text that creates a color object.
    - parameter selectedRange:  The location of the caret on the line (should have a length of 0).
    
    - returns: A Bool value.
    */
    
    func matchRangeContainsLineRange ( matchRange : NSRange, selectedRange : NSRange ) -> Bool {
    
        // TODO: - Create test that has two colors created on a line and see that the right one is selected.
        return ( ( selectedRange.location >= matchRange.location ) &&
                 ( NSMaxRange( selectedRange ) <= NSMaxRange( matchRange ) ) )
    }
    
    
    /**
    An abstract function that should be overridden by the child class.  The purpose of the function is to take a match and create the color that was found.
    
    - parameter match: A NSTextCheckingResult that provides the details where the color text is within the line.
    - parameter line:  A String containing the line of text.
    
    - returns: If the color can be created then a SearchResult is returned, otherwise nil.
    */
    
    func processMatch ( match : NSTextCheckingResult, line : String ) -> SearchResult? {
        
        return nil
    }
    
    
    /**
    Returns a substring from the String passed in as defined by the given NSRange.  It translates the NSRange into values useful to Range<String.Index> instead of converting the String object to an NSString object.  No checking is performed to ensure that the range is valid.
    
    - parameter range: The NSRange specifying the substring to grab.
    - parameter line:  The String containing the text to take the substring from.
    
    - returns: A String object
    */
    
    func stringFromRange ( range : NSRange, line : String ) -> String {
        
        return line.substringWithRange( range.calculateRangeInString( line ) )

    }
    
    
    /**
    Converts the String to an enumerated value for the type of color object (UIColor or NSColor).  If the String is equal to "UI" then the associated value is returned otherwise the value for "NS" is sent back.
    
    - parameter colorTypeString: The String object to test.
    
    - returns: A CSRColorType enumerated value.
    */
    
    func colorTypeFromString ( colorTypeString : String ) -> CSRColorType {
        
        switch colorTypeString {
        case "UI":
            return .UIColor

        case "NS":
            fallthrough
            
        default:
            return .NSColor
        }
    }
    
    
    /**
    Determines whether the string passed in contains Swift or Objective-C code.  If it contains an "[" then Objective-C code is assumed, otherwise it is assumed that the string contains Swift code.  No checking is performed to determined if the string contains valid code of either language.
    
    - parameter stringToCheck: The String object containing the code to test.
    
    - returns: A CSRProgrammingLanguage enum value specifying the language.
    */
    
    func programmingLanguageFromString ( stringToCheck : String ) -> CSRProgrammingLanguage {
        
        if ( stringToCheck.rangeOfString( "[" ) != nil ) {
            return .ObjectiveC
        }
        
        return .Swift
    }
}

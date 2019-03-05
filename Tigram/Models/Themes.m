//
//  Themes.m
//  Tigram
//
//  Created by Маргарита Коннова on 03/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

#import "Themes.h"

@implementation Themes

// MARK: LifeCycle of themes class
- (instancetype) initThemesWithFirstColor:(UIColor *)lightColor secondColor:(UIColor *)darkColor thirdColor:(UIColor *)champagneColor {
    
    // [super init] is permitted to do one of three things:
    //      return its own receiver with inherited instance values initialized;
    //      return a different object with inherited instance values initialized;
    //      return nil, indicating failure.
    if (self = [super init]) {
        self.light = lightColor;
        self.dark = darkColor;
        self.champagne = champagneColor;
    }
    
    return self;
}

- (void) dealloc {
    // Reduces the number of references by one
    [theme1 release];
    // Sets pointer to nil to avoid dangling pointers
    theme1 = nil;
    
    // And for the two remaining
    [theme2 release];
    theme2 = nil;
    
    [theme3 release];
    theme3 = nil;
    
    [super dealloc];
}


// MARK: Getters for each theme
- (UIColor *) light {
    return theme1;
}

- (UIColor *) dark {
    return theme2;
}

- (UIColor *) champagne {
    return theme3;
}

// MARK: Setters for each theme
- (void) setLight:(UIColor *)light {
    // Reduces the number of references for previous theme by one to avoid memory leak
    [theme1 release];
    // Increase the number of references for new light theme by one
    theme1 = [light retain];
}

- (void) setDark:(UIColor *)dark {
    // Reduces the number of references for previous theme by one to avoid memory leak
    [theme2 release];
    // Increase the number of references for new dark theme by one
    theme2 = [dark retain];
}

- (void) setChampagne:(UIColor *)champagne {
    // Reduces the number of references for previous theme by one to avoid memory leak
    [theme3 release];
    // Increase the number of references for new champagne theme by one
    theme3 = [champagne retain];
}

@end


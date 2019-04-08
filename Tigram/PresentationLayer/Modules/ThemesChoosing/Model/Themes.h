//
//  Themes.h
//  Tigram
//
//  Created by Маргарита Коннова on 03/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Themes: NSObject {
    UIColor * theme1;
    UIColor * theme2;
    UIColor * theme3;
}

// Init all three themes with colors
- (instancetype) initThemesWithFirstColor:(UIColor *) lightColor
                             secondColor:(UIColor *) darkColor
                             thirdColor:(UIColor *) champagneColor;
- (void) dealloc;

// Gets or sets colors for themes
@property (retain, nonatomic) UIColor * light;
@property (retain, nonatomic) UIColor * dark;
@property (retain, nonatomic) UIColor * champagne;

@end

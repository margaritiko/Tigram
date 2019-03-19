//
//  ThemesViewControllerDelegate.h
//  Tigram
//
//  Created by Маргарита Коннова on 03/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThemesViewController;
@protocol ThemesViewControllerDelegate <NSObject>
- (void) themesViewController:(ThemesViewController *)controller didSelectTheme:(UIColor *)selectedTheme;
@end

//
//  ThemesViewController.h
//  Tigram
//
//  Created by Маргарита Коннова on 03/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Themes.h"

@protocol ThemesViewControllerDelegate;

@interface ThemesViewController : UIViewController {
    id <ThemesViewControllerDelegate> _delegate;
    Themes * _model;
}
// Not retained, when setting the delegate property, just simply assigned.
@property (assign, nonatomic) id <ThemesViewControllerDelegate> delegate;
@property (retain, nonatomic) Themes * model;
// Just for compatibility with Swift class
@property (assign, nonatomic) void (^closureForSettingNewTheme)(UIColor * color, UIViewController * vc);

@end

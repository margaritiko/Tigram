//
//  ThemesViewController.m
//  Tigram
//
//  Created by Маргарита Коннова on 03/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

#import "ThemesViewController.h"
#import "ThemesViewControllerDelegate.h"

@implementation ThemesViewController

// MARK: LifeCycle of ThemesViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"ThemesViewController: Objective-C");
    // Default - white color
    // Don't need to call release fot it
    UIColor * lightColor = [UIColor whiteColor];
    UIColor * darkColor = [[UIColor alloc] initWithRed:83 / 256.0 green:103 / 256.0 blue:120 / 256.0 alpha:1.0];
    UIColor * champagneColor = [[UIColor alloc] initWithRed:244 / 256.0 green:217 / 256.0 blue:73 / 256.0 alpha:1.0];
    
    _model = [[Themes alloc] initThemesWithFirstColor:lightColor secondColor:darkColor thirdColor:champagneColor];
    
    [darkColor release];
    [champagneColor release];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults * data = [NSUserDefaults standardUserDefaults];
    NSString * themeNameForBackground = [data objectForKey:@"Theme"];
    if ([themeNameForBackground isEqual: @"light"]) {
        self.view.backgroundColor = [self.model light];
    }
    else if ([themeNameForBackground isEqual: @"dark"]) {
        self.view.backgroundColor = [self.model dark];
    }
    else if ([themeNameForBackground isEqual: @"champagne"]) {
        self.view.backgroundColor = [self.model champagne];
    }
}

- (void) dealloc {
    // Reduces the number of references for _model by one to avoid memory leak
    [_model release];
    // Sets _model pointer to nil to avoid dangling pointers
    _model = nil;
    // Sets _delegate pointer to nil to avoid dangling pointers
    _delegate = nil;
    
    [super dealloc];
}

// MARK: Getters for properties
- (Themes *) model {
    return _model;
}

- (id <ThemesViewControllerDelegate>) delegate {
    return _delegate;
}

// MARK: Setters for properties
- (void) setModel:(Themes *)model {
    if (_model != model) {
        // Reduces the number of references for previous model by one to avoid memory leak
        [_model release];
        // Increase the number of references for new model by one
        _model = [model retain];
    }
}

- (void) setDelegate:(id <ThemesViewControllerDelegate>)delegate {
    // Don't need to call retain because of using assign attribute
    if (_delegate != delegate)
        _delegate = delegate;
}

// MARK: User interaction
- (IBAction) closeButtonClicked:(UIButton *)sender {
    // Returns to ConversationsListViewController
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) lightThemeButtonClicked:(UIButton *)sender {
    self.view.backgroundColor = [self.model light];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"light" forKey:@"Theme"];
    [_delegate themesViewController:self didSelectTheme:[self.model light]];
}

- (IBAction) darkThemeButtonClicked:(UIButton *)sender {
    self.view.backgroundColor = [self.model dark];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"dark" forKey:@"Theme"];
    [_delegate themesViewController:self didSelectTheme:[self.model dark]];
}

- (IBAction) champagneThemeButtonClicked:(UIButton *)sender {
    self.view.backgroundColor = [self.model champagne];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"champagne" forKey:@"Theme"];
    [_delegate themesViewController:self didSelectTheme:[self.model champagne]];
}

@end

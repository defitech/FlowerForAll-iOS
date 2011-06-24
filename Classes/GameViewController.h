//
//  GameViewController.h
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the view controller for the game view. It handles notably a scroll view, allowing the user to scroll between the different games.


#import <UIKit/UIKit.h>


@interface GameViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate>{

	//The sub views include mainly the scroll view, which will include game1ChoiceView and game2ChoiceView (for the moment there are 2 games)
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIView *game1ChoiceView;
	IBOutlet UIView *game2ChoiceView;
	
	//The buttons inside each of the game sub views
	IBOutlet UIButton *game1Button;
	IBOutlet UIButton *game2Button;
	
	//The picker view that is displayed for selecting the user in case of multiple users utilisation
	UIView *labelAndPickerView;
	UIPickerView *myPickerView;
	UILabel *pickerLabel;
	
	//There is no navigation controller here. So we add a navigation bar individually.
	IBOutlet UINavigationBar *navigationBar;
	
	//Page control for the ScrollView
	IBOutlet UIPageControl *pageControl;
	
	//Arrays containing the user informations (for the display and selection of users)
	NSArray *userIDsArray;
	NSArray *usernamesArray;
	
	//Stores the currently selected row in the picker view
	NSInteger selectedRow;
	
	//The password text field
	UITextField *passwordTextField;
	
    }


//Properties
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) UIView *game1ChoiceView;
@property(nonatomic,retain) UIView *game2ChoiceView;

@property(nonatomic,retain) UIButton *game1Button;
@property(nonatomic,retain) UIButton *game2Button;

@property (nonatomic, retain) UIView *labelAndPickerView;
@property (nonatomic, retain) UIPickerView *myPickerView;
@property (nonatomic, retain) UILabel *pickerLabel;

@property (nonatomic, retain) UINavigationBar *navigationBar;

@property (nonatomic, retain) UIPageControl *pageControl;

@property (nonatomic, retain) NSArray *userIDsArray;
@property (nonatomic, retain) NSArray *usernamesArray;
@property NSInteger selectedRow;
@property (nonatomic, retain) UITextField *passwordTextField;

- (IBAction) game1Touch:(id) sender;


@end

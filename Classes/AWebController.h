//
//  AWebController.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 24.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AWebController : UIViewController {
    IBOutlet UIWebView *webView;
    IBOutlet UIToolbar *toolBar;
}

@property(nonatomic,retain) UIWebView *webView;
@property(nonatomic,retain) UIToolbar *toolBar;

- (IBAction) search:(id)sender;

-(void) modalTextfield:(NSString*)title message:(NSString*)message nextAction:(int)actionID;

@end

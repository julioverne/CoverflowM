#import <notify.h>
#import <Social/Social.h>
#import <prefs.h>

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.coverflowm.plist"


@interface CoverflowMSettingsController : PSListController {
	UILabel* _label;
	UILabel* underLabel;
}
- (void)HeaderCell;
@end

static __strong CoverflowMSettingsController* sharedInstaceCoverflowMSettingsController;

@implementation CoverflowMSettingsController
- (id)init
{
	if(!sharedInstaceCoverflowMSettingsController) {
		sharedInstaceCoverflowMSettingsController = [super init];
	}
	self = sharedInstaceCoverflowMSettingsController;
	return self;
}
- (id)specifiers {
	if (!_specifiers) {
		NSMutableArray* specifiers = [NSMutableArray array];
		PSSpecifier* spec;
		spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                  target:self
											         set:@selector(setPreferenceValue:specifier:)
											         get:@selector(readPreferenceValue:)
                                                  detail:Nil
											        cell:PSSwitchCell
											        edit:Nil];
		[spec setProperty:@"Enabled" forKey:@"key"];
		[spec setProperty:@YES forKey:@"default"];
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Style"
					      target:self
											  set:@selector(setPreferenceValue:specifier:)
											  get:@selector(readPreferenceValue:)
					      detail:PSListItemsController.class
											  cell:PSLinkListCell
											  edit:Nil];
			[spec setProperty:@"styleEnabled" forKey:@"key"];
			[spec setProperty:@0 forKey:@"default"];
			[spec setValues:@[@9, @0, @1, @2, @3, @4, @5, @6, @7, @8, @10, @11,]
			titles:@[ @"iOS 6",
					  @"iOS 8.3",
					  @"Linear",
					  @"Rotary",
					  @"Inverted Rotary",
					  @"Cylinder",
					  @"Inverted Cylinder",
					  @"Wheel",
					  @"Inverted Wheel",
					  @"CoverFlow",
					  @"Time Machine",
					  @"Inverted Time Machine",]];
		[specifiers addObject:spec];
		
		
			spec = [PSSpecifier emptyGroupSpecifier];
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Reset Settings"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(reset);
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Developer"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Developer" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Follow julioverne"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(twitter);
		[spec setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
		[spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"twitter" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
		spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:@"CoverflowM © 2017" forKey:@"footerText"];
        [specifiers addObject:spec];
		_specifiers = [specifiers copy];
	}
	return _specifiers;
}

- (void)showPrompt
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title message:@"An Respring is Requerid for this option." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Respring", nil];
	alert.tag = 55;
	[alert show];
}
- (void)respring
{
	system("killall backboardd SpringBoard");
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 55 && buttonIndex == 1) {
		[self respring];
    }
}

- (void)reset
{
	[@{} writeToFile:@PLIST_PATH_Settings atomically:YES];
	notify_post("com.julioverne.coverflowm/SettingsChanged");
	[self reloadSpecifiers];
	[self showPrompt];
}

- (void)twitter
{
	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=ijulioverne"]]) {
		[app openURL:[NSURL URLWithString:@"twitter://user?screen_name=ijulioverne"]];
	} else if ([app canOpenURL:[NSURL URLWithString:@"tweetbot:///user_profile/ijulioverne"]]) {
		[app openURL:[NSURL URLWithString:@"tweetbot:///user_profile/ijulioverne"]];		
	} else {
		[app openURL:[NSURL URLWithString:@"https://mobile.twitter.com/ijulioverne"]];
	}
}
- (void)love
{
	SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	[twitter setInitialText:@"#CoverflowM by @ijulioverne is cool!"];
	if (twitter != nil) {
		[[self navigationController] presentViewController:twitter animated:YES completion:nil];
	}
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	@autoreleasepool {
		NSMutableDictionary *Prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		Prefs[[specifier identifier]] = value;
		[Prefs writeToFile:@PLIST_PATH_Settings atomically:YES];
		notify_post("com.julioverne.coverflowm/SettingsChanged");
		if ([[specifier properties] objectForKey:@"PromptRespring"]) {
			[self showPrompt];
		}
	}
}
- (id)readPreferenceValue:(PSSpecifier*)specifier
{
	@autoreleasepool {
		NSDictionary *Prefs = [[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings];
		return Prefs[[specifier identifier]]?:[specifier properties][@"default"];
	}
}
- (void)_returnKeyPressed:(id)arg1
{
	[super _returnKeyPressed:arg1];
	[self.view endEditing:YES];
}

- (void)HeaderCell
{
	@autoreleasepool {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
	int width = [[UIScreen mainScreen] bounds].size.width;
	CGRect frame = CGRectMake(0, 20, width, 60);
		CGRect botFrame = CGRectMake(0, 55, width, 60);
 
		_label = [[UILabel alloc] initWithFrame:frame];
		[_label setNumberOfLines:1];
		_label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
		[_label setText:self.title];
		[_label setBackgroundColor:[UIColor clearColor]];
		_label.textColor = [UIColor blackColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.alpha = 0;

		underLabel = [[UILabel alloc] initWithFrame:botFrame];
		[underLabel setNumberOfLines:1];
		underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[underLabel setText:@"Landscape Styles for Music App"];
		[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;
		underLabel.alpha = 0;
		
		[headerView addSubview:_label];
		[headerView addSubview:underLabel];
		
	[_table setTableHeaderView:headerView];
	
	[NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(increaseAlpha)
                                   userInfo:nil
                                    repeats:NO];
				
	}
}
- (void) loadView
{
	[super loadView];
	self.title = @"CoverflowM";
	[self HeaderCell];	
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:0.09 green:0.99 blue:0.99 alpha:1.0];
	UIButton *heart = [[UIButton alloc] initWithFrame:CGRectZero];
	[heart setImage:[[UIImage alloc] initWithContentsOfFile:[[self bundle] pathForResource:@"Heart" ofType:@"png"]] forState:UIControlStateNormal];
	[heart sizeToFit];
	[heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:heart];
}
- (void)increaseAlpha
{
	[UIView animateWithDuration:0.5 animations:^{
		_label.alpha = 1;
	}completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			underLabel.alpha = 1;
		}completion:nil];
	}];
}				
@end


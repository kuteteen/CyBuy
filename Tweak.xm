#import "DeviceViewController.h"
#include <sys/utsname.h>
#include <Foundation/Foundation.h>

%hook HomeController
// Change the About button text to Options.
-(UIBarButtonItem*) leftButton {
     UIBarButtonItem* leftButton = %orig;
     [(UIBarButtonItem *)leftButton setTitle:@"Options"];
     return leftButton;
}

// Show actionsheet from alert controller
-(void) aboutButtonClicked {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Options" preferredStyle:UIAlertControllerStyleActionSheet];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

	// Cancel button tappped do nothing.

	}]];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"About Cydia" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	    // Display Cydia's default About alert.
        %orig();
	}]];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"About CyBuy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	    NSString* plistPath = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Settings" ofType:@"plist"];
		NSMutableDictionary *settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath]; 
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CyBuy"
												message:[NSString stringWithFormat:@"Your device is currently identifying as %@ running iOS %@", [settingsDict objectForKey:@"emulationHardware"], [settingsDict objectForKey:@"emulationSoftware"]]
											   delegate:self
									  cancelButtonTitle:@"Ok"
									  otherButtonTitles:nil];
		[alert show];
	}]];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Change Hardware" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {		
		UIViewController *vc = [[DeviceViewController alloc] init];
		[self presentViewController:vc animated:YES completion:nil];
	}]];
	
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Change Software" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		UIAlertController *softwareAlert = [UIAlertController alertControllerWithTitle:@"CyBuy" message:@"Please enter a version on iOS to emulate." preferredStyle:UIAlertControllerStyleAlert];
		
		[softwareAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
			textField.placeholder = [[UIDevice currentDevice] systemVersion];
			textField.keyboardType = UIKeyboardTypeDecimalPad;
		}];
		
		UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			NSString* plistPath = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Settings" ofType:@"plist"];
			NSMutableDictionary *settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath]; 
			[settingsDict setObject:[[softwareAlert textFields][0] text] forKey:@"emulationSoftware"];
			[settingsDict writeToFile:plistPath atomically:YES];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Software Updated"
												message:[NSString stringWithFormat:@"Your device now identifies to Cydia as running %@", [[softwareAlert textFields][0] text]]
											   delegate:self
									  cancelButtonTitle:@"Ok"
									  otherButtonTitles:nil];
			[alert show];
		}];
		
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
			// Nothing
		}];
		
		[softwareAlert addAction:confirmAction];
		[softwareAlert addAction:cancelAction];
		UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		alertWindow.rootViewController = [[UIViewController alloc] init];
		alertWindow.windowLevel = UIWindowLevelAlert + 1;

		[alertWindow makeKeyAndVisible];
		[alertWindow.rootViewController presentViewController:softwareAlert animated:YES completion:nil];
		[alertWindow release];
	}]];
	
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Reset to Original Device Details" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		// Get real model, platform and software versions.
        struct utsname systemInfo;
    	uname(&systemInfo);

    	NSString *Model     = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    	NSString *Software  = [[UIDevice currentDevice] systemVersion];
    	
    	NSString* plistPath = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Settings" ofType:@"plist"];
		NSMutableDictionary *settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath]; 
		[settingsDict setObject:Model forKey:@"emulationHardware"];
		[settingsDict setObject:Software forKey:@"emulationSoftware"];
		[settingsDict writeToFile:plistPath atomically:YES];

    	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CyBuy"
                                                        message:[NSString stringWithFormat:@"CyBuy has been reset to your system defaults.\n\nHardware: %@\nSoftware: %@", Model, Software]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
	}]];
	
	// Stupid way to assure we are on the right view. Is there a better way to do this?
	UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	alertWindow.rootViewController = [[UIViewController alloc] init];
	alertWindow.windowLevel = UIWindowLevelAlert + 1;

	[alertWindow makeKeyAndVisible];
	[alertWindow.rootViewController presentViewController:actionSheet animated:YES completion:nil];
	[alertWindow release];
} 

%end

%hook CydiaWebViewController

+(NSURLRequest *) requestWithHeaders:(NSURLRequest *) request {
	NSMutableURLRequest *copy = [%orig mutableCopy];
	
	NSURL *url([copy URL]);
	NSString *href([url absoluteString]);
	
	NSString* plistPath = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Settings" ofType:@"plist"];
	NSMutableDictionary *settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];

	if([href hasPrefix:@"https://cydia.saurik.com/api/commercial?package="] && ![[settingsDict objectForKey:@"emulationHardware"] isEqualToString:@"stock"] && ![[settingsDict objectForKey:@"emulationHardware"] isEqualToString:@"stock"]) {
        
        NSString *Custom_iOS_Model    = [settingsDict objectForKey:@"emulationHardware"];
        
        NSString *Custom_iOS_Hardware = @"iPhone";
        if([[settingsDict objectForKey:@"emulationHardware"] hasPrefix:@"iPhone"]) {
	        Custom_iOS_Hardware = @"iPhone";
	    } else if([[settingsDict objectForKey:@"emulationHardware"] hasPrefix:@"iPod"]) {
	        Custom_iOS_Hardware = @"iPod";
	    } else if([[settingsDict objectForKey:@"emulationHardware"] hasPrefix:@"iPad"]) {
	        Custom_iOS_Hardware = @"iPad";
	    }
	    
	    
        NSString *Custom_iOS_Software = [[settingsDict objectForKey:@"emulationSoftware"] stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        
        [copy setValue:[NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU iPhone OS %@ like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Mobile/14B100 Safari/602.1 Cydia/1.1.30 CyF/1348.00", Custom_iOS_Hardware, Custom_iOS_Software] forHTTPHeaderField:@"User-Agent"]; // Custom :D
        [copy setValue:Custom_iOS_Model forHTTPHeaderField:@"X-Machine"]; // Custom :D
    }
    
	return copy;
}

%end

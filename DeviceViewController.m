#import "DeviceViewController.h"
@implementation DeviceViewController {
	NSString *_selectedEntry;
}

- (void)loadView {
	[super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Models" ofType:@"plist"];
    NSArray  *devices = [NSArray arrayWithContentsOfFile:path];
    _selectedEntry = [devices objectAtIndex:0];
    
	self.view.backgroundColor = [UIColor whiteColor];
	
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(doneClicked)];
    
    UILabel *toolbarLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	toolbarLabel.text = @"Select a Device";
	[toolbarLabel sizeToFit];
	toolbarLabel.backgroundColor = [UIColor clearColor];
	toolbarLabel.textColor = [UIColor grayColor];
	toolbarLabel.textAlignment = NSTextAlignmentCenter;
	UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:toolbarLabel];


    toolBar.items = @[flex, labelItem, flex, barButtonDone];
    barButtonDone.tintColor = [UIColor blueColor];

    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBar.frame.size.height, screenWidth, 200)];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;


    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolBar.frame.size.height + picker.frame.size.height)];
    inputView.backgroundColor = [UIColor clearColor];
    [inputView addSubview:picker];
    [inputView addSubview:toolBar];
    
    [self.view addSubview:inputView];
}

-(void) doneClicked {
	NSString* plistPath = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Settings" ofType:@"plist"];
	NSMutableDictionary *settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath]; 
	[settingsDict setObject:_selectedEntry forKey:@"emulationHardware"];
	[settingsDict writeToFile:plistPath atomically:YES];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device Model Updated"
													message:[NSString stringWithFormat:@"Your device now identifies to Cydia as %@", _selectedEntry]
												   delegate:self
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles:nil];
	[alert show];
	[self resignFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSString *path = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Models" ofType:@"plist"];
    NSArray  *devices = [NSArray arrayWithContentsOfFile:path];
    _selectedEntry = [devices objectAtIndex:row];

}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	NSString *path = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Models" ofType:@"plist"];
    NSArray  *devices = [NSArray arrayWithContentsOfFile:path];
    return [devices count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *path = [[NSBundle bundleWithPath:@"/var/mobile/Library/Application Support/CyBuy"] pathForResource:@"Models" ofType:@"plist"];
    NSArray  *devices = [NSArray arrayWithContentsOfFile:path];
	NSString *title = devices[row];
    return title;
}

@end

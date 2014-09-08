//
//  VPKeyboardViewController.m
//  VPHabrakeyboardApp
//
//  Created by Vladimir Popko on 9/7/14.
//  Copyright (c) 2014 visput. All rights reserved.
//

#import "VPKeyboardViewController.h"

static NSString *const kVPUserDefaultsGesturesIsEnabledKey = @"gestures_preference";

@interface VPKeyboardViewController ()

@property (nonatomic, strong) IBOutlet UIView *keyboardView;
@property (nonatomic, strong) NSDictionary *tagsDictionary;

@end

@implementation VPKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadKeyboard];
    [self loadTags];
}

#pragma mark -
#pragma mark Action

- (IBAction)onNextInputModeButtonPressed:(id)sender {
    [self advanceToNextInputMode];
}

- (IBAction)onDeleteButtonPressed:(id)sender {
    if (self.textDocumentProxy.documentContextBeforeInput.length > 0) {
        [self.textDocumentProxy deleteBackward];
    }
}

- (IBAction)onClearButtonPressed:(id)sender {
    NSInteger endPositionOffset = self.textDocumentProxy.documentContextAfterInput.length;
    [self.textDocumentProxy adjustTextPositionByCharacterOffset:endPositionOffset];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // We can't know when text position adjustment is finished
        // Hack: Call this code after delay. In other case these changes won't be applied
        while (self.textDocumentProxy.documentContextBeforeInput.length > 0) {
            [self.textDocumentProxy deleteBackward];
        }
    });
}

- (IBAction)onDismissKeyboardButtonPressed:(id)sender {
    [self dismissKeyboard];
}

- (IBAction)onHabraButtonPressed:(id)sender {
    NSString *tagKey = [sender titleForState:UIControlStateNormal];
    NSString *tagValue = self.tagsDictionary[tagKey];
    [self.textDocumentProxy insertText:tagValue];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // We can't know when text insert is finished
        // Hack: Call this code after delay. In other case these changes won't be applied
        [self moveTextPositionToInputPointForTag:tagValue];
    });
}

- (IBAction)onLeftSwipeRecognized:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kVPUserDefaultsGesturesIsEnabledKey] &&
        self.textDocumentProxy.documentContextBeforeInput.length > 0) {
        
        [self.textDocumentProxy adjustTextPositionByCharacterOffset:-1];
    }
}

- (IBAction)onRightSwipeRecognized:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kVPUserDefaultsGesturesIsEnabledKey] &&
        self.textDocumentProxy.documentContextAfterInput.length > 0) {
        
        [self.textDocumentProxy adjustTextPositionByCharacterOffset:1];
    }
}

#pragma mark -
#pragma mark Private

- (void)loadKeyboard {
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self.view addSubview:self.keyboardView];
}

- (void)loadTags {
    NSString *tagsFilePath = [[NSBundle mainBundle] pathForResource:@"tags" ofType:@"json"];
    NSData *tagsData = [NSData dataWithContentsOfFile:tagsFilePath];
    NSError *error = nil;
    self.tagsDictionary = [NSJSONSerialization JSONObjectWithData:tagsData options:NSJSONReadingAllowFragments error:&error];
    NSAssert(error == nil, @"Invalid data format in file: %@", tagsFilePath);
}

- (void)moveTextPositionToInputPointForTag:(NSString *)tag {
    NSArray *inputPointLabels = @[@"://", @"=\"", @">"];
    for (NSString *label in inputPointLabels) {
        NSRange labelRange = [tag rangeOfString:label];
        if (labelRange.location != NSNotFound) {
            NSInteger offset = labelRange.location + labelRange.length - tag.length;
            [self.textDocumentProxy adjustTextPositionByCharacterOffset:offset];
            break;
        }
    }
}

@end

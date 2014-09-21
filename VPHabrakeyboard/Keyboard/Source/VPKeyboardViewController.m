//
//  VPKeyboardViewController.m
//  VPHabrakeyboardApp
//
//  Created by Vladimir Popko on 9/7/14.
//  Copyright (c) 2014 visput. All rights reserved.
//

#import "VPKeyboardViewController.h"

@interface VPKeyboardViewController ()

@property (nonatomic, strong) IBOutlet UIView *keyboardView;
@property (nonatomic, strong) IBOutlet UIButton *sarcasmButton;
@property (nonatomic, strong) IBOutlet UIButton *downerButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *tagButtons;

@property (nonatomic, strong) NSDictionary *tagsDictionary;

@end

@implementation VPKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadKeyboard];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    if (self.textDocumentProxy.documentContextBeforeInput.length > 0) {
        [self.textDocumentProxy adjustTextPositionByCharacterOffset:-1];
    }
}

- (IBAction)onRightSwipeRecognized:(id)sender {
    if (self.textDocumentProxy.documentContextAfterInput.length > 0) {
        [self.textDocumentProxy adjustTextPositionByCharacterOffset:1];
    }
}

#pragma mark -
#pragma mark Private

- (void)loadKeyboard {
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    self.keyboardView.frame = self.view.frame;
    [self.view addSubview:self.keyboardView];
    
    // Make images resizable
    for (UIButton *tagButton in self.tagButtons) {
        UIImage *image = [tagButton backgroundImageForState:UIControlStateNormal];
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(image.size.height / 2,
                                                   image.size.width / 2,
                                                   image.size.height / 2 + 1,
                                                   image.size.width / 2 + 1);
        [tagButton setBackgroundImage:[image resizableImageWithCapInsets:edgeInsets] forState:UIControlStateNormal];
    }
    
}

- (void)loadTags {
    // Load tags from json file
    NSString *tagsFilePath = [[NSBundle mainBundle] pathForResource:@"tags" ofType:@"json"];
    NSData *tagsData = [NSData dataWithContentsOfFile:tagsFilePath];
    NSError *error = nil;
    NSMutableDictionary *tagsDictionary = [NSJSONSerialization JSONObjectWithData:tagsData
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:&error];
    NSAssert(error == nil, @"Invalid data format in file: %@", tagsFilePath);
    
    // Load tags from settings
    static NSString *const kSarcasmTagOpenKey = @"SarcasmTagOpen";
    static NSString *const kSarcasmTagCloseKey = @"SarcasmTagClose";
    static NSString *const kDownerTagOpenKey = @"DownerTagOpen";
    static NSString *const kDownerTagCloseKey = @"DownerTagClose";
    static NSString *const kCustomTagFormat = @"[%@][/%@]";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sarcasmTag = nil;
    if ([userDefaults valueForKey:kSarcasmTagOpenKey] != nil && [userDefaults valueForKey:kSarcasmTagCloseKey]) {
        sarcasmTag = [NSString stringWithFormat:kCustomTagFormat, [userDefaults valueForKey:kSarcasmTagOpenKey], [userDefaults valueForKey:kSarcasmTagCloseKey]];
    } else {
        sarcasmTag = [NSString stringWithFormat:kCustomTagFormat, @"sarcasm mode on", @"sarcasm mode off"];
    }
    NSString *downerTag = nil;
    if ([userDefaults valueForKey:kDownerTagOpenKey] != nil && [userDefaults valueForKey:kDownerTagCloseKey]) {
        downerTag = [NSString stringWithFormat:kCustomTagFormat, [userDefaults valueForKey:kDownerTagOpenKey], [userDefaults valueForKey:kDownerTagCloseKey]];
    } else {
        downerTag = [NSString stringWithFormat:kCustomTagFormat, @"zanuda mode on", @"zanuda mode off"];
    }
    
    [tagsDictionary setValue:sarcasmTag forKey:[self.sarcasmButton titleForState:UIControlStateNormal]];
    [tagsDictionary setValue:downerTag forKey:[self.downerButton titleForState:UIControlStateNormal]];
    
    self.tagsDictionary = [NSDictionary dictionaryWithDictionary:tagsDictionary];
}

- (void)moveTextPositionToInputPointForTag:(NSString *)tag {
    static NSArray *inputPointLabels = nil;
    if (inputPointLabels == nil) {
        inputPointLabels = @[@"]", @"://", @"=\"", @">"];
    }
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

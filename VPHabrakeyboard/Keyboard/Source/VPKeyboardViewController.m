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

@end

@implementation VPKeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self.view addSubview:self.keyboardView];
}

#pragma mark -
#pragma mark UITextInputDelegate

- (void)textWillChange:(id<UITextInput>)textInput {
    [super textWillChange:textInput];
}

- (void)textDidChange:(id<UITextInput>)textInput {
    [super textDidChange:textInput];
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

- (IBAction)onDismissKeyboardButtonPressed:(id)sender {
    [self dismissKeyboard];
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

@end

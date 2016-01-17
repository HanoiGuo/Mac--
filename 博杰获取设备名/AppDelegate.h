//
//  AppDelegate.h
//  博杰获取设备名
//
//  Created by Hanoi on 16/1/10.
//  Copyright (c) 2016年 Tony. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSTextField *DevicesNameKeyWords;
@property (weak) IBOutlet NSTextField *SoftwareVersion;
@property (weak) IBOutlet NSTextField *LeftShowMessage;

@property (weak) IBOutlet NSTextField *RightShowMessage;

@property (weak) IBOutlet NSButton *LockText;

@property (weak) IBOutlet NSTextField *ShowMessage;
@property (weak) IBOutlet NSButton *modify;
@property (weak) IBOutlet NSComboBox *ProductName;


- (IBAction)m_Lock:(id)sender;
- (IBAction)m_Start:(id)sender;

- (IBAction)m_Exit:(id)sender;
- (IBAction)m_Modify:(id)sender;
- (IBAction)OnComboboxChanged:(id)sender;

@end


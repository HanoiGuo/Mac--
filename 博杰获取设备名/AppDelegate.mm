//
//  AppDelegate.m
//  博杰获取设备名
//
//  Created by Hanoi on 16/1/10.
//  Copyright (c) 2016年 Tony. All rights reserved.
//

#import "AppDelegate.h"
#import "Tony.h"
#import <vector>

using namespace std;
#define DEV_PATH @"/dev/"

NSString *select_string_for_combox;
bool isPoor = false;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}



-(void)awakeFromNib
{
    _LeftShowMessage.backgroundColor = [NSColor yellowColor];
    _RightShowMessage.backgroundColor = [NSColor yellowColor];
    _DevicesNameKeyWords.editable = false;
    _DevicesNameKeyWords.stringValue = @"DOORKNOB";
    
    [_ProductName removeAllItems];
    //[_ProductName addItemWithObjectValue:@"11"];
    //[_ProductName addItemWithObjectValue:@"22"];
    //[_ProductName addItemWithObjectValue:@"33"];
    //[_ProductName selectItemAtIndex:0];
    
    vector<string>productname;
    GetProduceName(productname);
    if(productname.size() > 0)
    {
        for(int i=0; i<productname.size(); i++)
        {
            NSString *str = [NSString stringWithUTF8String:productname.at(i).c_str()];
            [_ProductName addItemWithObjectValue:str];
            if(i == 0)
            {
                select_string_for_combox = str;
            }
        }
        [_ProductName selectItemAtIndex:0];
    }
    else
    {
        [_ProductName addItemWithObjectValue:@"没有配置文件"];
        [_ProductName selectItemAtIndex:0];
        isPoor = true;
    }

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)m_Lock:(id)sender
{
    if (_LockText.state)
    {
        //_DevicesNameKeyWords.editable = false;
        //_SoftwareVersion.editable = false;
        //_ProductName.editable = false;
        //_ProductName.selectable = false;
        _ProductName.enabled = false;
    }
    else
    {
        //_DevicesNameKeyWords.editable = true;
        //_SoftwareVersion.editable = true;
        //_ProductName.editable = true;
        //_ProductName.selectable = true;
        _ProductName.enabled = true;
    }
}



- (IBAction)m_Start:(id)sender
{
    if(isPoor)
    {
        _LeftShowMessage.backgroundColor = [NSColor redColor];
        _RightShowMessage.backgroundColor = [NSColor redColor];
        _ShowMessage.stringValue = @"没有配置文件,不能操作改程序";
        return;
    }
    
    //1:get key word and version
    NSString *nsKeywords = _DevicesNameKeyWords.stringValue;
    //NSString *nsSoftwareVersion = _SoftwareVersion.stringValue;
    //string temp = [select_string_for_combox cStringUsingEncoding: NSUTF8StringEncoding];
    string temp = [select_string_for_combox UTF8String];
    if(!DealString(temp))
    {
        _LeftShowMessage.backgroundColor = [NSColor redColor];
        _RightShowMessage.backgroundColor = [NSColor redColor];
        _ShowMessage.stringValue = @"有点问题,请注意检查你的配置文件?";
        return;
    }
    NSString *nsSoftwareVersion = [NSString stringWithUTF8String:temp.c_str()];
    if (nsKeywords.length < 1 || nsSoftwareVersion.length < 1)
    {
        _LeftShowMessage.backgroundColor = [NSColor redColor];
        _RightShowMessage.backgroundColor = [NSColor redColor];
        _ShowMessage.stringValue = @"请各位输入设备名的关键字和软件版本的信息,谢谢。\r\n不然我是不会执行的,明白吗?";
        return;
    }
    
    // list out the dev directory
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dir_contents = [fm contentsOfDirectoryAtPath:DEV_PATH error:nil];
    
    // filter for /dev/tty.
    NSPredicate *tty_filter = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH 'tty.'"];
    NSArray *dir_contents_tty = [dir_contents filteredArrayUsingPredicate:tty_filter];
    
    // recover the full path
    NSString *dev_path = DEV_PATH;
    NSArray *dir_contents_tty_path = [dev_path stringsByAppendingPaths:dir_contents_tty];
    
    bool isFind = false;
    NSString *stringTest;
    for (int i=0; i<dir_contents_tty_path.count; i++)
    {
        stringTest = [dir_contents_tty_path objectAtIndex:i];
        //NSLog(@"%@\n",stringTest);
        isFind = FindKeyWords(stringTest.UTF8String,nsKeywords.UTF8String);
        if (isFind)
        {
            _ShowMessage.stringValue = stringTest;
            break;
        }
    }
    if(!isFind)
    {
        _LeftShowMessage.backgroundColor = [NSColor redColor];
        _RightShowMessage.backgroundColor = [NSColor redColor];
        _ShowMessage.stringValue = @"各位,设备名不对或未连接设备,请仔细检查,否则会造成品质问题,谢谢";
        return;
    }
    

    bool isVersionRight = false;
    isVersionRight = CheckSoftwareVersion(stringTest.UTF8String,nsSoftwareVersion.UTF8String,(int)nsSoftwareVersion.length);
    if (!isVersionRight)
    {
        _LeftShowMessage.backgroundColor = [NSColor redColor];
        _RightShowMessage.backgroundColor = [NSColor redColor];
        _ShowMessage.stringValue = @"各位,版本信息不对,否则会造成品质问题,谢谢";
        return;
    }
    _LeftShowMessage.backgroundColor = [NSColor greenColor];
    _RightShowMessage.backgroundColor = [NSColor greenColor];
    _ShowMessage.stringValue = @"各位,测试完毕,开始下一个设备的测试";
}

- (IBAction)m_Exit:(id)sender
{
    
}

- (IBAction)m_Modify:(id)sender
{
    if (_modify.state)
    {
        _DevicesNameKeyWords.editable = true;
    }
    else
    {
        _DevicesNameKeyWords.editable = false;
    }
}

- (IBAction)OnComboboxChanged:(id)sender
{
    NSInteger index_for_combox = [_ProductName indexOfSelectedItem];
    select_string_for_combox = [_ProductName itemObjectValueAtIndex:index_for_combox];
    NSLog(@"%@\n",select_string_for_combox);
}

@end

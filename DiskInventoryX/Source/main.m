//
//  main.m
//  Disk Accountant
//
//  Created by Tjark Derlien on Sun Oct 26 2003.
//  Copyright (c) 2003 Tjark Derlien. All rights reserved.
//

#import <Cocoa/Cocoa.h>

void OBInvokeAssertionFailureHandler(const char *type,
                                     const char *expression,
                                     const char *file,
                                     unsigned int lineNumber,
                                     NSString *fmt, ...)
{
    NSLog(@"[%s] %s:%i: %s", type, file, lineNumber, expression);
}

int main(int argc, const char *argv[])
{
    return NSApplicationMain(argc, argv);
}

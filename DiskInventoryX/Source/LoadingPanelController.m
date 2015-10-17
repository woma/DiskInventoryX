/*

 Copyright (c) 2015, Wolfram Manthey
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.

 */

#import "LoadingPanelController.h"

@interface LoadingPanelController ()
@property (assign) NSModalSession modalSession;
@property (readwrite) BOOL cancelled;
@end

#pragma mark -

@implementation LoadingPanelController

- (id)init
{
	if (self = [super initWithWindowNibName:@"LoadingPanel"])
    {
        [self.progressIndicator setUsesThreadedAnimation:NO];
    }
	return self;
}

- (IBAction)showWindow:(id)sender
{
    [super showWindow:sender];

    // begin modal session for the window
    self.modalSession = [NSApp beginModalSessionForWindow:self.window];
}

- (void)close
{
    // end modal session for the window
    [NSApp endModalSession:self.modalSession];

    [super close];
}

- (void)setMessageText:(NSString *)text
{
	self.textField.stringValue = text;
}

- (void)startAnimation:(id)sender
{
    [self.progressIndicator startAnimation:sender];
}

- (void)stopAnimation:(id)sender
{
    [self.progressIndicator stopAnimation:sender];
}

- (IBAction)cancel:(id)sender
{
	self.cancelled = YES;
	[self.cancelButton setEnabled:NO];
}

@end


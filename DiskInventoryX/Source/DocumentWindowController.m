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

#import "DocumentWindowController.h"

#import "Document.h"
#import "FileSystemItem.h"
#import "FileSizeTransformer.h"


@interface DocumentWindowController ()
@property (strong, nonatomic) FileSizeTransformer *fileSizeTransformer;
@end

#pragma mark -

@implementation DocumentWindowController

- (instancetype)init
{
    //register volume transformers needed in the volume tableview (before Nib is loaded!)
    [NSValueTransformer setValueTransformer:self.fileSizeTransformer forName: @"FileSizeTransformer"];
    return [super initWithWindowNibName:@"DocumentWindow"];
}

- (void)cancelFetching:(id)sender
{
    self.cancelFetchingButton.enabled = NO;
    [[(Document*)self.document rootItem] cancelFetching];
}

- (IBAction)openFile:(id)sender
{
    NSURL *fileURL = [[self.fileSystemItemController.selectedObjects firstObject] url];
    [[NSWorkspace sharedWorkspace] openURL:fileURL];
}

- (IBAction)showInFinder:(id)sender
{
    NSInteger row = [self.fileTreeView clickedRow];
    NSLog(@"Menu at %li", (long)row);

//    NSURL *fileURL = [[self.fileSystemItemController.selectedObjects firstObject] url];
//    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
}

@end

#pragma mark -

@implementation DocumentWindowController (NSWindowController)

- (void)windowDidLoad
{
    [super windowDidLoad];
    Document* document = self.document;

    if (![document.rootItem isFetched])
    {
        [self.window beginSheet:self.fetchingPanel completionHandler:nil];

        [document.rootItem addObserver:self forKeyPath:@"fetchingURL" options:nil context:NULL];
        [document.rootItem addObserver:self forKeyPath:@"fetched" options:nil context:NULL];
        [document.rootItem addObserver:self forKeyPath:@"cancelled" options:nil context:NULL];

        [document.rootItem fetchChilds];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    Document *document = self.document;

    if ([keyPath isEqualToString:@"fetchingURL"])
    {
        NSRunLoop *mainLoop = [NSRunLoop mainRunLoop];

        // update the current directory path, discard previous updates not handled yet
        [mainLoop cancelPerformSelectorsWithTarget:self.fetchingItemLabel];
        [mainLoop performSelector:@selector(setObjectValue:)
                           target:self.fetchingItemLabel
                         argument:document.rootItem.fetchingURL.path
                            order:1000
                            modes:@[NSDefaultRunLoopMode]];
    }
    else if ([keyPath isEqualToString:@"fetched"] || [keyPath isEqualToString:@"cancelled"])
    {
        [document.rootItem removeObserver:self forKeyPath:@"fetchingURL"];
        [document.rootItem removeObserver:self forKeyPath:@"fetched"];
        [document.rootItem removeObserver:self forKeyPath:@"cancelled"];

        [self.window performSelectorOnMainThread:@selector(endSheet:)
                                      withObject:self.fetchingPanel
                                   waitUntilDone:NO];


        [self.fileSystemItemController performSelectorOnMainThread:@selector(setContent:)
                                                        withObject:document.rootItem.children
                                                     waitUntilDone:NO];
    }
}

@end

#pragma mark - NSMenuDelegate implementation

@implementation DocumentWindowController (NSMenuDelegate)

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    NSInteger row = [self.fileTreeView clickedRow];
    NSLog(@"Menu at %li", (long)row);
}

@end

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

#import "Document.h"

#import "FileSystemItem.h"
#import "LoadingPanelController.h"

@implementation Document

+ (BOOL)autosavesInPlace { return NO; }

- (BOOL)readFromURL:(NSURL *)url
             ofType:(NSString *)type
              error:(NSError * _Nullable *)error
{
    self.progressController = [LoadingPanelController new];
    [self.progressController addObserver:self
                              forKeyPath:@"cancelled"
                                 options:NSKeyValueObservingOptionNew
                                 context:NULL];

    [self.progressController showWindow:nil];

    self.rootItem = [[FileSystemItem alloc] initWithURL:url];
    self.rootItem.delegate = self;
    [self.rootItem performSelectorInBackground:@selector(fetchChilds) withObject:nil];

    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context
{
    if (object == self.progressController && [keyPath isEqualToString:@"cancelled"])
    {
        [self.rootItem cancelFetching];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

#pragma mark -

@implementation Document (FileSystemItemDelegate)

- (void)fileSystemItem:(FileSystemItem *)fileSystemItem fetchingURL:(NSURL *)url
{
    [self.progressController performSelectorOnMainThread:@selector(setMessageText:)
                                              withObject:[url path]
                                           waitUntilDone:NO];
}

- (void)fileSystemItemDidStartFetching:(FileSystemItem *)fileSystemItem
{
    [self.progressController performSelectorOnMainThread:@selector(startAnimation:)
                                              withObject:self
                                           waitUntilDone:NO];
}

-(void)fileSystemItemDidStopFetching:(FileSystemItem *)fileSystemItem cancelled:(BOOL)cancelled
{
    [self.progressController performSelectorOnMainThread:@selector(close)
                                              withObject:nil
                                           waitUntilDone:NO];
}

@end

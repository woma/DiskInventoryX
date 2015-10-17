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

#import "FileSystemItem.h"

@interface FileSystemItem ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, strong) NSMutableArray<FileSystemItem *> *children;
@property (nonatomic, weak) FileSystemItem *parent;
@property (atomic, assign, getter=isFetching) BOOL fetching;
@property (atomic, assign, getter=isCancelled) BOOL cancelled;

@end

#pragma mark -

@implementation FileSystemItem

- (instancetype)initWithURL:(NSURL *)url
{
    if (self = [super init])
    {
        self.url = url;
    }
    return self;
}

- (BOOL)fetchChilds
{
    @synchronized(self)
    {
        if ([self isFetching]) { return NO; }

        self.fetching = YES;
        self.cancelled = NO;
    }

    if ([self.delegate respondsToSelector:@selector(fileSystemItemDidStartFetching:)])
    {
        [self.delegate fileSystemItemDidStartFetching:self];
    }

    self.children = [NSMutableArray<FileSystemItem*> new];

    // Create a local file manager instance
    NSFileManager *fileManager = [NSFileManager new];
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:self.url
                                             includingPropertiesForKeys:@[NSURLIsDirectoryKey,
                                                                          NSURLParentDirectoryURLKey]
                                                                options:0
                                                           errorHandler:nil];

    // Dictionary containing all found directories
    NSMutableDictionary<NSURL*, FileSystemItem*> *directories = [NSMutableDictionary new];
    [directories setObject:self forKey:self.url];

    for (NSURL *fetchedURL in dirEnumerator)
    {
        if ([self isCancelled]) { break; }

        FileSystemItem *fetchedItem = [[FileSystemItem alloc] initWithURL:fetchedURL];
        FileSystemItem *parentItem = [directories objectForKey:fetchedURL.parentURL];

        fetchedItem.parent = parentItem;
        fetchedItem.name = fetchedURL.name;
        fetchedItem.icon = fetchedURL.thumbnail;
        fetchedItem.size = fetchedURL.fileSize;

        [parentItem.children addObject:fetchedItem];

        // if fetched item is a directory add it to the list of directories
        if (fetchedURL.isDirectory)
        {
            [directories setObject:fetchedItem forKey:fetchedURL];

            if (parentItem && dirEnumerator.level < 4 &&
                [self.delegate respondsToSelector:@selector(fileSystemItem:fetchingURL:)])
            {
                [self.delegate fileSystemItem:self fetchingURL:parentItem.url];
            }
        }
    }

    if ([self.delegate respondsToSelector:@selector(fileSystemItemDidStopFetching:cancelled:)])
    {
        [self.delegate fileSystemItemDidStopFetching:self cancelled:self.cancelled];
    }

    self.fetching = NO;
    return YES;
}

- (void)cancelFetching
{
    self.cancelled = YES;
}

@end

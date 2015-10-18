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

- (void)fetch;

@property (nonatomic, assign, getter=isFetched) BOOL fetched;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, assign) NSUInteger size;

@property (nonatomic, weak) FileSystemItem *parent;
@property (nonatomic, strong) NSMutableArray<FileSystemItem *> *children;

@property (nonatomic, weak) NSURL *fetchingURL;
@property (nonatomic, weak) NSOperation *fetchingOperation;

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

- (void)fetchChilds
{
    NSOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                  selector:@selector(fetch)
                                                                    object:nil];
    self.fetchingOperation = operation;

    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
}

- (void)fetch
{
    self.children = [NSMutableArray<FileSystemItem*> new];

    // create a local file manager instance and enumerator
    NSFileManager *fileManager = [NSFileManager new];
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:self.url
                                             includingPropertiesForKeys:@[NSURLIsDirectoryKey,
                                                                          NSURLParentDirectoryURLKey,
                                                                          NSURLNameKey,
                                                                          NSURLFileSizeKey,
                                                                          NSURLThumbnailKey]
                                                                options:0
                                                           errorHandler:nil];

    // dictionary keeping references to all found directories
    NSMutableDictionary<NSURL*, FileSystemItem*> *dirCache = [NSMutableDictionary new];
    [dirCache setObject:self forKey:self.url];

    for (NSURL *fetchedURL in dirEnumerator)
    {
        if ([self.fetchingOperation isCancelled])
        {
            self.cancelled = YES;
            break;
        }

        FileSystemItem *fetchedItem = [[FileSystemItem alloc] initWithURL:fetchedURL];
        FileSystemItem *parentItem = [dirCache objectForKey:fetchedURL.parentURL];

        fetchedItem.parent = parentItem;
        fetchedItem.name = fetchedURL.name;
        fetchedItem.path = fetchedURL.path;
        fetchedItem.icon = [[NSWorkspace sharedWorkspace] iconForFile:fetchedURL.path];
        fetchedItem.size = fetchedURL.fileSize;

        [parentItem.children addObject:fetchedItem];

        // if fetched item is a directory add it to the list of all found directories
        if (fetchedURL.isDirectory)
        {
            fetchedItem.children = [NSMutableArray new];
            self.fetchingURL = fetchedURL;
            [dirCache setObject:fetchedItem forKey:fetchedURL];
        }
        // if fetched item is a file add it's size to all parent directories
        else
        {
            for (FileSystemItem *parentIterator = parentItem;
                 parentIterator;
                 parentIterator = parentIterator.parent)
            {
                 parentIterator.size += fetchedItem.size;
            }
        }
    }
    self.fetched = YES;
}

- (void)cancelFetching
{
    [self.fetchingOperation cancel];
}

@end

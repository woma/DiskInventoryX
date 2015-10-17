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

#import "VolumesPanelController.h"

#import "Volume.h"


@interface VolumesPanelController ()
- (void)reloadVolumes;
@property (strong, nonatomic) VolumeSizeTransformer *volumeSizeTransformer;
@end

#pragma mark -

@interface VolumesPanelController (Notifications)
- (void)volumeDidMount:(NSNotification *)notification;
- (void)volumeDidUnmount:(NSNotification *)notification;
@end

#pragma mark -

@implementation VolumesPanelController

+ (VolumesPanelController *)sharedController
{
    static VolumesPanelController *controller = nil;
    return controller ? controller : (controller = [VolumesPanelController new]);
}

- (id)init
{
    if (self = [super init])
    {
        //register volume transformers needed in the volume tableview (before Nib is loaded!)
        [NSValueTransformer setValueTransformer:self.volumeSizeTransformer forName: @"VolumeSizeTransformer"];

        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(volumeDidMount:)
                                                                   name:NSWorkspaceDidMountNotification
                                                                 object:nil];

        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                               selector:@selector(volumeDidUnmount:)
                                                                   name:NSWorkspaceDidUnmountNotification                                                                 object:nil];

        // load Nib with volume panel
        if ([NSBundle loadNibNamed: @"VolumesPanel" owner: self]) {
            [self reloadVolumes];
        }
        else { self = nil; }
    }
    return self;
}

- (void)reloadVolumes
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSURL*> *volumeURLs = [fm mountedVolumeURLsIncludingResourceValuesForKeys:nil
                                                                              options:NSVolumeEnumerationSkipHiddenVolumes];

    NSRange range = NSMakeRange(0, [[self.volumesController arrangedObjects] count]);
    [self.volumesController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];

    for (NSURL *volumeURL in volumeURLs)
    {
        [self.volumesController addObject:[Volume volumeWithURL:volumeURL]];
    }
}

- (IBAction)openVolume:(id)sender
{
    Volume *selectedVolume = [[self.volumesController selectedObjects] firstObject];

    [[NSRunLoop currentRunLoop] performSelector:@selector(openDocumentWithContentsOfURL:)
                                         target: [NSDocumentController sharedDocumentController]
                                       argument: selectedVolume.url
                                          order: 1
                                          modes: [NSArray arrayWithObject: NSDefaultRunLoopMode]];
}

@end

#pragma mark -

@implementation VolumesPanelController (Notifications)

- (void)volumeDidMount:(NSNotification *)notification
{
    NSURL *mountedVolumeURL = [[notification userInfo] valueForKey:@"NSWorkspaceVolumeURLKey"];
    [self.volumesController addObject:[Volume volumeWithURL:mountedVolumeURL]];
}

- (void)volumeDidUnmount:(NSNotification *)notification
{
    NSURL *mountedVolumeURL = [[notification userInfo] valueForKey:@"NSWorkspaceVolumeURLKey"];
    [self.volumesController removeObject:[Volume volumeWithURL:mountedVolumeURL]];
}

@end

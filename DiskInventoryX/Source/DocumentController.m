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

#import "DocumentController.h"

#import "VolumesPanelController.h"
#import "Preferences.h"
#import "PrefsPanelController.h"


//global variable which enables/disables logging
BOOL g_EnableLogging;


@implementation DocumentController

- (NSInteger)runModalOpenPanel:(NSOpenPanel*)openPanel forTypes:(NSArray*)extensions
{
    //we want the user to choose a directory (including packages)
    [openPanel setCanChooseDirectories: YES];
    [openPanel setCanChooseFiles: NO];
    [openPanel setTreatsFilePackagesAsDirectories: YES];
	
	return [openPanel runModal];
}

- (void)openDocumentWithContentsOfURL:(NSURL *)url;
{
    [self openDocumentWithContentsOfURL:url
                                display:NO
                      completionHandler:^(NSDocument * _Nullable document,
                                          BOOL documentWasAlreadyOpen,
                                          NSError * _Nullable error)
     {}];
}

- (BOOL) applicationShouldOpenUntitledFile: (NSApplication*) sender
{
    //we don't want any untitled document as we need an existing folder
    return NO;
}

//- (NSDocument *)makeDocumentWithContentsOfURL:(NSURL *)absoluteURL
//                                               ofType:(NSString *)typeName
//                                                error:(NSError * _Nullable *)outError
//{
//    NSLog(@"");
//    return nil;
//}


//- (id)makeDocumentWithContentsOfFile:(NSString *)fileName ofType:(NSString *)docType
//{
//	//check whether "fileName" is a folder
//	NSDictionary *attribs = [[NSFileManager defaultManager] fileAttributesAtPath: fileName traverseLink: NO];
//    if ( attribs != nil )
//	{
//		NSString *type = [attribs fileType];
//        if ( type != nil && [type isEqualToString: NSFileTypeDirectory] ) {
//			id test = [super makeDocumentWithContentsOfFile:fileName ofType: @"Folder"];
//            return test;
//        }
//	}
//	
//	return nil;
//}

//"Open..." menu handler
//- (IBAction)openDocument:(id)sender
//{
//	//we implement this method by ourself, so we can avoid that stupid message "document couldn't be opened"
//	//in the case the user canceled the opening
//    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
//    [openPanel runModal];
//    return;
//
//    NSArray *fileNames;
//	if ( fileNames == nil )
//		return; //cancel pressed in open panel
//	
//	NSEnumerator *enumerator = [fileNames objectEnumerator];
//	NSString *fileName;
//	while ( fileName = [enumerator nextObject] )
//	{
//		[self openDocumentWithContentsOfFile: fileName display: YES];
//	}
//}

- (BOOL)application:(NSApplication*)theApp openFile:(NSString*)filePath
{
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    NSNumber *isDirectory;
    [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];

    if (![isDirectory boolValue]) {
        return NO;
    }

    [self openDocumentWithContentsOfURL:fileURL
                                display:NO
                      completionHandler:^(NSDocument * _Nullable document,
                                          BOOL documentWasAlreadyOpen,
                                          NSError * _Nullable error)
     {}];
	
	return TRUE;
}


- (NSString *)typeForContentsOfURL:(NSURL *)url error:(NSError * _Nullable *)outError
{
    NSString *value;
    [url getResourceValue:&value forKey:NSURLFileResourceTypeKey error:nil];

    return [value isEqualToString:NSURLFileResourceTypeDirectory] ? (NSString *)kUTTypeDirectory : nil;
}

- (IBAction) showPreferencesPanel: (id) sender
{
//	[[PrefsPanelController sharedPreferenceController] showPreferencesPanel: self];
	//[[OAPreferenceController sharedPreferenceController] showPreferencesPanel: self];
}

- (IBAction)gotoHomepage:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://www.derlien.com"]];
}

- (IBAction) closeDonationPanel: (id) sender;
{
	[_donationPanel close]; //will release itself
	_donationPanel = nil;
}


#pragma mark --------app notifications-----------------

- (void)applicationWillFinishLaunching:(NSNotification*)notification
{
    //verify that our custom DocumentController is in use 
    NSAssert( [[NSDocumentController sharedDocumentController] isKindOfClass:[DocumentController class]], @"the shared DocumentController is not our custom class!" );
	
	g_EnableLogging = [[NSUserDefaults standardUserDefaults] boolForKey: EnableLogging];
	
	//show the drives panel before "applicationDidFinishLaunching" so the panel is visible before the first document is loaded
	//(e.g. through drag&drop)
	[[VolumesPanelController sharedController] showWindow:self];
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification
{
	//show donate message
	if ( ![[NSUserDefaults standardUserDefaults] boolForKey: DontShowDonationMessage] )
	{
		[NSBundle loadNibNamed: @"DonationPanel" owner:self];
		[_donationPanel setWorksWhenModal: YES];
	}
	
//	DIXFinderCMInstaller *installer = [DIXFinderCMInstaller installer];
//	if ( ![installer isInstalled] )
//		[installer installToDomain: kUserDomain];
}

#pragma mark -----------------NSMenu delegates-----------------------

//- (void) menuNeedsUpdate: (NSMenu*) zoomStackMenu
//{
//	OBPRECONDITION( _zoomStackMenu == zoomStackMenu );
//	
//	FileSystemDoc *doc = [self currentDocument];
//	NSArray *zoomStack = [doc zoomStack];
//	
//	//thanks to ObjC, [zoomStack count] will evaluate to 0 if there is no current doc
//	unsigned i;
//	for ( i = 0; i < [zoomStack count]; i++ )
//	{
//		FSItem *fsItem = nil;
//		if ( i == 0 )
//			fsItem = [doc rootItem];
//		else
//			fsItem = [zoomStack objectAtIndex: i-1];
//		
//		if ( i >= [zoomStackMenu numberOfItems] )
//			[zoomStackMenu addItem:[NSMenuItem new]];
//		
//		NSMenuItem *menuItem = [zoomStackMenu itemAtIndex: i];
//		
//		[menuItem setTitle: [fsItem displayName]];
//		[menuItem setRepresentedObject: fsItem];
//		[menuItem setTarget: nil];
//		[menuItem setAction: @selector(zoomOutTo:)];
//	}
//	
//	while ( [zoomStackMenu numberOfItems] > [zoomStack count] )
//		[zoomStackMenu removeItemAtIndex: [zoomStackMenu numberOfItems] -1];
//}

@end


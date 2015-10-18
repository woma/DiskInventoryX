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

#import "Volume.h"


@implementation Volume

+ (instancetype)volumeWithURL:(NSURL*)url
{
    return [[Volume alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL*)url;
{
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

- (NSString *)name
{
    NSString *name;
    [self.url getResourceValue:&name forKey:NSURLVolumeNameKey error:nil];
    return name;
}

- (NSString *)format
{
    NSString *format;
    [self.url getResourceValue:&format forKey:NSURLVolumeLocalizedFormatDescriptionKey error:nil];
    return format;
}

- (NSUInteger)totalCapacity
{
    NSNumber *totalCapacity;
    [self.url getResourceValue:&totalCapacity forKey:NSURLVolumeTotalCapacityKey error:nil];
    return [totalCapacity unsignedIntegerValue];
}

- (NSImage *)icon
{
    NSImage *icon;
    [self.url getResourceValue:&icon forKey:NSURLEffectiveIconKey error:nil];
    return icon;
}

- (NSUInteger)freeCapacity
{
    NSNumber *freeCapacity;
    [self.url getResourceValue:&freeCapacity forKey:NSURLVolumeAvailableCapacityKey error:nil];
    return [freeCapacity unsignedIntegerValue];
}

- (NSUInteger)usedCapacity
{
    return self.totalCapacity - self.freeCapacity;
}

#pragma mark - NSObject implementation

- (NSUInteger)hash
{
    return self.url.hash;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[self class]] && [self.url isEqual:[object url]];
}

@end

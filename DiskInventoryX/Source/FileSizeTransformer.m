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

#import "FileSizeTransformer.h"

@implementation FileSizeTransformer

+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value
{
    if (value && ![value isKindOfClass:[NSNumber class]])
    {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) is not kind of NSNumber.", [value class]];
    }

    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.locale = [NSLocale currentLocale];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = 1;

    if ([value integerValue] > 1e9) {
        NSNumber *number = [NSNumber numberWithFloat:[value floatValue] / 1e9];
        return [NSString stringWithFormat:@"%@ GB", [numberFormatter stringFromNumber:number]];
    }
    else if ([value integerValue] > 1e6) {
        NSNumber *number = [NSNumber numberWithFloat:[value floatValue] / 1e6];
        return [NSString stringWithFormat:@"%@ MB", [numberFormatter stringFromNumber:number]];
    }
    else if ([value integerValue] > 1e4) {
        NSNumber *number = [NSNumber numberWithFloat:[value floatValue] / 1e3];
        return [NSString stringWithFormat:@"%@ KB", [numberFormatter stringFromNumber:number]];
    }

    return [NSString stringWithFormat:@"%@ Byte", [numberFormatter stringFromNumber:value]];
}

@end

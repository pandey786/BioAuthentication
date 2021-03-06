// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license.
//
// Microsoft Cognitive Services (formerly Project Oxford): https://www.microsoft.com/cognitive-services
//
// Microsoft Cognitive Services (formerly Project Oxford) GitHub:
// https://github.com/Microsoft/Cognitive-Face-iOS
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "PersonGroup.h"

@implementation PersonGroup

- (instancetype) init {
    self = [super init];
    _people = [[NSMutableArray alloc] init];
    _groupName = @"";
    return self;
}

- (instancetype) initWithGroupName: (id)name {
    self = [self init];
    self.groupName = name;
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.groupName forKey:@"groupName"];
    [encoder encodeObject:self.people forKey:@"people"];
    [encoder encodeObject:self.groupId forKey:@"groupId"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.groupName = [decoder decodeObjectForKey:@"groupName"];
        self.groupId = [decoder decodeObjectForKey:@"groupId"];
        self.people = [decoder decodeObjectForKey:@"people"];
    }
    return self;
}

@end

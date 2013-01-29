//
//  RIModel+Private.h
//  DropboxSample
//
//  Created by Ali Gadzhiev on 1/29/13.
//  Copyright (c) 2013 Red Iron. All rights reserved.
//

#import "RIModel.h"

@interface RIModel (Private)

@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, readwrite, getter = isLoaded) BOOL loaded;

@end

//
//  macros.h
//  Paldaruo
//
//  Created by Apiau on 11/09/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#ifndef Paldaruo_macros_h
#define Paldaruo_macros_h


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

#endif

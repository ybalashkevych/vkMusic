//
//  BYUtils.h
//  vkMusiс
//
//  Created by George on 12.03.15.
//  Copyright (c) 2015 George. All rights reserved.
//

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

typedef enum {
    
    BYMenuSongList,
    BYMenuFavorites,
    BYMenuPlaylist,
    BYMenuSearch,
    BYMenuSettings
    
} BYMenu;
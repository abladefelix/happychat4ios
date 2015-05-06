//
//  SuperDB.h
//  super
//
//  Created by Donal on 14-7-25.
//  Copyright (c) 2014年 super. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tool.h"
#import <FMDB/FMDB.h>

#define DraftSql @"CREATE TABLE  if not exists [tb_draft]('_id' INTEGER PRIMARY KEY AUTOINCREMENT,'draft_title' varchar(30) NOT NULL DEFAULT '','draft_content' MEDIUMTEXT NOT NULL DEFAULT '','draft_html' MEDIUMTEXT NOT NULL DEFAULT '','file_list' TEXT NOT NULL DEFAULT '','media_json' TEXT NOT NULL DEFAULT '','file_state' INTEGER NOT NULL DEFAULT 0 ,'is_pub' INTEGER NOT NULL DEFAULT 0 ,'is_comment' INTEGER NOT NULL DEFAULT 0 ,'time' varchar(10) NOT NULL DEFAULT '', 'tid' varchar(10) NOT NULL DEFAULT '', 'commentid' varchar(10) NOT NULL DEFAULT '');"

#define Friend_Role_Friend @"1"
#define Friend_Role_Stranger @"2"

@interface SuperDB : NSObject

+(void)createDataFile;

#pragma mark 构造recentId也就是conversationId
+(NSString *)generateRecentIdOrConversationId:(NSString *)target;

#pragma mark 构造client_key
+(NSString *)generateClientKey:(NSString *)target;

+(void)createDraftDatabase;

+(NSString *)saveDraftTitle:(NSString *)title
               draftContent:(NSString *)content
                  draftHtml:(NSString *)html
                 mediaFiles:(NSString *)mediaFiles
                  mediaJson:(NSString *)mediaJson
                  isComment:(int)isComment
                        tid:(NSString *)tid
                  commentid:(NSString *)commentId;

+(NSArray *)getUnPubDraft;

+(BOOL)updateDraftBy:(NSString *)draftId
      withDraftTitle:(NSString *)title
        draftContent:(NSString *)content
           draftHtml:(NSString *)html
          mediaFiles:(NSString *)mediaFiles
           mediaJson:(NSString *)mediaJson;

+(NSDictionary *)getPubDraftByID:(NSString *)draftId;

+(BOOL)updateDraftFileUploadedBy:(NSString *)draftId;

+(BOOL)updateDraftPubedBy:(NSString *)draftId;
@end

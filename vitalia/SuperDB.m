//
//  SuperDB.m
//  super
//
//  Created by Donal on 14-7-25.
//  Copyright (c) 2014年 super. All rights reserved.
//

#import "SuperDB.h"

@implementation SuperDB

#pragma mark 构造recentId也就是conversationId
+(NSString *)generateRecentIdOrConversationId:(NSString *)target
{
    return [Tool getMd5_32Bit_String:[NSString stringWithFormat:@"%@-%@", target, getUserID]];
}

#pragma mark 构造client_key
+(NSString *)generateClientKey:(NSString *)target
{
    return [Tool getMd5_32Bit_String:[NSString stringWithFormat:@"%@-%@-%ld", target, getUserID, (long)[NSDate date]]];
}

#pragma mark init
+(NSString*)getDataFilePathWithName:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:name];
    return path;
}

+(void)createDataFile
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self getDataFilePathWithName:@"record"]] == NO) {
        [fileManager createDirectoryAtPath:[self getDataFilePathWithName:@"record"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([fileManager fileExistsAtPath:[self getDataFilePathWithName:@"CompressedPhoto"]] == NO) {
        [fileManager createDirectoryAtPath:[self getDataFilePathWithName:@"CompressedPhoto"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([fileManager fileExistsAtPath:[self getDataFilePathWithName:@"JsonData"]] == NO) {
        [fileManager createDirectoryAtPath:[self getDataFilePathWithName:@"JsonData"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self createDraftDatabase];
}

+(void)createDraftDatabase
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        return;
    };
    FMDBQuickCheck([db executeUpdate:DraftSql]);
}

+(NSString *)saveDraftTitle:(NSString *)title
               draftContent:(NSString *)content
                  draftHtml:(NSString *)html
                 mediaFiles:(NSString *)mediaFiles
                  mediaJson:(NSString *)mediaJson
                  isComment:(int)isComment
                        tid:(NSString *)tid
                  commentid:(NSString *)commentId
{
    NSString *draftid = @"";
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        return @"";
    };
    BOOL worked;
    NSString *insertStr=@"replace INTO [tb_draft] ([draft_title], [draft_content], [draft_html], [file_list], [media_json], [time], [is_comment], [tid], [commentid]) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
    worked      = [db executeUpdate:insertStr, title, content, html, mediaFiles, mediaJson, [Tool getTimeStamp], [NSNumber numberWithInt:isComment], tid, commentId];
    if (worked) {
        NSString *sql ;
        FMResultSet *rs ;
        sql = @"SELECT * from tb_draft where is_pub=0 order by time desc";
        rs = [db executeQuery:sql];
        if ([rs next]) {
            draftid = [NSString stringWithFormat:@"%i", [rs intForColumn:@"_id"]];
        }
    }
    FMDBQuickCheck(worked);
    [db close];
    return draftid;
}

+(NSArray *)getUnPubDraft
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    [db open];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([db open]) {
        NSString *sql ;
        FMResultSet *rs ;
        sql = @"SELECT * from tb_draft where is_pub=0 order by time desc";
        rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *draftid = [NSString stringWithFormat:@"%i", [rs intForColumn:@"_id"]];
            NSString *title = [rs stringForColumn:@"draft_title"];
            NSString *draft_content = [rs stringForColumn:@"draft_content"];
            NSString *draft_html = [rs stringForColumn:@"draft_html"];
            NSString *file_list = [rs stringForColumn:@"file_list"];
            NSString *media_json = [rs stringForColumn:@"media_json"];
            NSString *time = [rs stringForColumn:@"time"];
            NSString *fileState = [NSString stringWithFormat:@"%i", [rs intForColumn:@"file_state"]];
            NSString *isComment = [NSString stringWithFormat:@"%i", [rs intForColumn:@"is_comment"]];
            NSString *tid = [rs stringForColumn:@"tid"];
            NSString *commentId = [rs stringForColumn:@"commentid"];
            NSDictionary *draftDictionary = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title",draftid, @"draftid", draft_content, @"content", draft_html, @"html", file_list, @"files", media_json, @"json", time, @"time", fileState, @"filestate", isComment, @"is_comment", tid, @"tid", commentId, @"commentid", nil];
            [array addObject:draftDictionary];
        }
        [db close];
    }
    return array;
}

+(BOOL)updateDraftBy:(NSString *)draftId
      withDraftTitle:(NSString *)title
        draftContent:(NSString *)content
           draftHtml:(NSString *)html
          mediaFiles:(NSString *)mediaFiles
           mediaJson:(NSString *)mediaJson
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        return NO;
    };
    BOOL worked;
    NSString *insertStr=@"update [tb_draft] set draft_title=?, draft_content=?, draft_html=?, file_list=?, media_json=?, time=?, file_state=0 where _id=?;";
    worked      = [db executeUpdate:insertStr, title, content, html, mediaFiles, mediaJson, [Tool getTimeStamp], [NSNumber numberWithInt:[draftId intValue]]];
    FMDBQuickCheck(worked);
    [db close];
    return worked;
}

+(NSDictionary *)getPubDraftByID:(NSString *)draftId
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    [db open];
    NSDictionary *draftDictionary;
    if ([db open]) {
        NSString *sql ;
        FMResultSet *rs ;
        sql = [NSString stringWithFormat:@"SELECT * from tb_draft where _id=%@", draftId];
        rs = [db executeQuery:sql];
        if ([rs next]) {
            NSString *draftid = [NSString stringWithFormat:@"%i", [rs intForColumn:@"_id"]];
            NSString *title = [rs stringForColumn:@"draft_title"];
            NSString *draft_content = [rs stringForColumn:@"draft_content"];
            NSString *draft_html = [rs stringForColumn:@"draft_html"];
            NSString *file_list = [rs stringForColumn:@"file_list"];
            NSString *media_json = [rs stringForColumn:@"media_json"];
            NSString *time = [rs stringForColumn:@"time"];
            NSString *fileState = [NSString stringWithFormat:@"%i", [rs intForColumn:@"file_state"]];
            NSString *isComment = [NSString stringWithFormat:@"%i", [rs intForColumn:@"is_comment"]];
            NSString *tid = [rs stringForColumn:@"tid"];
            NSString *commentId = [rs stringForColumn:@"commentid"];
            draftDictionary = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title",draftid, @"draftid", draft_content, @"content", draft_html, @"html", file_list, @"files", media_json, @"json", time, @"time", fileState, @"filestate", isComment, @"is_comment", tid, @"tid", commentId, @"commentid", nil];
        }
        [db close];
    }
    return draftDictionary;
}

+(BOOL)updateDraftFileUploadedBy:(NSString *)draftId
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        return NO;
    };
    BOOL worked;
    NSString *insertStr=@"update [tb_draft] set file_state=1 where _id=?;";
    worked      = [db executeUpdate:insertStr, [NSNumber numberWithInt:[draftId intValue]]];
    FMDBQuickCheck(worked);
    [db close];
    return worked;
}

+(BOOL)updateDraftPubedBy:(NSString *)draftId
{
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        return NO;
    };
    BOOL worked;
    NSString *insertStr=@"update [tb_draft] set is_pub=1 where _id=?;";
    worked      = [db executeUpdate:insertStr, [NSNumber numberWithInt:[draftId intValue]]];
    FMDBQuickCheck(worked);
    [db close];
    return worked;
}

@end

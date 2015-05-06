//
//  MutilMediaEditTableViewCell.m
//  vitalia
//
//  Created by Donal on 15/3/10.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "MutilMediaEditTableViewCell.h"

@interface MutilMediaEditTableViewCell() <UITextViewDelegate>

@end

@implementation MutilMediaEditTableViewCell

- (void)awakeFromNib {
    self.picDesTextView.delegate = self;
    self.onlyTextView.delegate = self;
    self.onlyTextView.placeholder = @"输入内容";
    self.picDesTextView.placeholder = @"请输入图片描述";
    self.picDesTextView.scrollsToTop = NO;
    self.onlyTextView.scrollsToTop = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setMedia:(MediaPubEdit *)edit atIndex:(NSInteger)index
{
    self.currentIndex = index;
    self.currentMedia = edit;
}

-(void)textViewDidChange:(UITextView *)textView
{
    self.currentMedia.mediaContent = textView.text.trim;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    [self.delegate scroolToCellAtIndex:self.currentIndex];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    textView.inputView = nil;
    [textView.inputView reloadInputViews];
}

- (IBAction)removeMedia:(id)sender {
    [self.delegate removeMediaAtIndex:self.currentIndex];
}
@end

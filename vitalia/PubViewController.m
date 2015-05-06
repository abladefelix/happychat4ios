//
//  PubViewController.m
//  vitalia
//
//  Created by Donal on 15/3/10.
//  Copyright (c) 2015年 ginye. All rights reserved.
//

#import "PubViewController.h"
#import "MutilMediaEditTableViewCell.h"
#import "PhotoGroupTableViewController.h"
#import "PubTitleView.h"
#import "SuperDB.h"
#import "DXFaceView.h"
#import "GTMBase64.h"

@interface PubViewController ()<UITableViewDataSource, UITableViewDelegate, PhotoGroupTableViewControllerDelegate, MutilMediaEditTableViewCellDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DXFaceDelegate>
{
    NSMutableArray *medias;
    NSInteger currentCellFoucusIndex;
    BOOL isTitleFoucus;
}
@property (strong, nonatomic) PubTitleView *pubTitleView;
@property (weak, nonatomic) IBOutlet UIButton *hideKeyButton;
/**
 *  表情的附加页面
 */
@property (strong, nonatomic) UIView *faceView;

@end

@implementation PubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pubTitleView = [[PubTitleView alloc] initWithNib];
    [self.pubTableView registerNib:[UINib nibWithNibName:@"MutilMediaEditTableViewCell" bundle:nil] forCellReuseIdentifier:@"MediaCell"];
    self.pubTitleView.height = 40;
    self.pubTableView.tableHeaderView.height = 40;
    self.pubTitleView.titleTextField.delegate = self;
    [self.pubTitleView.titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    medias = [NSMutableArray array];
    if (self.operation == OPRATION_NEW) {
        MediaPubEdit *m = [[MediaPubEdit alloc] init];
        m.mediaType = MEDIA_TEXT;
        m.mediaContent = @"";
        m.mediaUrl = @"";
        [medias addObject:m];
    }
    else {
        self.pubTitleView.titleTextField.text = [self.draft objectForKey:@"title"];
        NSString *jsonString = [self.draft objectForKey:@"json"];
        id json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        for (NSDictionary *dic in json) {
            MediaPubEdit *m = [[MediaPubEdit alloc] init];
            m.mediaType = [dic objectForKey:@"media_type"];
            m.mediaContent = [dic objectForKey:@"media_content"];
            m.mediaUrl = [dic objectForKey:@"media_url"];
            m.duration = [dic objectForKey:@"duration"];
            [medias addObject:m];
        }
        MediaPubEdit *lastM = medias.lastObject;
        if (![lastM.mediaType isEqual:MEDIA_TEXT]) {
            MediaPubEdit *m = [[MediaPubEdit alloc] init];
            m.mediaType = MEDIA_TEXT;
            m.mediaContent = @"";
            m.mediaUrl = @"";
            [medias addObject:m];
        }
    }
    
    if (self.type == TYPE_COMMENT) {
        
    }
    else {
        [self.pubTableView setTableHeaderView:self.pubTitleView];
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(pubShare)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self performSelector:@selector(becomeFirst) withObject:nil afterDelay:0.2];
    
    if (!self.faceView) {
        self.faceView = [[DXFaceView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 220)];
        [(DXFaceView *)self.faceView setDelegate:self];
        self.faceView.backgroundColor = UIColorFromRGB(0xcfcdcd, 1.0);
        self.faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
}

-(void)becomeFirst
{
    isTitleFoucus = YES;
    [self.pubTitleView.titleTextField becomeFirstResponder];
}

-(void)pubShare
{
    NSMutableArray *json = [NSMutableArray array];
    NSMutableArray *files = [NSMutableArray array];
    NSString *draftContent = @"";
    NSString *draftTitle = self.pubTitleView.titleTextField.text;
    NSString *html = @"";
    if (self.type == TYPE_SHARE && [draftTitle trim].length == 0) {
        return;
    }
    MediaPubEdit *m0 = medias[0];
    if ([m0.mediaType isEqualToString:MEDIA_TEXT] && [m0.mediaContent trim].length == 0) {
        return;
    }
    for (MediaPubEdit *media in medias) {
        if ([media.mediaType isEqual:MEDIA_TEXT]) {
            if (media.mediaContent.length > 0) {
                NSDictionary *MediaDictionary = [NSDictionary dictionaryWithObjectsAndKeys:MEDIA_TEXT, @"media_type", media.mediaContent, @"media_content", media.mediaUrl, @"media_url", @"", @"duration",@"", @"qiniuKey", nil];
                [json addObject:MediaDictionary];
                draftContent = [draftContent stringByAppendingString:media.mediaContent];
                html = [html stringByAppendingString:[NSString stringWithFormat:@"%@<br/>", media.mediaContent]];
            }
            
        }
        else if ([media.mediaType isEqual:MEDIA_IMAGE]) {
            media.mediaContent = [media.mediaContent replaceAll:@"(" with:@""];
            media.mediaContent = [media.mediaContent replaceAll:@")" with:@""];
            NSDictionary *MediaDictionary = [NSDictionary dictionaryWithObjectsAndKeys:MEDIA_IMAGE, @"media_type", media.mediaContent, @"media_content", media.mediaUrl, @"media_url", @"", @"duration", media.qiniuKey, @"qiniuKey", nil];
            [json addObject:MediaDictionary];
            
            NSDictionary *fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:MEDIA_IMAGE, @"media_type", media.mediaContent, @"media_content", [NSString stringWithFormat:@"%@%@",QINIU_PREFIX, media.qiniuKey], @"media_url", @"", @"duration", nil];
            [files addObject:fileDictionary];
            draftContent = [draftContent stringByAppendingString:@"[图片]"];
            html = [html stringByAppendingString:[NSString stringWithFormat:@"<img src=\"%@%@%@\" title=\"%@\"><br/>", QINIU_PREFIX, media.qiniuKey, [NSString stringWithFormat:@"?watermark/1/image/%@", [GTMBase64 stringByWebSafeEncodingData:[@"http://www.b1.qiniudn.com/images/logo-2.png" dataUsingEncoding:NSUTF8StringEncoding] padded:true ]], media.mediaContent]];
        }
    }
    NSString *jsonString = [[NSString alloc] initWithData:[Tool jsonFromObject:json] encoding:NSUTF8StringEncoding];
    NSString *fileString = [[NSString alloc] initWithData:[Tool jsonFromObject:files] encoding:NSUTF8StringEncoding];
    
    if (self.operation == OPRATION_NEW) {
        NSString *draftId =[SuperDB saveDraftTitle:draftTitle
                                      draftContent:draftContent
                                         draftHtml:html
                                        mediaFiles:fileString
                                         mediaJson:jsonString
                                         isComment:self.type
                                               tid:self.tid
                                         commentid:self.commentId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"draft" object:draftId];
    }
    else {
        [SuperDB updateDraftBy:[self.draft objectForKey:@"draftid"]
                withDraftTitle:draftTitle
                  draftContent:draftContent
                     draftHtml:html
                    mediaFiles:fileString
                     mediaJson:jsonString];
        [self.delegate editDraftSuccess];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"draft" object:[self.draft objectForKey:@"draftid"]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark listen keyboard
-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary*info=[notification userInfo];
    CGSize kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    [self adjustToolbarViewByKeyboard:kbSize.height];
}

-(void)keyboardWillHide:(NSNotification*)notification{
    self.operationView.bottom = screenframe.size.height;
    [self setTableViewInsetsWithBottomValue:self.pubTableView.height
     - self.operationView.frame.origin.y];
    self.hideKeyButton.hidden = YES;
}

-(void)adjustToolbarViewByKeyboard:(float)height
{
    self.hideKeyButton.hidden = NO;
    self.operationView.bottom = screenframe.size.height - height;
    [self setTableViewInsetsWithBottomValue:self.pubTableView.height
     - self.operationView.frame.origin.y];
    [self performSelector:@selector(scroolTabel:) withObject:[NSString stringWithFormat:@"%ld", currentCellFoucusIndex] afterDelay:0.1];
}

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.pubTableView.contentInset = insets;
    self.pubTableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = self.topLayoutGuide.length;
    }
    
    insets.bottom = bottom;
    
    return insets;
}

- (IBAction)showFace:(id)sender {
    self.faceButton.selected = !self.faceButton.selected;
    if (self.faceButton.selected ) {
        [self setFaceKeyborad];
    } else {

        [self setSystemKeyboard];
    }
}

-(void)setSystemKeyboard
{
    if (isTitleFoucus) {
        self.pubTitleView.titleTextField.inputView = nil;
        [self.pubTitleView.titleTextField reloadInputViews];
    }
    else {
        MutilMediaEditTableViewCell *cell = (MutilMediaEditTableViewCell *)[self.pubTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentCellFoucusIndex inSection:0]];
        MediaPubEdit *m = medias[currentCellFoucusIndex];
        if ([m.mediaType isEqualToString:MEDIA_TEXT]) {
            cell.onlyTextView.inputView = nil;
            [cell.onlyTextView reloadInputViews];
        }
        else {
            cell.picDesTextView.inputView = nil;
            [cell.picDesTextView reloadInputViews];
        }
    }
}


-(void)setFaceKeyborad
{
    [((DXFaceView *)self.faceView)._facialView.faceScroolView setContentOffset:CGPointZero];;
    [((DXFaceView *)self.faceView)._facialView.pageControl setCurrentPage:0];;
    if (isTitleFoucus) {
        self.pubTitleView.titleTextField.inputView = self.faceView;
        [self.pubTitleView.titleTextField reloadInputViews];
        [self.pubTitleView.titleTextField becomeFirstResponder];
    }
    else {
        MutilMediaEditTableViewCell *cell = (MutilMediaEditTableViewCell *)[self.pubTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentCellFoucusIndex inSection:0]];
        MediaPubEdit *m = medias[currentCellFoucusIndex];
        
        if ([m.mediaType isEqualToString:MEDIA_TEXT]) {
            cell.onlyTextView.inputView = self.faceView;
            [cell.onlyTextView reloadInputViews];
            [cell.onlyTextView becomeFirstResponder];
        }
        else {
            cell.picDesTextView.inputView = self.faceView;
            [cell.picDesTextView reloadInputViews];
            [cell.picDesTextView becomeFirstResponder];
        }
    }
}

- (IBAction)takeCamera:(id)sender {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)showPhotoLibrary:(id)sender {
    PhotoGroupTableViewController *vc = [[PhotoGroupTableViewController alloc] init];
    vc.delegate = self;
    vc.MaxCount = 20;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:NO completion:nil];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
    self.hideKeyButton.hidden = YES;
    self.faceButton.selected = NO;
}

#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    int width = image.size.width;
    int height = image.size.height;
    int contentImageHeight = height * 250 / width;
    UIImage *imageResize = [Tool imageWithImageSimple:image scaledToSize:CGSizeMake(250, contentImageHeight)];
    [self saveImage:imageResize];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image {
    long a = [[NSDate date] timeIntervalSince1970];
    NSString *imagePath = [Tool imageSavedPath:[NSString stringWithFormat:@"%ld.png", a]];
    BOOL isSaveSuccess = [Tool saveToDocument:image withFilePath:imagePath];
    if (isSaveSuccess) {
        MediaPubEdit *lastMedia = [medias lastObject];
        if (lastMedia.mediaContent.trim.length==0 && [lastMedia.mediaType isEqual:MEDIA_TEXT]) {
            [medias removeObject:lastMedia];
        }
        MediaPubEdit *m = [[MediaPubEdit alloc] init];
        m.mediaUrl = imagePath;
        m.mediaContent = @"";
        m.mediaType = MEDIA_IMAGE;
        m.qiniuKey = [NSString stringWithFormat:@"community/%@.png", [Tool getMd5_16Bit_String:m.mediaUrl]];
        [medias addObject:m];
        
        MediaPubEdit *nm = [[MediaPubEdit alloc] init];
        nm.mediaType = MEDIA_TEXT;
        nm.mediaContent = @"";
        nm.mediaUrl = @"";
        [medias addObject:nm];
        [self.pubTableView reloadData];
        [self scroolToCellAtIndex:medias.count-1];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"保存图片失败" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)getPhotos:(NSArray *)photos
{
    [self dismissViewControllerAnimated:NO completion:nil];
    MediaPubEdit *lastMedia = [medias lastObject];
    if (lastMedia.mediaContent.trim.length==0 && [lastMedia.mediaType isEqual:MEDIA_TEXT]) {
        [medias removeObject:lastMedia];
    }
    for (NSString *path in photos) {
        MediaPubEdit *m = [[MediaPubEdit alloc] init];
        m.mediaUrl = path;
        m.mediaContent = @"";
        m.mediaType = MEDIA_IMAGE;
        m.qiniuKey = [NSString stringWithFormat:@"community/%@.png", [Tool getMd5_16Bit_String:m.mediaUrl]];
        [medias addObject:m];
    }
    MediaPubEdit *nm = [[MediaPubEdit alloc] init];
    nm.mediaType = MEDIA_TEXT;
    nm.mediaContent = @"";
    nm.mediaUrl = @"";
    [medias addObject:nm];
    [self.pubTableView reloadData];
    [self scroolToCellAtIndex:medias.count-1];
}

#pragma mark tableview delegate begin
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return medias.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    CellIdentifier = @"MediaCell";
    MutilMediaEditTableViewCell *cell = (MutilMediaEditTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MediaPubEdit *mediaPub = medias[indexPath.row];
    if ([mediaPub.mediaType isEqual:MEDIA_TEXT]) {
        cell.picDesTextView.hidden = YES;
        cell.picImageView.hidden = YES;
        cell.onlyTextView.hidden = NO;
        cell.onlyTextView.text = mediaPub.mediaContent;
    }
    else if ([mediaPub.mediaType isEqual:MEDIA_IMAGE]) {
        cell.picDesTextView.hidden = NO;
        cell.picImageView.hidden = NO;
        cell.onlyTextView.hidden = YES;
        cell.picDesTextView.text = mediaPub.mediaContent;
        [cell.picImageView setImage:[UIImage imageWithContentsOfFile:mediaPub.mediaUrl]];
    }
    [cell setMedia:mediaPub atIndex:indexPath.row];
    cell.delegate = self;
    if (indexPath.row == (medias.count-1)) {
        cell.removeButton.hidden = YES;
    }
    else {
        cell.removeButton.hidden = NO;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark tableview delegate end

#pragma mark MutilMediaEditTableViewCellDelegate begin
-(void)scroolToCellAtIndex:(NSInteger)index
{
    isTitleFoucus = NO;
    currentCellFoucusIndex = index;
    self.faceButton.selected = NO;
    MutilMediaEditTableViewCell *cell = (MutilMediaEditTableViewCell *)[self.pubTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentCellFoucusIndex inSection:0]];
    MediaPubEdit *m = medias[currentCellFoucusIndex];
    if ([m.mediaType isEqualToString:MEDIA_TEXT]) {
        if (cell.onlyTextView.inputView == self.faceView) {
            self.faceButton.selected = YES;
        }
    }
    else {
        if (cell.picDesTextView.inputView == self.faceView) {
            self.faceButton.selected = YES;
        }
    }
    [self performSelector:@selector(scroolTabel:) withObject:[NSString stringWithFormat:@"%ld", index] afterDelay:0.1];
}

-(void)scroolTabel:(NSString *)index
{
    [self.pubTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[index integerValue] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void)removeMediaAtIndex:(NSInteger)index
{
    [medias removeObjectAtIndex:index];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self.pubTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationLeft];
    [self.pubTableView reloadData];
}
#pragma mark uitextfield delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.pubTableView scrollsToTop];
    isTitleFoucus = YES;
    self.faceButton.selected = NO;
    if (self.pubTitleView.titleTextField.inputView == self.faceView) {
        self.faceButton.selected = YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.inputView = nil;
    [textField.inputView reloadInputViews];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 30) {
                textField.text = [toBeString substringToIndex:30];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 30) {
            textField.text = [toBeString substringToIndex:30];
        }
    }
}

#pragma mark faceview delegate

-(void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    if (isTitleFoucus) {
        if (isDelete) {
            [self.pubTitleView.titleTextField deleteBackward];
        }
        else {
            [self.pubTitleView.titleTextField insertText:str];
        }
    }
    else {
        MutilMediaEditTableViewCell *cell = (MutilMediaEditTableViewCell *)[self.pubTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentCellFoucusIndex inSection:0]];
        MediaPubEdit *m = medias[currentCellFoucusIndex];
        UITextView *inputTextView;
        if ([m.mediaType isEqualToString:MEDIA_TEXT]) {
            inputTextView = cell.onlyTextView;
        }
        else {
            inputTextView = cell.picDesTextView;
        }
        if (isDelete) {
            [inputTextView deleteBackward];
        }
        else {
            [inputTextView insertText:str];
        }
    }
}

@end

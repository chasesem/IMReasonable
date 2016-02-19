//
//  WeChatTableViewCell.m
//  KeyBoard
//
//  Created by apple on 15/6/1.
//  Copyright (c) 2015年 Reasonable. All rights reserved.
//



#define CELL_HEIGTH 186
#define OFFSET 20
#define TIME_H 50//时间的高度
#define VOICE_H 76//语音高度(对方发的)
#define VOICE_H_M 56//我发的语音高度

#import "WeChatTableViewCell.h"
#import "MessageContent.h"
#import "VoiceContent.h"
#import "PictureContent.h"
#import "TQRichTextView.h"
#import "WeChat.h"
#import "Tool.h"
#import "UIImageView+WebCache.h"

@implementation WeChatTableViewCell {
    //头像
    UIImageView* _userPhoto;
    //文本内容
    MessageContent* _messageContent;

    //语音消息
    VoiceContent* _voiceContent;

    //图片消息
    PictureContent* _pictureContent;
    //时间与提示
    UILabel* _timeAndTips;

    UIImageView* reSend;
    BOOL isRoom;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }

    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
    [self.contentView addGestureRecognizer:longPressGesture];
    return self;
}

- (void)cellLongPress:(UIGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {

        [self becomeFirstResponder];

        NSMutableArray* tempmenu = [[NSMutableArray alloc] init];
        //        "lbAcopy"="複製";
        //        "lbAdelete"="刪除";
        //        "lbAForward"="轉發";
        //        "lbAalbum"="保存到相冊";

        if (_messagemode.type == MessageTypeText) {
            UIMenuItem* itCopy = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"lbAcopy", nil) action:@selector(handleCopyCell:)];
            UIMenuItem* itDelete = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"lbAdelete", nil) action:@selector(handleDeleteCell:)];
            UIMenuItem* itForward = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"lbAForward", nil) action:@selector(handleForwardCell:)];

            [tempmenu addObject:itCopy];
            [tempmenu addObject:itDelete];
            [tempmenu addObject:itForward];
        }

        if (_messagemode.type == MessageTypePicture) {

            UIMenuItem* itDelete = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"lbAdelete", nil) action:@selector(handleDeleteCell:)];
            UIMenuItem* itForward = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"lbAForward", nil) action:@selector(handleForwardCell:)];
            UIMenuItem* itSavePhoto = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"lbAalbum", nil) action:@selector(handleSavePhotoCell:)];
            [tempmenu addObject:itDelete];
            [tempmenu addObject:itForward];
            [tempmenu addObject:itSavePhoto];
        }
        UIMenuController* menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:tempmenu];
        [menu setTargetRect:self.bounds inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(handleCopyCell:)) {
        return YES;
    }
    else if (action == @selector(handleDeleteCell:)) {
        return YES;
    }
    else if (action == @selector(handleSavePhotoCell:)) {
        return YES;
    }
    else if (action == @selector(handleForwardCell:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}
- (void)handleCopyCell:(id)sender
{ //复制cell
    NSLog(@"handle copy cell");
    [UIPasteboard generalPasteboard].string = _messagemode.content;
}

- (void)handleDeleteCell:(id)sender
{ //删除cell
    NSLog(@"handle delete cell");

    [self.delegate acDeteleMessage:_messagemode];
}

- (void)handleForwardCell:(id)sender
{ //转发
    NSLog(@"handleForwardcell");
    [self.delegate acForwardMessage:_messagemode];
}
- (void)handleSavePhotoCell:(id)sender
{ //保存图片到相册

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* ImageURL1 = [_messagemode.content stringByReplacingOccurrencesOfString:@"Small" withString:@""];
        NSString* path = [Tool Append:IMReasonableAPPImagePath witnstring:ImageURL1];
        NSURL* url = [NSURL URLWithString:path];

        SDWebImageManager* manage = [SDWebImageManager sharedManager];
        [manage downloadImageWithURL:url
                             options:SDWebImageContinueInBackground
                            progress:nil
                           completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished, NSURL* imageURL) {

                               if (!error) {
                                   UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
                               }
                               else {
                                   UIImageView* tempimg = (UIImageView*)[_pictureContent viewWithTag:200];
                                   UIImageWriteToSavedPhotosAlbum(tempimg.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
                               }

                           }];

    });
}

- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    NSString* message = @"呵呵";
    if (!error) {
        message = NSLocalizedString(@"SAVE_TO_ALBUM", nil);
    }
    else {
        message = [error description];
    }

    [Tool alert:message];
    NSLog(@"%@", message);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)setMessagemode:(MessageModel*)messagemode isNeedName:(BOOL)isName
{

    _messagemode = messagemode;
    _userPhoto = nil;
    _messageContent = nil;
    _timeAndTips = nil;
    _voiceContent = nil;
    _pictureContent = nil;

    isRoom = isName;

    switch (messagemode.type) {
    case MessageTypeTime: { //当要显示时间
        [self initTimeViewControl];
    } break;
    case MessageTypePicture: { //图片消息
        [self initPictureViewControl];
        [self dealwithPicture];
    } break;
    case MessageTypeTips: { //消息提示
        [self initTimeViewControl];
    } break;
    case MessageTypeVoice: { //声音消息
        [self initVoiceViewControl];
        [self dealwithVoice];
    } break;
    case MessageTypeText: { //文本消息

        [self initTxtViewControl];
        [self dealwithText];

    } break;

    default:
        break;
    }
}

//文本处理
- (void)initTxtViewControl
{
    _messageContent = [[MessageContent alloc] init];
    _messageContent.delegate = self;
    [self.contentView addSubview:_messageContent];
}
- (void)dealwithText
{

    if (!_messagemode.content) {
        return;
    }
    CGRect rect = [TQRichTextView boundingRectWithSize:CGSizeMake(_ScreenWidth - 100, MAXFLOAT) font:[UIFont systemFontOfSize:MESSAGECONNECTSIZE] string:self.messagemode.content lineSpace:2.0f];

    if (self.messagemode.isFromMe) {
        CGFloat width = rect.size.width > 45 ? rect.size.width : 45;
        width += 15 + 2;
        _messageContent.frame = CGRectMake(_ScreenWidth - USERPHOTOOFFSET - width - 5, USERPHOTOOFFSET / 2, width, rect.size.height + 10 + 2);
        if ([_messagemode.isNeedSend isEqualToString:@"0"] && [_messagemode.isReceived isEqualToString:@"0"]) {
            reSend = [[UIImageView alloc] init];
            [self setGesRec];
            reSend.frame = CGRectMake(_messageContent.frame.origin.x - 25, _messageContent.frame.size.height - 20, 20, 20);
        }
    }
    else {
        //计算名字的宽度

        CGSize namesize = CGSizeMake(0, 0);
        CGFloat offset = 0;
        if (isRoom) {
            offset = 20;
            UIFont* font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
            NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary* attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle.copy };
            namesize = [self.messagemode.username boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        }

        CGFloat width = namesize.width > rect.size.width ? namesize.width : rect.size.width + 10;
        width += 20;

        _messageContent.frame = CGRectMake(USERPHOTOOFFSET + 5, USERPHOTOOFFSET / 2, width > 45 ? width : 45, rect.size.height + offset + 10 + 2);
    }

    [_messageContent setMessagemode:self.messagemode isNeedName:isRoom];
}
//提示和时间处理
- (void)initTimeViewControl
{

    UIFont* font = [UIFont systemFontOfSize:TIMEANDTIPSFONTSIZE];
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary* attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle.copy };
    CGSize timeSize = [self.messagemode.content boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    CGFloat width = timeSize.width < 100 ? 100 : timeSize.width;

    CGRect rect = CGRectMake((_ScreenWidth - width) / 2, (TIME_H-timeSize.height)/2, width, timeSize.height);
    _timeAndTips = [[UILabel alloc] initWithFrame:rect];
    _timeAndTips.backgroundColor = [UIColor colorWithRed:232.0 / 255 green:225.0 / 255 blue:215.0 / 255 alpha:1];
    _timeAndTips.textAlignment = NSTextAlignmentCenter;
    _timeAndTips.textColor = [UIColor grayColor];
    _timeAndTips.layer.masksToBounds = YES;
    _timeAndTips.layer.cornerRadius = 5;
    _timeAndTips.font = [UIFont systemFontOfSize:TIMEANDTIPSFONTSIZE];
    _timeAndTips.text = self.messagemode.content;
    [self.contentView addSubview:_timeAndTips];
}
//处理语音消息
- (void)initVoiceViewControl
{
    _voiceContent = [[VoiceContent alloc] init];
    [self.contentView addSubview:_voiceContent];
}
- (void)dealwithVoice
{
    if (self.messagemode.isFromMe) {
        _voiceContent.frame = CGRectMake(_ScreenWidth - USERPHOTOOFFSET - 120 - 5, (VOICE_H-40)/2, 120, 40);
        if ([_messagemode.isNeedSend isEqualToString:@"0"] && [_messagemode.isReceived isEqualToString:@"0"]) {
            reSend = [[UIImageView alloc] init];
            [self setGesRec];
            reSend.frame = CGRectMake(_voiceContent.frame.origin.x - 25, (VOICE_H-20)/2, 20, 20);
        }
    }
    else {
        _voiceContent.frame = CGRectMake(USERPHOTOOFFSET + 5, (VOICE_H-40)/2, 120, 40);
//        _voiceContent.frame=_voiceContent.voiceframe;
    }

    [_voiceContent setMessagemode:self.messagemode isNeedName:isRoom];
}

//处理图片消息
- (void)initPictureViewControl
{
    _pictureContent = [[PictureContent alloc] init];
    _pictureContent.delegate = self;
    [self.contentView addSubview:_pictureContent];
}


- (void)dealwithPicture
{
    
    if (self.messagemode.isFromMe) {
        UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:_messagemode.content]];
        //自己发送的就是本地图片
        if (tempimg) {
            float imagewidth = 140;
            float imageheight = 140;
            float tempwidth = tempimg.size.width;
            float tempheight = tempimg.size.height;
            if (tempwidth > tempheight) {
                
                BOOL flag = tempwidth > (_ScreenWidth - 150) ? true : false;
                imagewidth = flag ? (_ScreenWidth - 150) : tempwidth;
                imageheight = flag ? ((_ScreenWidth - 100) / tempwidth) * tempimg.size.height : tempimg.size.height;
            }
            else {
                
                float zh = tempimg.size.width / tempimg.size.height;
                imagewidth = 140 * zh > (_ScreenWidth - 150) ? 140.0 : 140 * zh;
            }
            _pictureContent.frame = CGRectMake(_ScreenWidth-IMAGE_WIDTH-MARGEN, USERPHOTOOFFSET / 2, IMAGE_WIDTH, IMAGE_HEIGHT);
            
            if ([_messagemode.isNeedSend isEqualToString:@"0"] && [_messagemode.isReceived isEqualToString:@"0"]) {
                reSend = [[UIImageView alloc] init];
                [self setGesRec];
                reSend.frame = CGRectMake(_pictureContent.frame.origin.x - 25, _pictureContent.frame.size.height - 20, 20, 20);
            }
        }
        else {
            _pictureContent.hidden = YES;
        }
    }
    else {
        //计算名字的宽度
        CGFloat offset = 0;
        if (isRoom) {
            offset = 20;
        }
        
        CGFloat width = 140;
        
        width += 15;
        _pictureContent.frame = CGRectMake(MARGEN, USERPHOTOOFFSET / 2, IMAGE_WIDTH, IMAGE_HEIGHT+OFFSET);
    }
    [_pictureContent setMessagemode:self.messagemode isNeedName:isRoom];
}

#pragma mark -设置头像

- (void)SetPohoto
{
    if (self.messagemode.isFromMe) {
        NSString* imagename = [[NSUserDefaults standardUserDefaults] objectForKey:XMPPMYFACE];
        UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:imagename]];
        tempimg = tempimg ? tempimg : [UIImage imageNamed:@"default"];
        _userPhoto.image = tempimg;
    }
    else {

        UIImage* tempimg = [UIImage imageWithContentsOfFile:[Tool getFilePathFromDoc:self.messagemode.faceurl]];
        tempimg = tempimg ? tempimg : [UIImage imageNamed:@"default"];
        _userPhoto.image = tempimg;
    }
}

#pragma mark -设置重发手势
- (void)setGesRec
{
    reSend.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reSendMessage:)];
    [reSend addGestureRecognizer:tap];
    reSend.image = [UIImage imageNamed:@"Alert7"];
    [self.contentView addSubview:reSend];
}

- (void)reSendMessage:(id)sender
{
    [self.delegate reSendMessage:self.messagemode];
}

//获取cell的实际高度
+ (CGFloat)getCellHeight:(MessageModel*)messagemode isNeedName:(BOOL)isName
{
    CGFloat cellheight = 0;
    switch (messagemode.type) {
    case MessageTypeTime: { //当要显示时间
        cellheight = TIME_H;
    } break;
    case MessageTypePicture: { //图片消息
        return [WeChatTableViewCell getPictureHeight:messagemode];
    } break;
    case MessageTypeTips: { //消息提示
        cellheight = 20;
    } break;
    case MessageTypeVoice: { //声音消息
        cellheight = messagemode.isFromMe?VOICE_H_M:VOICE_H;
    } break;
    case MessageTypeText: { //文本消息
        cellheight = [WeChatTableViewCell getTextHeight:messagemode isNeedName:isName];
    } break;

    default:
        break;
    }
    return cellheight;
}

+ (CGFloat)getPictureHeight:(MessageModel*)messagemode
{
    
    return messagemode.isFromMe?CELL_HEIGTH:CELL_HEIGTH+20;
}

+ (CGFloat)getTextHeight:(MessageModel*)messagemode isNeedName:(BOOL)isName
{

    if (!messagemode.content) {
        return 0;
    }
    CGRect rect = [TQRichTextView boundingRectWithSize:CGSizeMake(_ScreenWidth - 100, MAXFLOAT) font:[UIFont systemFontOfSize:MESSAGECONNECTSIZE] string:messagemode.content lineSpace:2.0f];
    if (messagemode.isFromMe) {
        CGFloat height = rect.size.height + 20;
        return height; //>60?height:60;
    }
    else {

        CGFloat height = rect.size.height + 20;
        if (isName) {
            height += 20;
        }

        return height; //>60?height:60;
    }
}

#pragma mark -内容协议
- (void)touchMessageContent:(NSString*)content withType:(TouchContentType)type
{
    [self.delegate touchMessageContent:content withType:type];
}

- (void)touchPictureContent:(UIImageView*)imgV MessageModle:(MessageModel*)modle
{
    [self.delegate touchPictureContent:modle tableviewcell:self   ImageView:imgV];
}
- (void)dealloc
{
    _messageContent.delegate = nil;
    _pictureContent.delegate = nil;
}

@end

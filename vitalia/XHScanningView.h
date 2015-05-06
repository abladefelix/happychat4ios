//
//  XHScanningView.h
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XHScanningStyle) {
    XHScanningStyleQRCode = 0,
    XHScanningStyleBook,
    XHScanningStyleStreet,
    XHScanningStyleWord,
};

@interface XHScanningView : UIView

@property (nonatomic, assign, readonly) XHScanningStyle scanningStyle;

-(void)scanning;
- (void)transformScanningTypeWithStyle:(XHScanningStyle)style;

@end

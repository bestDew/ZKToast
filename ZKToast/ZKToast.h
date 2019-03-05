//
//  ZKToast.h
//  ZKToastDemo
//
//  Created by bestdew on 2018/12/5.
//  Copyright © 2018 bestdew. All rights reserved.
//
//                      d*##$.
// zP"""""$e.           $"    $o
//4$       '$          $"      $
//'$        '$        J$       $F
// 'b        $k       $>       $
//  $k        $r     J$       d$
//  '$         $     $"       $~
//   '$        "$   '$E       $
//    $         $L   $"      $F ...
//     $.       4B   $      $$$*"""*b
//     '$        $.  $$     $$      $F
//      "$       R$  $F     $"      $
//       $k      ?$ u*     dF      .$
//       ^$.      $$"     z$      u$$$$e
//        #$b             $E.dW@e$"    ?$
//         #$           .o$$# d$$$$c    ?F
//          $      .d$$#" . zo$>   #$r .uF
//          $L .u$*"      $&$$$k   .$$d$$F
//           $$"            ""^"$$$P"$P9$
//          JP              .o$$$$u:$P $$
//          $          ..ue$"      ""  $"
//         d$          $F              $
//         $$     ....udE             4B
//          #$    """"` $r            @$
//           ^$L        '$            $F
//             RN        4N           $
//              *$b                  d$
//               $$k                 $F
//               $$b                $F
//                 $""               $F
//                 '$                $
//                  $L               $
//                  '$               $
//                   $               $

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZKToastVerticalPosition) {
    ZKToastVerticalPositionCenter  = 0, // default vertical position, show in the center of the screen
    ZKToastVerticalPositionTop,         // show in top of the screen, and top padding is 90.f
    ZKToastVerticalPositionBottom       // show in bottom of the screen, and bottom padding is 85.f
};

@interface ZKToast : NSObject

+ (void)setMinimumSize:(CGSize)minimumSize;                     // default is CGSizeMake(100.f, 30.f)
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval; // default is 2 seconds
+ (void)setTextFont:(UIFont *)font;                             // default is [UIFont systemFontOfSize:14.f]
+ (void)setTextColor:(UIColor *)color;                          // default is [UIColor whiteColor]
+ (void)setVerticalPosition:(ZKToastVerticalPosition)position;  // default is ZKToastVerticalPositionCenter
+ (void)setBackgroundColor:(UIColor *)bgColor;                  // default is [UIColor blackColor]
+ (void)setCornerRadius:(CGFloat)cornerRadius;                  // default is 15.f
+ (void)setShadowColor:(UIColor *)color;                        // default is [UIColor blackColor]
+ (void)setShadowOffset:(CGSize)size;                           // default is CGSizeZero
+ (void)setShadowOpacity:(CGFloat)opacity;                      // default is 0.7

+ (void)showWithStatus:(NSString *)status;
+ (void)dismiss;

@end

UIKIT_EXTERN NSString * const ZKToastWillAppearNotification;
UIKIT_EXTERN NSString * const ZKToastDidAppearNotification;
UIKIT_EXTERN NSString * const ZKToastWillDisappearNotification;
UIKIT_EXTERN NSString * const ZKToastDidDisappearNotification;
UIKIT_EXTERN NSString * const ZKToastStatusUserInfoKey;

//
//  SwiftFramework.h
//  SwiftFramework
//
//  Created by apple on 26/03/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//! Project version number for SwiftFramework.
FOUNDATION_EXPORT double SwiftFrameworkVersionNumber;

//! Project version string for SwiftFramework.
FOUNDATION_EXPORT const unsigned char SwiftFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftFramework/PublicHeader.h>

@protocol PresenterDelegate <NSObject>

- (void)showAlertWithTitle:(NSString *)title;
- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                buttonName:(NSString *)buttonName
                completion:(void (^)(BOOL))completion;

@end

@protocol OnboardingDelegate <NSObject>

- (void)startOnboardingWithTitle:(NSString *)title
                        subtitle:(NSString *)subtitle
                     buttonTitle:(NSString *)buttonTitle
                    buttonTitle1:(NSString *)buttonTitle1
                          imgUrl:(NSString *)imgUrl
                      completion:(void (^)(BOOL, NSString *))completion;

@end

@protocol StopRequestDelegate <NSObject>

- (void)stopRequestWithTitle:(NSString *)title
                    subtitle:(NSString *)subtitle
              backroundColor:(NSString *)backgroundColor
                   textColor:(NSString *)textColor
                     message:(NSString *)message
                      imgURL:(NSString *)imgURL
                  completion:(void (^)(BOOL, NSString *))completion;

@end

@protocol SosRequestDelegate <NSObject>

- (void)sosRequestWithTitle:(NSString *)title
                   subtitle:(NSString *)subtitle
             backroundColor:(NSString *)backgroundColor
                  textColor:(NSString *)textColor
                    message:(NSString *)message
                     imgURL:(NSString *)imgURL
                 completion:(void (^)(BOOL, NSString *))completion;

@end

@protocol QRRequestDelegate <NSObject>

- (void)QRGenerationWithTicketStatus:(NSString *)ticketStatus
                             ticketId:(NSString *)ticketId
                            expiryDate:(NSString *)expiryDate
                            totalCount:(NSString *)totalCount
                        startColorHex:(NSString *)startColorHex
                          endColorHex:(NSString *)endColorHex
                         textColorHex:(NSString *)textColorHex;

@end

@protocol NeedPermissionDelegate <NSObject>

- (void)needPermissionWithTitle:(NSString *)title
                        subTitle:(NSString *)subTitle
                     description:(NSString *)description
                      completion:(void (^)(BOOL, NSString *))completion;

@end

@protocol TicketValidationDelegate <NSObject>

- (BOOL)addTicketsWithTicketID:(NSInteger)ticketID
                     ticketName:(NSString *)ticketName
                    ticketCount:(NSInteger)ticketCount
                 purchasedTicket:(NSString *)purchasedTicket
                      expiryDate:(NSString *)expiryDate
                     ticketStatus:(NSInteger)ticketStatus;

- (NSArray<NSDictionary *> *)getTickets;
- (BOOL)changeStatusWithTicketId:(NSInteger)ticketId
                           status:(NSInteger)status;

@end

@protocol BearonRangingDelegate <NSObject>

- (void)startRangingBeaconsWithIbeaconStatus:(NSInteger)ibeaconStatus
                                   macAddress:(NSString *)macAddress
                                        major:(NSInteger)major
                                        minor:(NSInteger)minor;

@end

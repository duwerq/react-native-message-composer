//
//  RNMessageComposer.m
//  RNMessageComposer
//
//  Created by Matthew Knight on 06/05/2015.
//  Copyright (c) 2015 Anarchic Knight. All rights reserved.
//

#import "RNMessageComposer.h"
#import "RCTConvert.h"
#import <MessageUI/MessageUI.h>

@interface RNMessageComposer() <MFMessageComposeViewControllerDelegate>

@end

@implementation RNMessageComposer
{
    NSMutableArray *composeViews;
    NSMutableArray *composeCallbacks;
    BOOL presentAnimated;
    BOOL dismissAnimated;
}

- (NSDictionary *)constantsToExport
{
//
//  RNMessageComposer.m
//  RNMessageComposer
//
//  Created by Matthew Knight on 06/05/2015.
//  Copyright (c) 2015 Anarchic Knight. All rights reserved.
//

#import "RNMessageComposer.h"
#import "RCTConvert.h"
#import <MessageUI/MessageUI.h>
#import <ContactsUI/ContactsUI.h>

@interface RNMessageComposer() <MFMessageComposeViewControllerDelegate>

@end

@implementation RNMessageComposer
{
    NSMutableArray *composeViews;
    NSMutableArray *composeCallbacks;
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"Sent": @"sent",
             @"Cancelled": @"cancelled",
             @"Failed": @"failed",
             @"NotSupported": @"notsupported"
             };
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        composeCallbacks = [[NSMutableArray alloc] init];
        composeViews = [[NSMutableArray alloc] init];
    }
    return self;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(messagingSupported:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNumber numberWithBool:[MFMessageComposeViewController canSendText]]]);
}

RCT_EXPORT_METHOD(composeMessageWithArgs:(NSDictionary *)args callback:(RCTResponseSenderBlock)callback)
{
    // check the device can actually send messages - return from method if not supported
    if(![MFMessageComposeViewController canSendText])
    {
        callback(@[@"notsupported"]);
        return;
    }
    
    MFMessageComposeViewController *mcvc = [[MFMessageComposeViewController alloc] init];
    mcvc.messageComposeDelegate = self;
    
    if(args[@"recipients"])
    {
        // check that recipients was passed as an NSArray
        if([args[@"recipients"] isKindOfClass:[NSArray class]])
        {
            NSArray *recipients = args[@"recipients"];
            if(recipients.count > 0)
            {
                NSMutableArray *validRecipientTypes = [[NSMutableArray alloc] init];
                
                // Check type of each item in NSArray and only use it if it was provided as an NSString.
                // We could be more lenient here and just use RCTConvert on all values even if not
                // provided as NSString originally. For now I prefer being more strict.
                for(id recipient in recipients)
                {
                    if([recipient isKindOfClass:[NSString class]])
                    {
                        [validRecipientTypes addObject:recipient];
                    }
                }
                if(validRecipientTypes.count != 0)
                {
                    mcvc.recipients = validRecipientTypes;
                }
                else
                {
                    RCTLog(@"You provided a recipients array but it did not contain any valid argument types");
                }
            }
            else
            {
                RCTLog(@"You provided a recipients array but it was empty. No values to add");
            }
        }
        else
        {
            RCTLog(@"recipients must be supplied as an array. Ignoring the values provided");
        }
    }
    
    // check to see if messages support subjects - if they do check if a subject has been supplied
    if([MFMessageComposeViewController canSendSubject])
    {
        if(args[@"subject"])
        {
            mcvc.subject = [RCTConvert NSString:args[@"subject"]];
        }
    }
    
    if(args[@"messageText"])
    {
        mcvc.body = [RCTConvert NSString:args[@"messageText"]];
    }
    
 
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
   
  
    if(args[@"attachments"])
    {
        
        


            if(args[@"attachments"] && args[@"attachments"][@"photoURL"])    
            {
                NSString *photoURL = [RCTConvert NSString:args[@"attachments"][@"photoURL"]];
                
                NSString *photoName = [RCTConvert NSString:args[@"attachments"][@"photoName"]];
                
                NSData * photoData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:photoURL]];
                
                NSString *imageID = @"kUTTypeJPEG";

                if([args[@"attachments"][@"photoType"] isEqualToString:@"png"]) {
                    imageID = @"kUTTypePNG";
                } else if([args[@"attachments"][@"photoType"] isEqualToString:@"gif"]) {
                    imageID = @"kUTTypeGIF";
                }

                [mcvc addAttachmentData:photoData typeIdentifier:imageID filename:photoName];
                NSLog(@"PHOTO");
            }
        
        
     
        
            if(args[@"attachments"] && args[@"attachments"][@"contactInfo"])
            {
            
                NSLog(@"CONTACT INFO =", args[@"attachments"] && args[@"attachments"][@"contactInfo"]);
                CNMutableContact *contact = [CNMutableContact new];
                
                if (args[@"attachments"][@"contactInfo"][@"givenName"] == (id)[NSNull null] ) {
                    
                } else {
                    
                    contact.givenName = [RCTConvert NSString:args[@"attachments"][@"contactInfo"][@"givenName"]];
                }

                contact.contactType = CNContactTypePerson;

                if (args[@"attachments"][@"contactInfo"][@"conactInfo"] == (id)[NSNull null] ) {
                    
                } else {
                    contact.familyName = [RCTConvert NSString:args[@"attachments"][@"contactInfo"][@"familyName"]];
                }

                if (args[@"attachments"][@"contactInfo"][@"jobTitle"] == (id)[NSNull null] ) {
                    
                } else {
                    contact.jobTitle = [RCTConvert NSString:args[@"attachments"][@"contactInfo"][@"jobTitle"]];
                }

                //contact.emailAddresses = [RCTConvert NSString:args[@"attachments"][@"contactInfo"][@"email"]];


                //phoneNumbers
                if (args[@"attachments"][@"contactInfo"][@"phoneNumber"]) {
                    
                    
                    NSString * phoneNumber = [RCTConvert NSString:args[@"attachments"][@"contactInfo"][@"phoneNumber"]];
                    
                    CNPhoneNumber *digits = [CNPhoneNumber phoneNumberWithStringValue:phoneNumber];
                    
                    CNLabeledValue * fullNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMain value:digits];
                    
                    NSMutableArray *validPhoneNumber = [[NSMutableArray alloc] init];
                    
                    [validPhoneNumber addObject:fullNumber];
                    
                    contact.phoneNumbers = validPhoneNumber;
                }

                //email

                if (args[@"attachments"][@"contactInfo"][@"emailAddresses"] == (id)[NSNull null] ) {
                    
                } else {
                   
                    NSLog(@"EMAIL" );
                    CNLabeledValue * email = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[RCTConvert NSString:args[@"attachments"][@"contactInfo"][@"emailAddresses"]]];
                    
                     NSMutableArray *allEmails = [[NSMutableArray alloc] init];

                    [allEmails addObject:email];

                    contact.emailAddresses = allEmails;
                }

                NSString *contactURL = [RCTConvert NSString:args[@"attachments"][@"photoURL"]];
                
                NSLog(@"Contact photo");
                
                NSData * contactData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:contactURL]];
                NSLog(@"%@", contactData);

                
             

                

                NSArray *array = [[NSArray alloc] initWithObjects:contact, nil];
                NSData *bufferedData = [CNContactVCardSerialization dataWithContacts:array error:nil];
                
                NSString* vcString = [[NSString alloc] initWithData:bufferedData encoding:NSUTF8StringEncoding];
                NSString* base64Image = [contactData base64EncodedStringWithOptions:0];
                NSString* vcardImageString = [[@"PHOTO;TYPE=JPEG;ENCODING=BASE64:" stringByAppendingString:base64Image] stringByAppendingString:@"\n"];
                vcString = [vcString stringByReplacingOccurrencesOfString:@"END:VCARD" withString:[vcardImageString stringByAppendingString:@"END:VCARD"]];
                bufferedData = [vcString dataUsingEncoding:NSUTF8StringEncoding];

               
                NSString *contactName = [RCTConvert NSString:args[@"attachments"][@"contactName"]];
        

                NSString *vcardID = @"kUTTypeVCard"; 
        
        
        
                [mcvc addAttachmentData:bufferedData typeIdentifier:vcardID filename:contactName];
                NSLog(@"CONTACT", contactName);
            }
        
        
    }
    
   
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
        dispatch_sync(dispatch_get_main_queue(), ^{
        [vc presentViewController:mcvc animated:YES completion:nil];          

        });
    });
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"The code sends the text!");

        [composeViews addObject:mcvc];
        [composeCallbacks addObject:callback];
    });
}   

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSUInteger index = [composeViews indexOfObject:controller];
    RCTAssert(index != NSNotFound, @"Dismissed view controller was not recognised");
    RCTResponseSenderBlock callback = composeCallbacks[index];
    
    switch (result) {
        case MessageComposeResultCancelled:
            callback(@[@"cancelled"]);
            break;
        case MessageComposeResultFailed:
            callback(@[@"failed"]);
            break;
        case MessageComposeResultSent:
            callback(@[@"sent"]);
            break;
        default:
            break;
    }
    NSLog(@"The code runs through here!");
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc dismissViewControllerAnimated:YES completion:nil];
    
    [composeViews removeObjectAtIndex:index];
    [composeCallbacks removeObjectAtIndex:index];
}

@end

            {
                NSMutableArray *validRecipientTypes = [[NSMutableArray alloc] init];
                
                // Check type of each item in NSArray and only use it if it was provided as an NSString.
                // We could be more lenient here and just use RCTConvert on all values even if not
                // provided as NSString originally. For now I prefer being more strict.
                for(id recipient in recipients)
                {
                    if([recipient isKindOfClass:[NSString class]])
                    {
                        [validRecipientTypes addObject:recipient];
                    }
                }
                if(validRecipientTypes.count != 0)
                {
                    mcvc.recipients = validRecipientTypes;
                }
                else
                {
                    RCTLog(@"You provided a recipients array but it did not contain any valid argument types");
                }
            }
            else
            {
                RCTLog(@"You provided a recipients array but it was empty. No values to add");
            }
        }
        else
        {
            RCTLog(@"recipients must be supplied as an array. Ignoring the values provided");
        }
    }
    
    // check to see if messages support subjects - if they do check if a subject has been supplied
    if([MFMessageComposeViewController canSendSubject])
    {
        if(args[@"subject"])
        {
            mcvc.subject = [RCTConvert NSString:args[@"subject"]];
        }
    }
    
    if(args[@"messageText"])
    {
        mcvc.body = [RCTConvert NSString:args[@"messageText"]];
    }

    if(args[@"presentAnimated"])
    {
        presentAnimated = [RCTConvert BOOL:args[@"presentAnimated"]];
    }

    if(args[@"dismissAnimated"])
    {
        dismissAnimated = [RCTConvert BOOL:args[@"dismissAnimated"]];
    }

    if([MFMessageComposeViewController canSendAttachments]) {
        if(args[@"attachments"])
        {
            if([args[@"attachments"] isKindOfClass:[NSArray class]])
            {
                NSArray *attachments = args[@"attachments"];
                for(id attachment in attachments)
                {
                    if([attachment isKindOfClass:[NSDictionary class]])
                    {
                        if ([attachment objectForKey:@"url"] && [attachment objectForKey:@"typeIdentifier"])
                        {
                            NSURL *url = [NSURL URLWithString:[attachment objectForKey:@"url"]];
                            NSString *typeIdentifier = [attachment objectForKey:@"typeIdentifier"];
                            NSString *filename = [attachment objectForKey:@"filename"];

                            if (![mcvc addAttachmentData:[NSData dataWithContentsOfURL:url]
                                       typeIdentifier:typeIdentifier
                                             filename:filename]) {
                                NSLog(@"attachment failed to add: %@", attachment);
                            }
                        }
                    }
                }
            }
        }
    }
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:mcvc animated:presentAnimated completion:nil];
    
    [composeViews addObject:mcvc];
    [composeCallbacks addObject:callback];
}

#pragma mark - MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSUInteger index = [composeViews indexOfObject:controller];
    RCTAssert(index != NSNotFound, @"Dismissed view controller was not recognised");
    RCTResponseSenderBlock callback = composeCallbacks[index];
    
    switch (result) {
        case MessageComposeResultCancelled:
            callback(@[@"cancelled"]);
            break;
        case MessageComposeResultFailed:
            callback(@[@"failed"]);
            break;
        case MessageComposeResultSent:
            callback(@[@"sent"]);
            break;
        default:
            break;
    }
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc dismissViewControllerAnimated:dismissAnimated completion:nil];
    
    [composeViews removeObjectAtIndex:index];
    [composeCallbacks removeObjectAtIndex:index];
}

@end

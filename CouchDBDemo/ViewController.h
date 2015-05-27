//
//  ViewController.h
//  CouchDBDemo
//
//  Created by Sujeet on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchCocoa.h>
#import "CouchbaseMobile.h"

@interface ViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *txtSearchData;
    IBOutlet UILabel *lblName;
   CouchbaseMobile* cb;
    NSString *DBPath;
    NSString *databaseName;
    IBOutlet UIImageView *imageView;
    
    IBOutlet UIImageView *imageView2;
    IBOutlet UIImageView *imageView1;
}
- (IBAction)btnSyncClicked:(id)sender;
- (IBAction)btnUpdateClicked:(id)sender;
- (IBAction)startConnection:(id)sender;
- (IBAction)insertBtnClicked:(id)sender;
- (IBAction)deleteBtnClicked:(id)sender;
- (IBAction)searchBtnClicked:(id)sender;
- (void) insertToRemoteDatabase;
- (void) connectToRemoteDatabase;
- (void) deleteToRemoteDatabase ;
- (void) searchToRemoteDatabase;
- (void) updateRemoteDatabase;
- (void) syncWithLocalDB;
- (RESTOperation*) POST: (NSData*)body
             parameters: (NSDictionary*)parameters;
- (RESTOperation*) sendRequest: (NSURLRequest*)request;
- (void)insertInDatabase;
- (void)checkAndCreateDatabase;
-(void)addRecordInRemoteDatabase:(NSString *)document;

@end

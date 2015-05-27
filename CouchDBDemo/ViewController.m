//
//  ViewController.m
//  CouchDBDemo
//
//  Created by Sujeet on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <CouchCocoa/CouchCocoa.h>
#import "CouchbaseMobile.h"
#import <sqlite3.h>
#import "NSData+Base64.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
   // cb = [[CouchbaseMobile alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [txtSearchData release];
    txtSearchData = nil;
    [lblName release];
    lblName = nil;
    [imageView release];
    imageView = nil;
    [imageView1 release];
    imageView1 = nil;
    [imageView2 release];
    imageView2 = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma Mark -- CouchDB Methods


// Connection to the Local DB

- (void) connectToDatabase {
   cb = [[CouchbaseMobile alloc] init];
    cb.delegate = self;
    NSAssert([cb start], @"Couchbase couldn't start! Error = %@", cb.error);
}

- (void) couchbaseMobile: (CouchbaseMobile*)cb didStart: (NSURL*)serverURL {
    CouchServer *server = [[CouchServer alloc] init];
    CouchDatabase *database = [server databaseNamed: @"employee"];
    RESTOperation* op = [database create];
    if (![op wait] && op.httpStatus != 412) {
        // failed to contact the server or create the database
        // (a 412 status is OK; it just indicates the db already exists.)
    }
}

-(void)couchbaseMobile: (CouchbaseMobile*)couchbase failedToStart: (NSError*)error {
    NSLog(@"Couchbase couldn't start! Error = %@", error);
    exit(1); // Put real failure handling here :)
}

//Connection to the Remote DB

- (void) connectToRemoteDatabase {
    NSURL* serverURL = [NSURL URLWithString: @"https://abc.cloudant.com/"];
    CouchServer *server = [[CouchServer alloc] initWithURL: serverURL];
    CouchDatabase *database = [server databaseNamed: @"employee"];
    
    RESTOperation* op = [database GET];
    NSLog(@"Rest operation %@",op);
    if (![op wait]) {
        // failed to contact the server or access the database
    }
    CouchQuery* allDocs = database.getAllDocuments;
    for (CouchQueryRow* row in allDocs.rows) {
        CouchDocument* doc = row.document;
        NSLog(@"Documents are %@",doc);
        NSString* empId = [doc.properties objectForKey: @"empId"];
        NSString* Designation = [doc.properties objectForKey: @"Designation"];
        NSString* Name = [doc.properties objectForKey: @"Name"];
        NSString* Address = [doc.properties objectForKey: @"Address"];
        NSLog(@"Doc ID %@ has empId: %@ Designation: %@ Name: %@ Address: %@", row.documentID, empId,Designation,Name,Address);
    }

}



- (NSMutableURLRequest*) requestWithMethod: (NSString*)method
                                parameters: (NSDictionary*)parameters
{
    NSMutableString* queries = nil;
    BOOL firstQuery;
    
   // NSURL* url = self.URL;
    NSURL* url = [NSURL URLWithString: @"https://abc.cloudant.com/"];
    NSAssert1(url, @"Resource has no URL: %@", self);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: url];
    request.HTTPMethod = method;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    for (NSString* key in parameters) {
        NSString* value = [[parameters objectForKey: key] description];
        if ([key hasPrefix: @"?"]) {
            if (!queries) {
                queries = [NSMutableString string];
                firstQuery = (url.query.length == 0);
            }
            if (firstQuery) {
                [queries appendString: key]; // already includes leading '?'
                firstQuery = NO;
            } else {
                [queries appendString: @"&"];
                [queries appendString: [key substringFromIndex: 1]];
            }
            [queries appendString: @"="];
            CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                          (CFStringRef)value,
                                                                          NULL, (CFStringRef)@"&",
                                                                          kCFStringEncodingUTF8);
            [queries appendString: (id)escaped];
            CFRelease(escaped);
        } else {
            [request setValue: value forHTTPHeaderField: key];
        }
    }
    
    if (queries) {
        NSString* urlStr = [url.absoluteString stringByAppendingString: queries];
        request.URL = [NSURL URLWithString: urlStr];
    }
    
    return request;
}





- (void) insertToRemoteDatabase {

    NSURL* serverURL = [NSURL URLWithString: @"https://abc.cloudant.com/"];
    CouchServer* server = [[CouchServer alloc] initWithURL:serverURL];
    CouchDatabase* db = [server databaseNamed:@"employee"];

     RESTOperation* op = [db create];
    [op onCompletion:^{
        NSLog(@"DB CREATED FOOL!");
        [self createDocumentInDatabase:db];
    }];
    [op start];

}



- (void)createDocumentInDatabase:(CouchDatabase*)db {
    CouchDocument* doc = [db documentWithID:@"EmpList3"];
    UIImage *img = [UIImage imageNamed:@"app_icon_new.png"];
    UIImage *img1 = [UIImage imageNamed:@"BlueFolder@2x.png"];
    UIImage *img2 = [UIImage imageNamed:@"actionsheet_bg_trans_ipad.png"];
    NSString *index = [[NSString alloc]init];
    index = @"index1,index2,index3";
    NSData *dataObj = UIImagePNGRepresentation(img);
   
    NSString* newStr = [dataObj base64Encoding];
    
    dataObj = UIImagePNGRepresentation(img1);
    
    NSString* newStr1 = [dataObj base64Encoding];
    dataObj = UIImagePNGRepresentation(img2);
    
    NSString* newStr2 = [dataObj base64Encoding];
    NSLog(@"String %@",newStr);
    
    RESTOperation* op = [doc putProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                            @"112", @"ID",
                                            @"Stoppin", @"Name",
                                            index, @"Index",
                                            newStr,@"image",
                                            newStr1,@"image1",
                                            newStr2,@"image2",
                                            nil]];
    
    // make a synchronous call
    BOOL wasCreated = [op wait];
    NSLog(@"DOCUMENT CREATED  %d", wasCreated);
}


- (void) deleteToRemoteDatabase {
	
   
    BOOL flag = FALSE;
    NSURL* serverURL = [NSURL URLWithString: @"https://abc.cloudant.com/"];
    CouchServer *server = [[CouchServer alloc] initWithURL: serverURL];
    CouchDatabase *database = [server databaseNamed: @"employee"];
    
    RESTOperation* op = [database GET];
    if (![op wait]) {
        // failed to contact the server or access the database
    }
    NSString * str = [NSString stringWithFormat:@"CouchDocument[%@]",txtSearchData.text];
    CouchQuery* allDocs = database.getAllDocuments;
    for (CouchQueryRow* row in allDocs.rows) {
    CouchDocument* doc = row.document;
        NSLog(@"doc is %@ and text to delete %@",doc.description,str);
        if ([str isEqualToString:doc.description])
        {
            flag = TRUE;
            NSMutableArray *docArray = [[NSMutableArray alloc]initWithObjects:doc, nil];
            op = [database deleteDocuments:docArray];
            break;
        }
    }
    

    if (flag)
        lblName.text = @"File Deleted";
    else
        lblName.text = @"File Not Found";
        

    
}


- (void) searchToRemoteDatabase {
    NSURL* serverURL = [NSURL URLWithString: @"https://abc.cloudant.com/"];
    CouchServer *server = [[CouchServer alloc] initWithURL: serverURL];
    CouchDatabase *database = [server databaseNamed: @"employee"];
    
    RESTOperation* op = [database GET];
    NSLog(@"Rest operation %@",op);
    if (![op wait]) {
        // failed to contact the server or access the database
    }
   
    BOOL flag = FALSE;
   // NSString *name;
    NSString *image, *image1, *image2,*indexValue;
    CouchDesignDocument* design = [database designDocumentWithName: @"EmpList3"];
    //NSString *queryStr = [NSString stringWithFormat:@"function(doc){if (doc.ID == %@ ) emit(doc.ID,doc.image);};",txtSearchData.text];
    NSString *queryStr = [NSString stringWithFormat:@"function(doc){if (doc.ID == %@ ) emit(doc.ID,{Name: doc.Name,Index: doc.Index, image: doc.image, image1: doc.image1, image2: doc.image2});};",txtSearchData.text];
    //emit(doc.LastName, {FirstName: doc.FirstName, Address: doc.Address});
    NSLog(@"Query String %@",queryStr);
    [design defineViewNamed: @"EmpList3" map: queryStr];
    CouchQuery* query = [design queryViewNamed: @"EmpList3"];
    
    for (CouchQueryRow* row in query.rows) {
        NSLog(@"Row %@",row);
        flag = TRUE;
        NSLog(@"%@'s Name is <%@>", row.key, [row.value objectForKey:@"image"]);
      //  name = (NSString *)row.value;
        indexValue  = (NSString*)[row.value objectForKey:@"Index"];
        image = (NSString *)[row.value objectForKey:@"image"];
        image1 = (NSString *)[row.value objectForKey:@"image1"];
        image2 = (NSString *)[row.value objectForKey:@"image2"];
    }
    if (flag)
    {
        NSLog(@"index value %@",indexValue);
        lblName.text = indexValue;
        NSData *data = [NSData dataWithBase64EncodedString:image];
        UIImage *img = [UIImage imageWithData:data];
       // imageView.frame=CGRectMake(imageView.frame.origin.x,imageView.frame.origin.y, img.size.width, img.size.height);
        imageView.image = img;
        data = [NSData dataWithBase64EncodedString:image1];
        img = [UIImage imageWithData:data];
        //imageView1.frame=CGRectMake(imageView.frame.origin.x,imageView.frame.origin.y, img.size.width, img.size.height);
        imageView1.image = img;
        data = [NSData dataWithBase64EncodedString:image2];
        img = [UIImage imageWithData:data];
        //imageView.frame=CGRectMake(imageView.frame.origin.x,imageView.frame.origin.y, img.size.width, img.size.height);
        imageView2.image = img;
        NSLog(@"Image value %@",image);
    }
    else
    {
        lblName.text = @"Record not found";
        imageView.image=nil;
    }
    
}


-(void)addRecordInRemoteDatabase:(NSString *)document
{
    NSURL* serverURL = [NSURL URLWithString: @"https://abc.cloudant.com/"];
    CouchServer *server = [[CouchServer alloc] initWithURL: serverURL];
    CouchDatabase *database = [server databaseNamed: @"employee"];
    
    RESTOperation* op = [database GET];
    CouchDocument* doc = [database documentWithID:document];
    NSLog(@"Rest operation %@",doc);
    if (![op wait]) {
        // failed to contact the server or access the database
    }
    

}


- (void) updateRemoteDatabase
{
    NSURL* serverURL = [NSURL URLWithString: @"https://abc.cloudant.com/"];
    CouchServer *server = [[CouchServer alloc] initWithURL: serverURL];
    CouchDatabase *database = [server databaseNamed: @"employee"];
    
    RESTOperation* op = [database GET];
    CouchDocument* doc = [database documentWithID:@"EmpList3"];
    NSLog(@"Rest operation %@",op);
    if (![op wait]) {
        // failed to contact the server or access the database
    }
    
    
    NSString *name;
  //  UIImage *img = [UIImage imageNamed:@"app_icon_new.png"];
    
   // NSData *dataObj = UIImageJPEGRepresentation(img, 1.0);
  //  NSString *content =[ NSString stringWithCString:[dataObj bytes] encoding:NSUTF8StringEncoding];

    CouchDesignDocument * design = [database designDocumentWithName: @"EmpList3"];
    CouchRevision * latest = design.currentRevision;
      
        name = @"Admin";
    UIImage *img = [UIImage imageNamed:@"app_icon_new.png"];
    UIImage *img1 = [UIImage imageNamed:@"BlueFolder@2x.png"];
    UIImage *img2 = [UIImage imageNamed:@"actionsheet_bg_trans_ipad.png"];
    NSString *index = [[NSString alloc]init];
    index = @"index1,index2,index3";
    NSData *dataObj = UIImagePNGRepresentation(img);
    
    NSString* newStr = [dataObj base64Encoding];
    
    dataObj = UIImagePNGRepresentation(img1);
    
    NSString* newStr1 = [dataObj base64Encoding];
    dataObj = UIImagePNGRepresentation(img2);
    
    NSString* newStr2 = [dataObj base64Encoding];
    NSLog(@"String %@",newStr);
    
    op = [doc putProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                            @"112", @"ID",
                                            @"Stoppin", @"Name",
                                            index, @"Index",
                                            newStr,@"image",
                                            newStr1,@"image1",
                                            newStr2,@"image2",
                                            nil]];

    // make a synchronous call
    BOOL wasCreated = [op wait];
       
     //   [props setValue:name forKey:@"Name"];
       // op = [latest putProperties:props];
    
        [op onCompletion: ^{
            if (op.isSuccessful)
            {
                NSLog(@"Successfully updated document!");
                lblName.text = @"Record Updated";
            }
            else
            {
                NSLog(@"Failed to update document: %@", op.error);
                lblName.text = @"Record not found";
            }
        }];
    
  
}

-(void)insertInDatabase
{
       
    NSArray *dbPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [dbPath objectAtIndex:0];
    DBPath=[documentsDirectory stringByAppendingPathComponent:@"CouchDBDemo.sqlite"];
    [self checkAndCreateDatabase];
    sqlite3 * database;
    NSString *Name = @"Sujeet";
    // NSLog(@"Value of Friends Data %@",friendContactsData);
    if(sqlite3_open([DBPath UTF8String], &database) == SQLITE_OK)
    {
        NSString *sql = [[NSString alloc] initWithFormat:@"select * from empDetail"];
        
        //  NSLog(@"Sql %@", sql);
        //  NSLog(@"Database %@",dbPath);
        sqlite3_stmt *statement, *statement1, *statement2;
        
        if(sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            
            //  NSLog(@"Statement %@",statement);
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *sqlUpdate = [[NSString alloc] initWithFormat:@"update empDetail set Name ='%@' )",Name];
                // NSLog(@"sqlUpdate %@", sqlUpdate);
                if(sqlite3_prepare_v2(database, [sqlUpdate UTF8String], -1, &statement1, NULL) == SQLITE_OK)
                {
                    sqlite3_step(statement1);
                }
                [sqlUpdate release];
            }
            else
            {
                NSString *sqlInsert = [[NSString alloc] initWithFormat:@"insert into empDetail values('102','Manager','XYZ','Noida')"];
                
                //  NSLog(@"Insertion Query %@", sqlInsert);
                
                if(sqlite3_prepare_v2(database, [sqlInsert UTF8String], -1, &statement2, NULL) == SQLITE_OK)
                {
                    sqlite3_step(statement2);
                    //   NSLog(@"insert query executed successfully");
                }
                else
                {
                    //    NSLog(@"something went wrong while inserting flake history.");
                }
                [sqlInsert release];
            }
            
        }
        
        sqlite3_finalize(statement);
        [sql release];
        
    }
    
    sqlite3_close(database);
      
    
}

-(void)checkAndCreateDatabase
{
        // Check if the SQL database has already been saved to the users phone, if not then copy it over
        databaseName=@"CouchDBDemo.sqlite";
        BOOL success;
        
        // Create a FileManager object, we will use this to check the status
        // of the database and to copy it over if required
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Check if the database has already been created in the users filesystem
        success = [fileManager fileExistsAtPath:DBPath];
        
        // If the database already exists then return without doing anything
        if(success) return;
        
        // If not then proceed to copy the database from the application to the users filesystem
        
        // Get the path to the database in the application package
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
        
        // NSLog(@"Database Path From App %@",databasePathFromApp);
        // Copy the database from the package to the users filesystem
        [fileManager copyItemAtPath:databasePathFromApp toPath:DBPath error:nil];
        
        [fileManager release];
        
      
}

- (void) syncWithLocalDB
{
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)btnSyncClicked:(id)sender {
   // [self syncWithLocalDB];
    if (![txtSearchData.text length]) {
        return;
    }
    [self addRecordInRemoteDatabase:txtSearchData.text];
    
}

- (IBAction)btnUpdateClicked:(id)sender {
    [self updateRemoteDatabase];
}

- (IBAction)startConnection:(id)sender {
    [self connectToRemoteDatabase];
    
}

- (IBAction)insertBtnClicked:(id)sender {
    [self insertToRemoteDatabase];
}

- (IBAction)deleteBtnClicked:(id)sender {
    [self deleteToRemoteDatabase];
}

- (IBAction)searchBtnClicked:(id)sender {
    [self searchToRemoteDatabase];
}
- (void)dealloc {
    [txtSearchData release];
    [lblName release];
    [imageView release];
    [imageView1 release];
    [imageView2 release];
    [super dealloc];
}
@end

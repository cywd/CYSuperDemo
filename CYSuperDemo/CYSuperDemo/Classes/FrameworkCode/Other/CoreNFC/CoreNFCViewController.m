//
//  CoreNFCViewController.m
//  CYSuperDemo
//
//  Created by cyrill on 2018/11/8.
//  Copyright © 2018 Cyrill. All rights reserved.
//

#import "CoreNFCViewController.h"
#import <CoreNFC/CoreNFC.h>


API_AVAILABLE(ios(11.0))
@interface NFCNDEFPayload(CY)

- (NSString *)fullDescription;

@end

@implementation NFCNDEFPayload(CY)

- (NSString *)fullDescription {
    NSString *description = @"TNF (TypeNameFormat): \(typeDescription)\n";
    
    NSString *payloadStr = [[NSString alloc] initWithData:self.payload encoding:NSUTF8StringEncoding] ?: @"No payload";
    NSString *typeStr = [[NSString alloc] initWithData:self.type encoding:NSUTF8StringEncoding] ?: @"No type";
    NSString *identifierStr = [[NSString alloc] initWithData:self.identifier encoding:NSUTF8StringEncoding] ?: @"No identifier";
    
    NSString *string = [NSString stringWithFormat:@"%@Payload: %@\nType: %@\nIdentifier: %@\n", description, payloadStr, typeStr, identifierStr];
    
    
    return [string stringByReplacingOccurrencesOfString:@"\0" withString:@""];
}

@end

API_AVAILABLE(ios(11.0))
@interface CoreNFCViewController () <NFCNDEFReaderSessionDelegate, NFCReaderSessionDelegate>

@property (nonatomic, strong) NSMutableArray<NFCNDEFPayload *> *payloads;
@property (nonatomic, strong) NFCNDEFReaderSession *session;

@end

@implementation CoreNFCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _payloads = [NSMutableArray array];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellId"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStyleDone target:self action:@selector(scan)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.payloads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.payloads[indexPath.row] fullDescription];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - NFCReaderSessionDelegate
/*!
 * @method readerSessionDidBecomeActive:
 *
 * @param session   The session object in the active state.
 *
 * @discussion      Gets called when the NFC reader session has become active. RF is enabled and reader is scanning for tags.
 *                  The @link readerSession:didDetectTags: @link/ will be called when a tag is detected.
 */
- (void)readerSessionDidBecomeActive:(NFCReaderSession *)session  API_AVAILABLE(ios(11.0)){
    
}

/*!
 * @method readerSession:didDetectTags:
 *
 * @param session   The session object used for tag detection.
 * @param tags      Array of @link NFCTag @link/ objects.
 *
 * @discussion      Gets called when the reader detects NFC tag(s) in the polling sequence.
 */
- (void)readerSession:(NFCReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCTag>> *)tags  API_AVAILABLE(ios(11.0)){
    
}

#pragma mark - NFCReaderSessionDelegate

// Process detected NFCNDEFMessage objects
- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages  API_AVAILABLE(ios(11.0)){
    NFCNDEFMessage *message = [messages firstObject];
    if (message) {
        _payloads = [NSMutableArray arrayWithArray:message.records];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

// Check invalidation reason from the returned error. A new session instance is required to read new tags.
// 识别出现Error后会话会自动终止，此时就需要程序重新开启会话
- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error  API_AVAILABLE(ios(11.0)){
    if (!error) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Session Invalidated" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - Action

- (void)scan {
    if (@available(iOS 11.0, *)) {
//        if ([NFCISO15693ReaderSession readingAvailable]) {
//            NFCISO15693ReaderSession *session = [[NFCISO15693ReaderSession alloc] initWithDelegate:self queue:nil];
////            [session restartPolling];
//            [session beginSession];
//        }
        
        if ([NFCNDEFReaderSession readingAvailable]) {
            _session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
            [_session beginSession];
        } else {
            ShowMsg(@"设备不支持NFC，或NFC不可用");
        }
    } else {
        // Fallback on earlier versions
        
        ShowMsg(@"iOS 11.0 以上才能使用");
    }
    
}

@end

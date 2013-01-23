//
//  RIRootViewController.m
//  DropboxSample
//
//  Created by Ali Gadzhiev on 12/26/12.
//  Copyright (c) 2012 Red Iron. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "RIRootViewController.h"
#import "DBFetchModel.h"
#import "DBUploadModel.h"
#import "DBFile.h"

#import "RITableViewDataSource.h"

@interface RIRootViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	RITableViewDataSource * _dataSource;
}
@property (strong, nonatomic) DBFetchModel * model;
@property (strong, nonatomic) DBUploadModel * uploadModel;
@property (strong, nonatomic) UITableView * tableView;
@end

@implementation RIRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																							   target:self
																							   action:@selector(addButtonPressed)];
		
		self.model = [DBFetchModel model];
		self.uploadModel = [DBUploadModel model];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(uploadDidFinish:)
													 name:RIModelDidFinishLoadNotification
												   object:self.uploadModel];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(uploadDidFail:)
													 name:RIModelDidFailLoadNotification
												   object:self.uploadModel];
		
		_dataSource = [[RITableViewDataSource alloc] init];
		_dataSource.fetchedResults = [DBFile MR_fetchAllGroupedBy:nil withPredicate:nil sortedBy:@"modified" ascending:YES];
		[_dataSource registerClass:[UITableViewCell class] forCellWithReuseIdentifier:@"Cell"];
		[_dataSource setReusableIdentifierBlock:^NSString *(NSIndexPath * indexPath) {
			return @"Cell";
		}];
		[_dataSource setConfigureCellBlock:^(UITableViewCell * cell, NSIndexPath * indexPath, id obj) {
			DBFile * file = obj;
			cell.textLabel.text = [file.path stringByStandardizingPath];
		}];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.tableView];
	
	_dataSource.tableView = self.tableView;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[DBSession sharedSession] isLinked]) {
		[self.model load];
	} else {
		[[DBSession sharedSession] linkFromController:self];
	}
}

#pragma mark - Buttons actions

- (void)addButtonPressed {
	UIImagePickerController * pickerController = [[UIImagePickerController alloc] init];
	pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    pickerController.delegate = self;
	
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - Image picker controller delegate

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
	
	NSString * path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"photo.jpg"];
    NSString * mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage * originalImage, *editedImage, *imageToUse;
	
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
		
        editedImage = (UIImage *) [info objectForKey:
								   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
									 UIImagePickerControllerOriginalImage];
		
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        // Do something with imageToUse
		
		[[NSFileManager defaultManager] createFileAtPath:path
												contents:UIImageJPEGRepresentation(imageToUse, 1.0)
											  attributes:nil];
    }
	
    [self dismissViewControllerAnimated:YES completion:^{
		[self.uploadModel uploadFileWithName:@"photo.jpg" fromPath:path];
	}];
}

#pragma mark - Models handlers

- (void)uploadDidFinish:(NSNotification *)notification {
	[self.model load];
}

- (void)uploadDidFail:(NSNotification *)notification {
	NSError * error = [[notification userInfo] objectForKey:@"error"];
	NSString * message = [error localizedDescription];
	if (!message) message = @"Unknown error";
	
	[[[UIAlertView alloc] initWithTitle:@"Error" message:message
							   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
	 show];
}

@end

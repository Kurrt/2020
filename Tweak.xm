@interface SBIconView
-(void)update2020Plist;
-(CGRect)new2020Rect;
@end

#define ADD_SECONDS		3600
#define MIN_SIZE		5.f 
#define PLIST_PATH		@"/var/mobile/Library/2020/state.plist"
#define ICON_SIZE		@"size"
#define TIME_STAMP		@"time"
#define SHRINK_AMOUNT	0.1f

static float iconSize = -1.f;
static NSTimeInterval timeStamp = 0;


%hook SBIconView

-(CGRect)_frameForVisibleImage {
	if (iconSize < 0)
		return %orig;
	else if (iconSize < MIN_SIZE)
		iconSize = %orig.size.width;
	return [self new2020Rect];
}

-(CGRect)_frameForImageView {
	if (iconSize < 0)
		return %orig;
	else if (iconSize < MIN_SIZE)
		iconSize = %orig.size.width;
	return [self new2020Rect];
}

-(CGRect)iconImageFrame {
	if (iconSize < 0)
		return %orig;
	else if (iconSize < MIN_SIZE)
		iconSize = %orig.size.width;
	return [self new2020Rect];
}

%new
-(CGRect)new2020Rect {
	if (timeStamp == 0)
		timeStamp = [[NSDate date] timeIntervalSince1970] + ADD_SECONDS;

	if (timeStamp < [[NSDate date] timeIntervalSince1970] && iconSize > MIN_SIZE) {
		timeStamp = [[NSDate date] timeIntervalSince1970] + ADD_SECONDS;
		iconSize -= SHRINK_AMOUNT;
		[self update2020Plist];
	}

	return CGRectMake(0.f,0.f,iconSize,iconSize);
}

%new
-(void)update2020Plist {
	[@{ICON_SIZE:[NSNumber numberWithFloat:iconSize],TIME_STAMP:[NSNumber numberWithDouble:timeStamp]} writeToFile:PLIST_PATH atomically: YES];
}

%end


%ctor {
	NSMutableDictionary *attr = [NSMutableDictionary dictionary]; 
    [attr setObject:[NSNumber numberWithInt:501] forKey:NSFileOwnerAccountID];
    [attr setObject:[NSNumber numberWithInt:501] forKey:NSFileGroupOwnerAccountID]; 
    [attr setObject:[NSNumber numberWithInt:0777] forKey:NSFilePosixPermissions];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:PLIST_PATH]) {
        if(![[NSFileManager defaultManager] fileExistsAtPath:(PLIST_PATH).stringByDeletingLastPathComponent isDirectory:nil])
            [[NSFileManager defaultManager] createDirectoryAtPath:(PLIST_PATH).stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:attr error:NULL];
        else 
            [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:(PLIST_PATH).stringByDeletingLastPathComponent error:&error];
        [[NSFileManager defaultManager] createFileAtPath:PLIST_PATH contents:nil attributes:attr];
    } else {
        [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:(PLIST_PATH).stringByDeletingLastPathComponent error:&error];
        [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:PLIST_PATH error:&error];
    }
    if(error)
        NSLog(@"2020 File Error");

	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	if ([dict valueForKey:ICON_SIZE]) 
		iconSize = [[dict valueForKey:ICON_SIZE] floatValue];
	else
		iconSize = 0.f;
	if ([dict valueForKey:TIME_STAMP]) 
		timeStamp = [[dict valueForKey:TIME_STAMP] doubleValue];
	[dict release];
}
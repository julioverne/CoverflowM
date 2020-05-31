#import "Tweak.h"

#include "ReflectionView/ReflectionView.m"
#include "MDAudioPlayerTableViewCell/MDAudioPlayerTableViewCell.m"

#define NSLog1(...)


static BOOL Enabled;
static int styleEnabled;
static float kScreenW;
static float kScreenH;

static CPDistributedMessagingCenter *centerMusic = nil;

static __strong NSArray* items;

static void playItem(int action, int collectionIndex, int soundIndex)
{
	[centerMusic sendMessageName:@"actionPlayer" userInfo:@{
		@"action":@(action),
		@"collectionIndex":@(collectionIndex),
		@"soundIndex":@(soundIndex),
	}];
}


@implementation CollectionTableAViewController
@synthesize indexRow;
- (void)updateData
{
	@try {
	NSArray* Items = [(MPMediaItemCollection*)items[indexRow] items]?:@[];
	
	double Totalduration = 0;
	
	for(MPMediaItem* mdItem in Items) {
		Totalduration += [[mdItem valueForProperty:MPMediaItemPropertyPlaybackDuration]?:@(0) doubleValue];
	}
	
	MPMediaItem* song = [(MPMediaItemCollection*)items[indexRow] representativeItem];
	
	((UINavigationBar*)self.navigationController.navigationBar).prompt = @" ";
	
	UILabel *label = [[UILabel alloc] initWithFrame:self.navigationController.navigationBar.bounds];
	label.frame = self.navigationController.navigationBar.bounds;
	label.backgroundColor = [UIColor whiteColor];
	label.textColor = [UIColor blackColor];
	label.numberOfLines = 4;
	label.font = [UIFont boldSystemFontOfSize: 12.0f];
	label.textAlignment = NSTextAlignmentLeft;
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	label.translatesAutoresizingMaskIntoConstraints = YES;
	
	[self.navigationController.navigationBar _setBackgroundView:label];
	
	NSDateComponentsFormatter *dateComponentsFormatter = [%c(NSDateComponentsFormatter) new];
	dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
	
	NSString* anoAlbum = @"";
	if(NSDate* anoI = [song valueForProperty:MPMediaItemPropertyReleaseDate]) {
		anoAlbum = [@([[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:anoI] year]) stringValue];
	}	
	
	label.text = [NSString stringWithFormat:@"  %@\n\n  %d songs, %@\n  %@", [song valueForProperty:MPMediaItemPropertyAlbumTitle], (int)[Items count], [dateComponentsFormatter stringFromTimeInterval:Totalduration], anoAlbum];
	
	[self.tableView reloadData];
	
	}@catch(NSException* e) {
	}
}
- (id)initWithIndex:(int)arg1
{
	self = [super init];
	indexRow = arg1;
	return self;
}
- (void)viewDidLoad
{
	[super viewDidLoad];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	@try {
		if(MPMediaItemCollection* collectionSelected = (MPMediaItemCollection*)items[indexRow]) {
			if(NSArray* itms = [collectionSelected items]) {
				return [itms count];
			}		
		}
	}@catch(NSException* e) {
	}
    return 0;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	playItem(1, indexRow, indexPath.row);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* simpleTableIdentifier = @"SongCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
	
	@try {
	MPMediaItemCollection* collectionSelected = (MPMediaItemCollection*)items[indexRow];
	MPMediaItem* song = [collectionSelected items][indexPath.row];
	
	
	
	cell.accessoryView = nil;
	cell.textLabel.text = nil;
	cell.detailTextLabel.text = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.textAlignment = NSTextAlignmentLeft;
	cell.imageView.image = nil;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	cell.backgroundColor = [UIColor whiteColor];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.detailTextLabel.textColor = [UIColor blackColor];
	
	cell.textLabel.font = [UIFont boldSystemFontOfSize: 12.0f];
	cell.detailTextLabel.font = [UIFont boldSystemFontOfSize: 12.0f];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@  %@", [song valueForProperty:MPMediaItemPropertyAlbumTrackNumber], [song valueForProperty:MPMediaItemPropertyTitle]];
	
	double duration = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
	NSDateComponentsFormatter *dateComponentsFormatter = [%c(NSDateComponentsFormatter) new];
	dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
	cell.detailTextLabel.text = [dateComponentsFormatter stringFromTimeInterval:duration];
	}@catch(NSException* e) {
	}
	return cell;
}
@end

@implementation HorizontalCollectionViewLayout
{
    NSInteger _cellCount;
    CGSize _boundsSize;
}
- (void)prepareLayout
{
    _cellCount = [self.collectionView numberOfItemsInSection:0];
    _boundsSize = self.collectionView.bounds.size;
}
- (CGSize)collectionViewContentSize
{
    NSInteger verticalItemsCount = (NSInteger)floorf(_boundsSize.height / _itemSize.height);
    NSInteger horizontalItemsCount = (NSInteger)floorf(_boundsSize.width / _itemSize.width);
    NSInteger itemsPerPage = verticalItemsCount * horizontalItemsCount;
    NSInteger numberOfItems = _cellCount;
    NSInteger numberOfPages = (NSInteger)ceilf((CGFloat)numberOfItems / (CGFloat)itemsPerPage);
    CGSize size = _boundsSize;
    size.width = numberOfPages * _boundsSize.width;
    return size;
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:_cellCount];
    for (NSUInteger i=0; i<_cellCount; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewLayoutAttributes *attr = [self _layoutForAttributesForCellAtIndexPath:indexPath];

        [allAttributes addObject:attr];
    }
    return allAttributes;
}
- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _layoutForAttributesForCellAtIndexPath:indexPath];
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
- (UICollectionViewLayoutAttributes*)_layoutForAttributesForCellAtIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    CGRect bounds = self.collectionView.bounds;
    CGSize itemSize = self.itemSize;
	
    NSInteger verticalItemsCount = (NSInteger)floorf(bounds.size.height / itemSize.height);
    NSInteger horizontalItemsCount = (NSInteger)floorf(bounds.size.width / itemSize.width);
    NSInteger itemsPerPage = verticalItemsCount * horizontalItemsCount;
	
    NSInteger columnPosition = row%horizontalItemsCount;
    NSInteger rowPosition = (row/horizontalItemsCount)%verticalItemsCount;
    NSInteger itemPage = floorf(row/itemsPerPage);
	
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	
    CGRect frame = CGRectZero;
    frame.origin.x = itemPage * (horizontalItemsCount*itemSize.width) + columnPosition * itemSize.width;
    frame.origin.y = rowPosition * itemSize.height;
    frame.size = _itemSize;
	
    attr.frame = frame;
	
    return attr;
}
- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    [self invalidateLayout];
}
@end

static __strong UIImage* kNoArtWork = [[[UIImage alloc] initWithData:[NSData dataWithBytesNoCopy:(void *)NO_ART_BYTES length:NO_ART_LEN freeWhenDone:NO]] copy];


@implementation PlayerButtonView
@synthesize playView, pauseView, nextView, prevView, isPaused, prevImageView, pauseImageView, playImageView, nextImageView;
- (UIImage *)inverseColor:(UIImage *)image
{
    CIImage *coreImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:coreImage forKey:kCIInputImageKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    return [UIImage imageWithCIImage:result];
}
- (id)initWithFrame:(CGRect)arg1
{
	self = [super initWithFrame:arg1];
	
	UIImage* kPlay = [[UIImage alloc] initWithData:[NSData dataWithBytesNoCopy:(void *)PLAY_BYTES length:PLAY_LEN freeWhenDone:NO]];
	UIImage* kPause = [[UIImage alloc] initWithData:[NSData dataWithBytesNoCopy:(void *)PAUSE_BYTES length:PAUSE_LEN freeWhenDone:NO]];
	UIImage* kNext = [[UIImage alloc] initWithData:[NSData dataWithBytesNoCopy:(void *)NEXT_BYTES length:NEXT_LEN freeWhenDone:NO]];
	UIImage* kPrev = [[UIImage alloc] initWithData:[NSData dataWithBytesNoCopy:(void *)PREV_BYTES length:PREV_LEN freeWhenDone:NO]];
	
	kPlay = [self inverseColor:kPlay];
	kPause = [self inverseColor:kPause];
	kNext = [self inverseColor:kNext];
	kPrev = [self inverseColor:kPrev];
	
	self.prevImageView = [[UIImageView alloc] initWithImage:kPrev];
	self.pauseImageView = [[UIImageView alloc] initWithImage:kPause];
	self.playImageView = [[UIImageView alloc] initWithImage:kPlay];
	self.nextImageView = [[UIImageView alloc] initWithImage:kNext];
	
	self.prevImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.pauseImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.playImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.nextImageView.contentMode = UIViewContentModeScaleAspectFill;
	
	self.prevView = [[UIView alloc] init];
	self.pauseView = [[UIView alloc] init];
	self.playView = [[UIView alloc] init];
	self.nextView = [[UIView alloc] init];
	
	[self.prevView addSubview:prevImageView];
	[self.pauseView addSubview:pauseImageView];
	[self.playView addSubview:playImageView];
	[self.nextView addSubview:nextImageView];
	
	[self addSubview:self.prevView];
	[self addSubview:self.pauseView];
	[self addSubview:self.playView];
	[self addSubview:self.nextView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged) name:(__bridge id)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
	
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleButtons:)];
	singleTap.numberOfTapsRequired = 1;
	
	[self.prevView setUserInteractionEnabled:YES];
	[self.pauseView setUserInteractionEnabled:YES];
	[self.playView setUserInteractionEnabled:YES];
	[self.nextView setUserInteractionEnabled:YES];
	
	[self setUserInteractionEnabled:YES];
	[self addGestureRecognizer:singleTap];

	return self;
}
- (void)playbackStateChanged
{
	MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlayingNow){
		self.isPaused = isPlayingNow;
		self.pauseView.hidden = !self.isPaused;
		self.playView.hidden = self.isPaused;
	});
}
- (void)handleButtons:(UITapGestureRecognizer*)gestureRecognizer
{
	if(gestureRecognizer) {
		CGPoint loc = [gestureRecognizer locationInView:self];
		if(CGRectContainsPoint(self.playView.frame, loc) || CGRectContainsPoint(self.pauseView.frame, loc)) {
			MRMediaRemoteSendCommand(kMRTogglePlayPause, 0);
		} else if(CGRectContainsPoint(self.nextView.frame, loc)) {
			MRMediaRemoteSendCommand(kMRNextTrack, 0);
		} else if(CGRectContainsPoint(self.prevView.frame, loc)) {
			MRMediaRemoteSendCommand(kMRPreviousTrack, 0);
		}
	}
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self setFrame:[self superview].bounds];
	
	[self playbackStateChanged];
	
	float centerSize = self.frame.size.width/2;
	float buttonWidth = 42;
	float spaceBetwen = buttonWidth*1.3f;
	
	CGPoint sizeBtVCen = CGPointMake(self.frame.size.height/2, self.frame.size.height/2);
	[self.prevView setCenter:sizeBtVCen];
	[self.pauseView setCenter:sizeBtVCen];
	[self.playView setCenter:sizeBtVCen];
	[self.nextView setCenter:sizeBtVCen];
	
	[self.prevView setFrame:CGRectMake(centerSize-(buttonWidth+spaceBetwen), self.prevView.frame.origin.y, buttonWidth, buttonWidth)];
	[self.pauseView setFrame:CGRectMake(centerSize, self.pauseView.frame.origin.y, buttonWidth, buttonWidth)];
	[self.playView setFrame:CGRectMake(centerSize, self.playView.frame.origin.y, buttonWidth, buttonWidth)];
	[self.nextView setFrame:CGRectMake(centerSize+buttonWidth+spaceBetwen, self.nextView.frame.origin.y, buttonWidth, buttonWidth)];
	
	CGRect sizeBt = CGRectMake(0, 0, buttonWidth/2, buttonWidth/2);
	[self.prevImageView setFrame:sizeBt];
	[self.pauseImageView setFrame:sizeBt];
	[self.playImageView setFrame:sizeBt];
	[self.nextImageView setFrame:sizeBt];
	
	CGPoint sizeBtCen = CGPointMake(buttonWidth/2, buttonWidth/2);
	[self.prevImageView setCenter:sizeBtCen];
	[self.pauseImageView setCenter:sizeBtCen];
	[self.playImageView setCenter:sizeBtCen];
	[self.nextImageView setCenter:sizeBtCen];
	
	
}
@end


static UIView* getTransportButtons()
{
	static UIView *retV;
	if(!retV) {
		retV = [UIView new];
		PlayerButtonView *controls = [[PlayerButtonView alloc] initWithFrame:CGRectMake(0,0,0,0)];
		controls.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[retV addSubview:controls];
	}
	[retV layoutSubviews];	
	return retV;
}

@implementation ColectionHViewController
@synthesize collectionView, collectionIndex, rowsCount, isShowingAlbumInfo, isShowingAlbumInfoIndexPath;
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if(!rowsCount) {
		rowsCount = 3;
	}
	
	HorizontalCollectionViewLayout* layOu = [[HorizontalCollectionViewLayout alloc] init];
	layOu.itemSize = CGSizeMake(self.view.frame.size.width/rowsCount, self.view.frame.size.width/rowsCount);
	collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layOu];
	collectionView.delegate = self;
	collectionView.dataSource = self;
	collectionView.backgroundColor = [UIColor blackColor];
	[collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"TrackCell"];
	collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:collectionView];
	
	UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinchGesture:)];
    [collectionView addGestureRecognizer:gesture];
	
    [collectionView reloadData];
}
- (void)didReceivePinchGesture:(UIPinchGestureRecognizer*)gesture
{
	if(gesture.state == UIGestureRecognizerStateEnded) {
		int newRowsCount = rowsCount;
		if(gesture.scale > 1) {
			newRowsCount--;
		} else if(gesture.scale < 1) {
			newRowsCount++;
		}
		if(newRowsCount<1) {
			newRowsCount = 1;
		}
		if(newRowsCount>5) {
			newRowsCount = 5;
		}
		if(rowsCount != newRowsCount) {
			rowsCount = newRowsCount;
			((HorizontalCollectionViewLayout*)[collectionView collectionViewLayout]).itemSize = CGSizeMake(self.view.frame.size.height/rowsCount, self.view.frame.size.height/rowsCount);			
			[UIView animateWithDuration:0.5f animations:^{				
				[collectionView.collectionViewLayout invalidateLayout];
			} completion:nil];
		}
    }
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	@try {
		return [items count];
	}@catch(NSException* e) {
	}
	return 0;
}
- (UIImageView*)imageViewForIndexPath:(NSIndexPath *)indexPath withFrame:(CGRect)frame
{
	
	UIImageView* imageV = [[UIImageView alloc] initWithFrame:frame];
	@try {
		MPMediaItem* song = [(MPMediaItemCollection*)items[indexPath.row] representativeItem];
		imageV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		imageV.translatesAutoresizingMaskIntoConstraints = YES;
		imageV.tag = 7856;
		imageV.contentMode = UIViewContentModeScaleAspectFit;
		imageV.image = [(MPMediaItem*)[song valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(imageV.frame.size.width * 5, imageV.frame.size.width * 5)]?:kNoArtWork;
	}@catch(NSException* e) {
	}
	return imageV;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)acollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TrackCell";
    UICollectionViewCell *cell = [acollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	cell.translatesAutoresizingMaskIntoConstraints = YES;
	cell.contentView.translatesAutoresizingMaskIntoConstraints = YES;
	cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	if(UIView* oldBT = [cell.contentView viewWithTag:7856]) {
		[oldBT removeFromSuperview];
	}
	[cell.contentView addSubview:[self imageViewForIndexPath:indexPath withFrame:cell.bounds]];
	
	cell.layer.borderColor = [UIColor blackColor].CGColor;
	cell.layer.borderWidth = 0.4f;
	
    return cell;
}
- (void)zoom:(BOOL)enableZoom indexPath:(NSIndexPath *)indexPath
{
	isShowingAlbumInfo = enableZoom;
	
	if(isShowingAlbumInfo) {
		isShowingAlbumInfoIndexPath = indexPath;
	}
	
	
	if(enableZoom) {
		if(UIView* oldBT = [self.view viewWithTag:7656]) {
			[oldBT removeFromSuperview];
		}
		if(UIView* oldBT = [self.view viewWithTag:76596]) {
			[oldBT removeFromSuperview];
		}
	}
	
	
	
	
	UIView* buttons = getTransportButtons()?:[UIView new];
	
	buttons.frame = CGRectMake( 0, ((self.view.frame.size.height/2)-((self.view.frame.size.height/1.6)/1.6)) + (self.view.frame.size.height/1.6), (self.view.frame.size.width/2), 60);
	buttons.tag = 96585;
	buttons.alpha = 0;
	
	static __strong UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:[[CollectionTableAViewController alloc] initWithIndex:indexPath.row]];
	
	((CollectionTableAViewController*)navCon.topViewController).indexRow = indexPath.row;
	[(CollectionTableAViewController*)navCon.topViewController updateData];
	
	navCon.view.frame = CGRectMake( (self.view.frame.size.width/2), 0, (self.view.frame.size.width/2), self.view.frame.size.height);
	navCon.view.alpha = 0;
	
	[UIView animateWithDuration:0.3 animations:^{
		
		collectionView.scrollEnabled = !enableZoom;
		collectionView.alpha = enableZoom?0.3:1.0;
		
		UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:isShowingAlbumInfoIndexPath];
		CGRect cellRect = attributes.frame;
		CGRect cellFrameInSuperview = [collectionView convertRect:cellRect toView:self.view];
		
		if(!enableZoom) {
			if(UIView* oldBT = [self.view viewWithTag:7656]) {
				oldBT.frame = cellFrameInSuperview;
			}
			if(UIView* oldBT = [self.view viewWithTag:76596]) {
				oldBT.alpha = 0;
			}
			if(UIView* oldBT = [self.view viewWithTag:96585]) {
				oldBT.alpha = 0;
			}
			return;
		}
		
		UIImageView* imageVi = [self imageViewForIndexPath:isShowingAlbumInfoIndexPath withFrame:cellFrameInSuperview];
		imageVi.tag = 7656;
		
		imageVi.frame = cellFrameInSuperview;
		
		[self.view addSubview:imageVi];
		
        imageVi.frame = CGRectMake( (self.view.frame.size.width/2)-(((self.view.frame.size.height/1.6)/1.7)*2.1), (self.view.frame.size.height/2)-((self.view.frame.size.height/1.6)/1.6), self.view.frame.size.height/1.6, self.view.frame.size.height/1.6);
		
		navCon.view.alpha = 1.0;
		navCon.view.tag = 76596;
		
		[self.view addSubview:navCon.view];
		
		buttons.alpha = 1.0;
		
		[self.view addSubview:buttons];
		
    } completion:^(BOOL comple){
		if(comple) {
			if(!enableZoom) {
				if(UIView* oldBT = [self.view viewWithTag:7656]) {
					[oldBT removeFromSuperview];
				}
				if(UIView* oldBT = [self.view viewWithTag:76596]) {
					[oldBT removeFromSuperview];
				}
				if(UIView* oldBT = [self.view viewWithTag:96585]) {
					[oldBT removeFromSuperview];
				}
			}
		}
	}];
}
- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self zoom:!isShowingAlbumInfo indexPath:indexPath];
}
@end


@implementation CoverflowMViewController
@synthesize carousel, titleName, artist, album, albumTableView, collectionIndex, collectionScroll;
__strong static CoverflowMViewController* _sharedCoverflowMViewController;
+ (id)sharedInstance
{
	if (!_sharedCoverflowMViewController) {
		_sharedCoverflowMViewController = [[[self class] alloc] init];
	}
	return _sharedCoverflowMViewController;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	@try {
	if(MPMediaItemCollection* collectionSelected = (MPMediaItemCollection*)items[collectionIndex]) {
		if(NSArray* itms = [collectionSelected items]) {
			return [itms count];
		}		
	}
	}@catch(NSException* e) {
	}
    return 0;
}
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	playItem(1, collectionIndex, indexPath.row);
}
	
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	 MDAudioPlayerTableViewCell *cell = (MDAudioPlayerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if(cell == nil) {
		cell = [[MDAudioPlayerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}
	@try {
	MPMediaItemCollection* collectionSelected = (MPMediaItemCollection*)items[collectionIndex];
	MPMediaItem* song = [collectionSelected items][indexPath.row];
	
   
	
	cell.title = [song valueForProperty:MPMediaItemPropertyTitle];
	cell.number = [NSString stringWithFormat:@"%@", [song valueForProperty:MPMediaItemPropertyAlbumTrackNumber]];
	
	double duration = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
	NSDateComponentsFormatter *dateComponentsFormatter = [%c(NSDateComponentsFormatter) new];
	dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
	
	cell.duration = [dateComponentsFormatter stringFromTimeInterval:duration];

	cell.isEven = indexPath.row % 2;
	
	/*if (0 == indexPath.row) {
		cell.isSelectedIndex = YES;
	} else {
		cell.isSelectedIndex = NO;
	}*/
	
	}@catch(NSException* e) {
	}
	
	return cell;
}
- (void)loadView
{	
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	
	collectionScroll = [[ColectionHViewController alloc] init];
	collectionScroll.view.frame = self.view.bounds;
	collectionScroll.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:collectionScroll.view];
	
	
	carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, -(self.view.frame.size.height/6), self.view.frame.size.width, self.view.frame.size.height + (self.view.frame.size.height/6))];
	carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	carousel.delegate = self;
	carousel.dataSource = self;
	float sizeArt = (self.view.frame.size.height/1.5);
	[self.view addSubview:carousel];
	
	UIView* TapBarPlayer = [UIView new];
	TapBarPlayer.tag = 76985;
	TapBarPlayer.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2f];
	TapBarPlayer.frame = CGRectMake(0, self.view.frame.size.width - (self.view.frame.size.width/3.6), self.view.frame.size.height, self.view.frame.size.width/3.6);
	[self.view addSubview:TapBarPlayer];
	
	titleName = [[UILabel alloc]initWithFrame:CGRectMake(0, TapBarPlayer.frame.size.height/8, TapBarPlayer.frame.size.width, TapBarPlayer.frame.size.height/4)];
	titleName.textAlignment = NSTextAlignmentCenter;
	titleName.textColor = [UIColor whiteColor];
	titleName.font = [UIFont systemFontOfSize:12];
	[TapBarPlayer addSubview:titleName];
	
	artist = [[UILabel alloc]initWithFrame:CGRectMake(0, (TapBarPlayer.frame.size.height/2.8), TapBarPlayer.frame.size.width, TapBarPlayer.frame.size.height/4)];
	artist.textAlignment = NSTextAlignmentCenter;
	artist.textColor = [UIColor whiteColor];
	artist.font = [UIFont systemFontOfSize:12];
	[TapBarPlayer addSubview:artist];
	
	album = [[UILabel alloc]initWithFrame:CGRectMake(0, (TapBarPlayer.frame.size.height/1.8), TapBarPlayer.frame.size.width, TapBarPlayer.frame.size.height/4)];
	album.textAlignment = NSTextAlignmentCenter;
	album.textColor = [UIColor whiteColor];
	album.font = [UIFont systemFontOfSize:12];
	[TapBarPlayer addSubview:album];
	
	UIView* buttons = getTransportButtons()?:[UIView new];
	
	buttons.frame = CGRectMake(30, 9, 260, 60.0);
	
	buttons.tag = 96585;
	[TapBarPlayer addSubview:buttons];
	
	
	
	albumTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, sizeArt, sizeArt)];
	albumTableView.delegate = self;
	albumTableView.dataSource = self;
	albumTableView.separatorColor = [UIColor colorWithRed:0.986 green:0.933 blue:0.994 alpha:0.10];
	albumTableView.backgroundColor = [UIColor clearColor];
	albumTableView.contentInset = UIEdgeInsetsMake(0, 0, 37, 0); 
	albumTableView.showsVerticalScrollIndicator = NO;
	
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
	v.backgroundColor = [UIColor clearColor];
	[albumTableView setTableFooterView:v];
	
	[self carouselCurrentItemIndexDidChange:carousel];
}
- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
	return (self.view.frame.size.height/1.5);
}
- (void)updateData
{
	@try {
		
	if([CoverflowM sharedInstanceExist]) {
		if(UIView* superV = [[CoverflowM sharedInstance] springboardWindow]) {
			superV.hidden = Enabled?NO:YES;
		}
	}
	
		if(collectionScroll && carousel) {
			if(UIView* oldBT = [self.view viewWithTag:76985]) {
				oldBT.hidden = styleEnabled==0?YES:NO;
			}
			if(styleEnabled==0) {
				collectionScroll.view.hidden = NO;
				carousel.hidden = YES;
			} else {
				carousel.type = (iCarouselType)(styleEnabled-1);
				carousel.hidden = NO;
				collectionScroll.view.hidden = YES;
			}
		}
		if(items&&titleName&&artist&&album) {
			MPMediaItem* song = [(MPMediaItemCollection*)items[[carousel currentItemIndex]] representativeItem];
			//titleName.text = [song valueForProperty:MPMediaItemPropertyTitle];
			artist.text = [song valueForProperty:MPMediaItemPropertyArtist];
			album.text = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
		}
		
		}@catch(NSException* e) {
	}
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self updateData];
	[carousel updateItemWidth];
	[carousel reloadData];
}
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousels
{
	[self updateData];
}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
	return YES;
}
- (void)carousel:(iCarousel *)carousels didSelectItemAtIndex:(NSInteger)index
{
	@try {
	collectionIndex = index;
	albumTableView.frame = [carousels currentItemView].bounds;
	
	[albumTableView reloadData];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationTransition:([albumTableView superview]?UIViewAnimationTransitionFlipFromLeft:UIViewAnimationTransitionFlipFromRight) forView:[carousels currentItemView] cache:YES];
	if([albumTableView superview]) {
		[albumTableView removeFromSuperview];
	} else {
		[[carousels currentItemView] addSubview:albumTableView];
	}
	[UIView commitAnimations];
	}@catch(NSException* e) {
	}
}

- (void)carouselDidScroll:(iCarousel *)carousels
{
	if([albumTableView superview]) {
		[albumTableView removeFromSuperview];
	}
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
	@try {
    return [items count];
	}@catch(NSException* e) {
	}
	return 0;
}
- (UIView *)carousel:(iCarousel *)carousels viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
	float sizeArt = (self.view.frame.size.height/1.5);
	UIView* viewR = [[ReflectionView alloc] initWithFrame:CGRectMake(0, 0, sizeArt, sizeArt)];
	@try {
	MPMediaItem* song = [(MPMediaItemCollection*)items[index] representativeItem];
	
	carousels.itemWidth = sizeArt;
	UIView* artView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sizeArt, sizeArt)];
	artView.translatesAutoresizingMaskIntoConstraints = YES;
	
	UIImageView* imageV = [[UIImageView alloc] initWithFrame:artView.bounds];
	[artView addSubview:imageV];
	imageV.contentMode = UIViewContentModeScaleAspectFit;
	imageV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageV.translatesAutoresizingMaskIntoConstraints = YES;
	imageV.image = [(MPMediaItem*)[song valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(sizeArt * 5, sizeArt * 5)]?:kNoArtWork;
	
	
	((ReflectionView*)viewR).reflectionGap = 0;
	[viewR addSubview:artView];
	
	if(view) {
		view.frame = artView.bounds;
	}	
	}@catch(NSException* e) {
	}
    return viewR;
}
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if(option == iCarouselOptionSpacing) {
        return value * 1.2;
    }
    return value;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}
- (BOOL)prefersStatusBarHidden
{
	return YES;
}
@end



static void orientationChanged()
{
	[CoverflowM notifyOrientationChange];
}

static UIDeviceOrientation orientationOld;

@interface UIApplication ()
- (UIWindow*)statusBarWindow;
@end

@implementation CoverflowM
@synthesize springboardWindow, controller;
__strong static id _sharedObject;
+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("com.apple.springboard.screenchanged"), NULL, (CFNotificationSuspensionBehavior)0);
		CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("UIWindowDidRotateNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	return _sharedObject;
}
+ (BOOL)sharedInstanceExist
{
	if (_sharedObject) {
		return YES;
	}
	return NO;
}
- (void)firstload
{
	return;
}
+ (void)notifyOrientationChange
{
	if([CoverflowM sharedInstanceExist]) {
		if (CoverflowM* CoverflowMH = [CoverflowM sharedInstance]) {
			[CoverflowMH orientationChanged];
		}
	}
}
-(id)init
{
	self = [super init];
	if(self != nil) {
		@try {
			
			CGRect frameDisplay = [[UIScreen mainScreen] bounds];
			
			springboardWindow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameDisplay.size.height, frameDisplay.size.width)];
			[springboardWindow setHidden:Enabled?NO:YES];
			springboardWindow.alpha = 0;
			[springboardWindow setUserInteractionEnabled:YES];
			springboardWindow.layer.cornerRadius = 0;
			springboardWindow.layer.masksToBounds = YES;
			springboardWindow.layer.shouldRasterize  = NO;
			
			controller = [CoverflowMViewController sharedInstance];
			controller.view.frame = springboardWindow.bounds;
			
			[(UIView *)springboardWindow addSubview:controller.view];
			
			[self orientationChanged];
			
		} @catch (NSException * e) {
			
		}
	}
	return self;
}
- (void)orientationChanged
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if(orientation == orientationOld) {
		return;
	}
	BOOL isLandscape;
	__block BOOL hideView;
	hideView = NO;
	__block CGAffineTransform newTransform;
	__block int xLoc;
	__block int yLoc;
	#define DegreesToRadians(degrees) (degrees * M_PI / 180)
	switch (orientation) {
		case UIDeviceOrientationLandscapeRight: {			
			isLandscape = YES;
			yLoc = 0;
			xLoc = 0;
			newTransform = CGAffineTransformMakeRotation(-DegreesToRadians(90));
			break;
		}
		case UIDeviceOrientationLandscapeLeft: {
			isLandscape = YES;
			yLoc = (kScreenH-controller.view.frame.size.width);
			xLoc = (kScreenW-controller.view.frame.size.height);
			newTransform = CGAffineTransformMakeRotation(DegreesToRadians(90));
			break;
		}
		default: {
			isLandscape = NO;
			yLoc = 0;
			xLoc = 0;
			newTransform = CGAffineTransformMakeRotation(-DegreesToRadians(90));
			hideView = YES;
			break;
		}
    }
	
	springboardWindow.alpha = hideView?springboardWindow.alpha==0?0.0:1.0:0.0;
	[springboardWindow setTransform:newTransform];
	CGRect frame = springboardWindow.frame;
	frame.origin.y = yLoc;
	frame.origin.x = xLoc;
	springboardWindow.frame = frame;
	orientationOld = orientation;
	
	[UIView animateWithDuration:0.3f animations:^{
		[[[UIApplication sharedApplication] statusBarWindow] setHidden:!hideView];
		springboardWindow.alpha = hideView?0.0:1.0;
	} completion:nil];
}
@end

@interface MusicApplicationDelegateGet : NSObject
- (UIWindow*)window;
@end

%group groupHooks

%hook MusicApplicationDelegateGet
- (BOOL)application:(id)arg1 willFinishLaunchingWithOptions:(id)arg2
{
	BOOL ret = %orig;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		@try {
			MPMediaQuery* albums = [MPMediaQuery albumsQuery];
			items = [albums _hasCollections]?[albums collections]:nil;
			[(UIView *)[[UIApplication sharedApplication] keyWindow] addSubview:[[CoverflowM sharedInstance] springboardWindow]];
		}@catch(NSException* e) {
		}
	});
	return ret;
}
%end
%hook UIDevice
- (void)setOrientation:(UIDeviceOrientation)arg1
{
	%orig;
	[CoverflowM notifyOrientationChange];
}
- (void)setOrientation:(UIDeviceOrientation)arg1 animated:(BOOL)arg2
{
	%orig;
	[CoverflowM notifyOrientationChange];
}
%end

%end // END groupHooks


@interface CoverflowMCenter : NSObject {
	CPDistributedMessagingCenter * _messagingCenter;
}
@end

@implementation CoverflowMCenter
+ (void)load
{
	[self sharedInstance];
}
+ (instancetype)sharedInstance
{
	static dispatch_once_t once = 0;
	__strong static id sharedInstance = nil;
	dispatch_once(&once, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}
- (instancetype)init
{
	if ((self = [super init])) {
		_messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.julioverne.coverflowm.center"];
		rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
		[_messagingCenter runServerOnCurrentThread];
		[_messagingCenter registerForMessageName:@"actionPlayer" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	}
	return self;
}
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo
{
	int action = [userInfo[@"action"]?:@(0) intValue];
	MPMusicPlayerApplicationController* MPcontroller = [MPMusicPlayerController systemMusicPlayer];
	MPMediaQuery* albums = [MPMediaQuery albumsQuery];
	items = [albums _hasCollections]?[albums collections]:nil;
	if(MPcontroller != nil) {
		if(action==1) {
			int collectionIndex = [userInfo[@"collectionIndex"]?:@(0) intValue];
			int soundIndex = [userInfo[@"soundIndex"]?:@(0) intValue];
			MPMediaItemCollection* collectionSelected = (MPMediaItemCollection*)items[collectionIndex];
			MPMediaItem* song = [collectionSelected items][soundIndex];
			[MPcontroller setQueueWithItemCollection:collectionSelected];
			[MPcontroller setNowPlayingItem:song];
			[MPcontroller prepareToPlay];
			[MPcontroller play];
		} else if(action==2) {
			[MPcontroller pause];
		} else if(action==3) {
			[MPcontroller skipToNextItem];
		} else if(action==4) {
			[MPcontroller skipToPreviousItem];
		}
	}
	
	return @{};
}
@end


static void settingsChangedCoverflowM(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@autoreleasepool {
		NSDictionary *Prefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:@{} copy];
		Enabled = (BOOL)[Prefs[@"Enabled"]?:@YES boolValue];
		styleEnabled = (int)[Prefs[@"styleEnabled"]?:@(0) intValue];
		
		if([CoverflowM sharedInstanceExist]) {
			[[CoverflowMViewController sharedInstance] updateData];
		}
	}
}


%ctor
{
	@autoreleasepool {
		if(%c(SpringBoard)==nil) {
			kScreenW = [[UIScreen mainScreen] bounds].size.width;
			kScreenH = [[UIScreen mainScreen] bounds].size.height;
			
			centerMusic = [CPDistributedMessagingCenter centerNamed:@"com.julioverne.coverflowm.center"];
			rocketbootstrap_distributedmessagingcenter_apply(centerMusic);
			
			
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChangedCoverflowM, CFSTR("com.julioverne.coverflowm/SettingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
			settingsChangedCoverflowM(NULL, NULL, NULL, NULL, NULL);
			%init(groupHooks, MusicApplicationDelegateGet = objc_getClass("Music.ApplicationDelegate")?:objc_getClass("MusicApplication.ApplicationDelegate"));
		} else {
			[CoverflowMCenter load];
		}
	}
}


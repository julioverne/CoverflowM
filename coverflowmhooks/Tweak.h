@interface MPMediaQuery : NSObject
- (NSArray*)items;
+ (id)albumsQuery;
- (NSArray*)collections;
-(BOOL)_hasCollections;
@end
@interface MPMediaItem : NSObject
@property (nonatomic, readonly) NSURL *assetURL;
- (id)valueForProperty:(id)arg1;
- (id)imageWithSize:(CGSize)arg1;
@end
#import <dlfcn.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <notify.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#import "iCarousel/iCarousel.h"

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.coverflowm.plist"

#import "images.h"
#import "MediaRemote.h"

#import "ReflectionView/ReflectionView.h"
#import "MDAudioPlayerTableViewCell/MDAudioPlayerTableViewCell.h"

@interface MPMusicPlayerController : NSObject
+(id)iPodMusicPlayer;
+(id)applicationMusicPlayer;
+(id)systemMusicPlayer;
-(void)setQueueWithItemCollection:(id)arg1;
-(void)setNowPlayingItem:(id)arg1;
-(void)prepareToPlay;
-(void)play;
- (void)beginGeneratingPlaybackNotifications;
- (void)pause;
- (void)skipToNextItem;
- (void)skipToPreviousItem;
@end

@interface MPMediaItemCollection : NSObject
- (MPMediaItem*)representativeItem;
- (id)initWithItems:(id)arg1;
- (NSArray*)items;

@end

@interface MPCPlayerPath : NSObject
+ (id)deviceActivePlayerPath;
+ (id)systemMusicPathWithRoute:(id)arg1 playerID:(id)arg2 ;
+ (id)pathWithDeviceUID:(id)arg1 bundleID:(id)arg2 pid:(int)arg3 playerID:(id)arg4 ;
@end

@interface MPMusicPlayerApplicationController : MPMusicPlayerController
@property (nonatomic, retain) MPCPlayerPath *playerPath;
@end

@interface MPQueuePlayer : NSObject
- (void)removeAllItems;
- (void)insertItem:(id)arg1 afterItem:(id)arg2;
- (void)prepareItem:(id)arg1 withCompletionHandler:(id /* block */)arg2;
- (void)pause;
- (void)play;
@end

@interface ColectionHViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (assign) int collectionIndex;
@property (assign) int rowsCount;
@property (assign) BOOL isShowingAlbumInfo;
@property (nonatomic, strong) NSIndexPath* isShowingAlbumInfoIndexPath;
@end


@interface UINavigationBar ()
@property (nonatomic, strong) NSString *prompt;
-(void)_setBackgroundView:(id)a;
@end



@interface CoverflowMViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) iCarousel* carousel;
@property (nonatomic, strong) UILabel *titleName;
@property (nonatomic, strong) UILabel *artist;
@property (nonatomic, strong) UILabel *album;
@property (nonatomic, strong) UITableView* albumTableView;
@property (assign) int collectionIndex;
@property (nonatomic, strong) ColectionHViewController* collectionScroll;
+ (id)sharedInstance;
- (void)updateData;
@end

@interface CollectionTableAViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (assign) int indexRow;
- (void)updateData;
@end

@interface MusicSongCell : UIView
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *accessibilityDurationString;
@property (nonatomic, strong) NSString *accessibilityTrackNumberString;
@property (assign) BOOL wantsNowPlayingIndicator;
@property (assign) BOOL isExplicit;
@property (assign) NSInteger playbackState;
@property (assign) CGFloat duration;
@end

@interface CoverflowM : NSObject
{
	UIView* springboardWindow;
	CoverflowMViewController *controller;
}
@property (nonatomic, strong) UIView* springboardWindow;
@property (nonatomic, strong) CoverflowMViewController *controller;
+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
+ (void)notifyOrientationChange;
- (void)firstload;
- (void)orientationChanged;
@end

extern "C" id MPMediaItemPropertyTitle;
extern "C" id MPMediaItemPropertyAlbumTitle;
extern "C" id MPMediaItemPropertyArtist;
extern "C" id MPMediaItemPropertyArtwork;
extern "C" id MPMediaItemPropertyPlaybackDuration;
extern "C" id MPMediaItemPropertyAlbumTrackNumber;
extern "C" id MPMediaItemPropertyReleaseDate;


@interface PlayerButtonView : UIView
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) UIView *pauseView;
@property (nonatomic, strong) UIView *nextView;
@property (nonatomic, strong) UIView *prevView;
@property (nonatomic, strong) UIImageView* prevImageView;
@property (nonatomic, strong) UIImageView* pauseImageView;
@property (nonatomic, strong) UIImageView* playImageView;
@property (nonatomic, strong) UIImageView* nextImageView;
@property (nonatomic, assign) BOOL isPaused;
@end

@interface HorizontalCollectionViewLayout : UICollectionViewLayout
@property (nonatomic, assign) CGSize itemSize;
@end
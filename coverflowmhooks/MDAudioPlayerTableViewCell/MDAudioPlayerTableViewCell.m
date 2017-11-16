//
//  MDAudioPlayerTableViewCell.m
//  MDAudioPlayerSample
//
//  Created by Matt Donnelly on 04/08/2010.
//  Copyright 2010 Matt Donnelly. All rights reserved.
//

#import "MDAudioPlayerTableViewCell.h"
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)


@interface MDTableViewCellView : UIView
@end

@implementation MDTableViewCellView

- (void)drawRect:(CGRect)r
{
	UIView *superview = [self superview];
    if (![superview isKindOfClass:[UITableViewCell class]]) {
        superview = [superview superview];
    }
	[(MDAudioPlayerTableViewCell *)superview drawContentView:r];
}

@end


@implementation MDAudioPlayerTableViewCell

@synthesize title;
@synthesize number;
@synthesize duration;
@synthesize isEven;
@synthesize isSelectedIndex;

static UIFont *textFont = nil;

+ (void)initialize
{
	if (self == [MDAudioPlayerTableViewCell class])
	{
		textFont = [UIFont systemFontOfSize:11];
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
		contentView = [[MDTableViewCellView alloc] initWithFrame:CGRectZero];
		contentView.opaque = NO;
		[self addSubview:contentView];
	}
	
	return self;
}

- (void)setTitle:(NSString *)s
{
    title = s;
	[self setNeedsDisplay]; 
}

- (void)setNumber:(NSString *)s
{
    number = s;
	[self setNeedsDisplay]; 
}

- (void)setDuration:(NSString *)s
{
    duration = s;
	[self setNeedsDisplay]; 
}

- (void)setIsSelectedIndex:(BOOL)flag
{
	isSelectedIndex = flag;
	[self setNeedsDisplay];
}

- (void)setFrame:(CGRect)f
{
	[super setFrame:f];
	[contentView setFrame:[self bounds]];
}

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *bgColor;
	
	if (self.highlighted)
		bgColor = [UIColor blackColor];
	else
		bgColor = self.isEven ? [UIColor colorWithWhite:0.0 alpha:0.95] : [UIColor blackColor];
	
	UIColor *textColor = [UIColor whiteColor];
	UIColor *dividerColor = self.highlighted ? [UIColor clearColor] : [UIColor colorWithRed:0.986 green:0.933 blue:0.994 alpha:0.13];
	
	[bgColor set];
	CGContextFillRect(context, r);
	
	[textColor set];
	
	
	[number drawInRect:CGRectMake((r.size.width/55), (r.size.height/3.5), (r.size.width/10), (r.size.height/2)) withFont:textFont lineBreakMode:NSLineBreakByTruncatingTail];
	[title drawInRect:CGRectMake((r.size.width/7), (r.size.height/3.5), (r.size.width/1.6), (r.size.height/2)) withFont:textFont lineBreakMode:NSLineBreakByTruncatingTail];
	[duration drawInRect:CGRectMake((r.size.width/1.3), (r.size.height/3.5), (r.size.width/9), (r.size.height/2)) withFont:textFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentRight];
	
	[dividerColor set];
	
	CGContextSetLineWidth(context, 0.5);
	
	CGContextMoveToPoint(context, (r.size.width/8), 0.0);
	CGContextAddLineToPoint(context, (r.size.width/8), r.size.height);
	
	CGContextMoveToPoint(context, (r.size.width/1.3), 0.0);
	CGContextAddLineToPoint(context, (r.size.width/1.3), r.size.height);
	
	CGContextStrokePath(context);
	
	if (self.isSelectedIndex)
	{		
		[self.highlighted ? [UIColor whiteColor] : [UIColor colorWithRed:0.090 green:0.274 blue:0.873 alpha:1.000] set];
		
		CGContextMoveToPoint(context, 45, 17);
		CGContextAddLineToPoint(context, 45, 27);
		CGContextAddLineToPoint(context, 55, 22);
		
		CGContextClosePath(context);
		
		CGContextFillPath(context);
	}
}

@end

//
//  CustomCell.m
//  KATG.com
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "CustomCell.h"


@implementation CustomCell

@synthesize lblTitle, lblPublish, lblPublishDate, imgSquare;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        lblTitle.textColor = [UIColor blackColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:12.0];
		lblTitle.numberOfLines = 4;
		
        lblPublish = [[UILabel alloc] initWithFrame:CGRectZero];
        lblPublish.textColor = [UIColor darkGrayColor];
        lblPublish.font = [UIFont systemFontOfSize:12.0];
		
		lblPublishDate = [[UILabel alloc] initWithFrame:CGRectZero];
        lblPublishDate.textColor = [UIColor darkGrayColor];
        lblPublishDate.font = [UIFont systemFontOfSize:12.0];
        
        imgSquare = [[UIImageView alloc] initWithFrame:CGRectZero];
				
		[self.contentView addSubview:lblTitle];
        [self.contentView addSubview:lblPublish];
        [self.contentView addSubview:lblPublishDate];
        [self.contentView addSubview:imgSquare];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect baseRect = CGRectInset(self.contentView.bounds, 10, 0);
    CGRect rect = baseRect;
	
	rect.origin.x = self.contentView.bounds.size.width - 190;
    rect.origin.y = 0;
    rect.size.width = self.contentView.bounds.size.width - 120;
    lblTitle.frame = rect;
    
	rect.origin.x = self.contentView.bounds.size.width - 265;
    rect.origin.y = 45;
	rect.size.width = 70;
	rect.size.height = 20;
    lblPublish.frame = rect;
	
	rect.origin.y -= 30;
    lblPublishDate.frame = rect;
    
    rect.size.width = 20;
    rect.size.height = 20;
    rect.origin.x = self.contentView.bounds.size.width - 295;
    rect.origin.y = 30;
    imgSquare.frame = rect;
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    if (selected) {
        lblTitle.textColor = [UIColor whiteColor];
        lblPublish.textColor = [UIColor whiteColor];
		lblPublishDate.textColor = [UIColor whiteColor];
    } else {
        lblTitle.textColor = [UIColor blackColor];
        lblPublish.textColor = [UIColor darkGrayColor];
        lblPublishDate.textColor = [UIColor darkGrayColor];
    }
}

- (void)dealloc {
    [lblTitle release];
    [lblPublish release];
	[lblPublishDate release];
    [imgSquare release];
    [super dealloc];
}


@end

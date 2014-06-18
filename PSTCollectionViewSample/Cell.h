#import <UIKit/UIKit.h>
#import <PSTCollectionView/PSTCollectionView.h>

@interface Cell : PSUICollectionViewCell

@property (nonatomic, strong) UILabel *label;

- (void)setNumber:(NSString *)number;

@end

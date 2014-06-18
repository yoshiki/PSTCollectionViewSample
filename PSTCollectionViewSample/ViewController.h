#import <UIKit/UIKit.h>
#import <PSTCollectionView/PSTCollectionView.h>
#import "ReorderedCollectionViewLayout.h"

@interface ViewController : UIViewController <PSTCollectionViewDelegate, PSTCollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, ReorderedCollectionViewDataSource, ReorderedCollectionViewDelegateFlowLayout>

@end

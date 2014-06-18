#import <UIKit/UIKit.h>
#import <PSTCollectionView/PSTCollectionView.h>

@protocol ReorderedCollectionViewDataSource <PSUICollectionViewDataSource>

@optional
- (void)collectionView:(PSUICollectionView *)collectionView
       itemAtIndexPath:(NSIndexPath *)fromIndexPath
   willMoveToIndexPath:(NSIndexPath *)toIndexPath;

- (void)collectionView:(PSUICollectionView *)collectionView
       itemAtIndexPath:(NSIndexPath *)fromIndexPath
    didMoveToIndexPath:(NSIndexPath *)toIndexPath;

- (BOOL)collectionView:(PSUICollectionView *)collectionView
canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)collectionView:(PSUICollectionView *)collectionView
       itemAtIndexPath:(NSIndexPath *)fromIndexPath
    canMoveToIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol ReorderedCollectionViewDelegateFlowLayout <PSUICollectionViewDelegateFlowLayout>

@optional
- (void)collectionView:(PSUICollectionView *)collectionView
                layout:(PSUICollectionViewLayout *)collectionViewLayout
willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(PSUICollectionView *)collectionView
                layout:(PSUICollectionViewLayout *)collectionViewLayout
didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(PSUICollectionView *)collectionView
                layout:(PSUICollectionViewLayout *)collectionViewLayout
willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(PSUICollectionView *)collectionView
                layout:(PSUICollectionViewLayout *)collectionViewLayout
didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ReorderedCollectionViewLayout : PSUICollectionViewFlowLayout <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<ReorderedCollectionViewDataSource> dataSource;
@property (nonatomic, assign) id<ReorderedCollectionViewDelegateFlowLayout> delegate;

@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, assign, readonly) NSUInteger cellCount;

@end

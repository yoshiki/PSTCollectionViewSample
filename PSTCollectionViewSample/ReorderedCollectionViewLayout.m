#import "ReorderedCollectionViewLayout.h"

static int const ReorderedCollectionViewLayoutColumns = 3;

@interface ReorderedCollectionViewLayout ()

@property (nonatomic, strong) NSIndexPath *emptyCellIndexPath;
@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, strong) UIView *draggingCell;
@property (nonatomic, assign, getter = isAnimating) BOOL animating;

@end

@implementation ReorderedCollectionViewLayout

- (void)prepareLayout
{
    [super prepareLayout];

    _animating = NO;
    
    _cellCount = [self.collectionView numberOfItemsInSection:0];

    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleLongPressGesture:)];
    _longPressGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:_longPressGestureRecognizer];
}

- (CGSize)collectionViewContentSize
{
    int row = ceilf((float)_cellCount / ReorderedCollectionViewLayoutColumns);
    CGFloat width = ((self.minimumLineSpacing * 2) +
                     (self.minimumInteritemSpacing * (ReorderedCollectionViewLayoutColumns - 1)) +
                     (self.itemSize.width * ReorderedCollectionViewLayoutColumns));
    CGFloat height = ((self.minimumLineSpacing * 2) +
                      (self.minimumInteritemSpacing * (row - 1)) +
                      (self.itemSize.height * row));
    return (CGSize){ width, height };
}

- (void)applyLayoutAttributes:(PSUICollectionViewLayoutAttributes *)attributes
{
    int col = attributes.indexPath.row % ReorderedCollectionViewLayoutColumns;
    int row = (int)attributes.indexPath.row / ReorderedCollectionViewLayoutColumns;
    attributes.center = (CGPoint){
        self.minimumInteritemSpacing + (self.minimumLineSpacing * col) + (self.itemSize.width * col) + (self.itemSize.width / 2),
        self.minimumInteritemSpacing + (self.minimumLineSpacing * row) + (self.itemSize.height * row) + (self.itemSize.height / 2),
    };
    attributes.alpha = (([attributes.indexPath isEqual:self.emptyCellIndexPath]) ? 0.0f : 1.0f);
}

- (PSUICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PSUICollectionViewLayoutAttributes *attributes = (PSUICollectionViewLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];
    [self applyLayoutAttributes:attributes];
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesInRect = [super layoutAttributesForElementsInRect:rect];
    for (PSUICollectionViewLayoutAttributes *attributes in attributesInRect) {
        [self applyLayoutAttributes:attributes];
    }
    return attributesInRect;
}

#pragma mark - Handlers of gesture recognizer

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.collectionView];
    switch(recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:location];

            // Checking item can move
            if ([_dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)] &&
                ![_dataSource collectionView:(PSUICollectionView *)self.collectionView canMoveItemAtIndexPath:currentIndexPath]) {
                return;
            }

            _emptyCellIndexPath = currentIndexPath;
            _originalIndexPath = currentIndexPath;
            
            // Noticing will begin dragging
            if ([_delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
                [_delegate collectionView:(PSUICollectionView *)self.collectionView
                                       layout:(PSUICollectionViewLayout *)self
             willBeginDraggingItemAtIndexPath:_emptyCellIndexPath];
            }

            PSUICollectionViewCell *cell = (PSUICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:_emptyCellIndexPath];
            _draggingCell = [[UIView alloc] initWithFrame:cell.frame];
            _draggingCell.backgroundColor = [UIColor grayColor];
            [self.collectionView addSubview:_draggingCell];

            [UIView beginAnimations:@"" context:NULL];
            [UIView setAnimationDuration:0.2];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            
            // transformation-- larger, slightly transparent
            _draggingCell.transform = CGAffineTransformMakeScale(1.2, 1.2);
            _draggingCell.alpha = 0.7;
            
            // also make it center on the touch point
            _draggingCell.center = [recognizer locationInView:self.collectionView];
            
            [UIView commitAnimations];

            [self invalidateLayout];

            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (_emptyCellIndexPath == nil) return;

            [UIView beginAnimations:@"" context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(finishedSnap:finished:context:)];
            
            PSUICollectionViewCell *emptyCell = (PSUICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:_emptyCellIndexPath];
            CGRect r = emptyCell.frame;
            CGRect f = _draggingCell.frame;
            f.origin.x = r.origin.x + ceilf((r.size.width - f.size.width) * 0.5);
            f.origin.y = r.origin.y + ceilf((r.size.height - f.size.height) * 0.5);

            _draggingCell.frame = f;
            _draggingCell.transform = CGAffineTransformIdentity;
            _draggingCell.alpha = 1.0;
            
            if (_dataSource != nil &&
                [_dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)]) {
                CGPoint location = [recognizer locationInView:self.collectionView];
                NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
                [_dataSource collectionView:(PSUICollectionView *)self.collectionView
                                itemAtIndexPath:_originalIndexPath
                             didMoveToIndexPath:indexPath];
            }

            [UIView commitAnimations];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [recognizer locationInView:self.collectionView];

            // update draging cell location
            _draggingCell.center = location;
            
            if (self.isAnimating) break;

            NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:location];
            if (currentIndexPath == nil) {
                return;
            }

            if (currentIndexPath.row != _emptyCellIndexPath.row) {
                [self.collectionView performBatchUpdates:^{
                    _animating = YES;
                    if (currentIndexPath.row < _emptyCellIndexPath.row) {
                        for (NSUInteger i = currentIndexPath.row; i < _emptyCellIndexPath.row; i++) {
                            //NSLog( @"Moving %u to %u", i, i+1 );
                            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                            NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
                            if (_dataSource != nil &&
                                [_dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
                                [_dataSource collectionView:(PSUICollectionView *)self.collectionView
                                                itemAtIndexPath:fromIndexPath
                                            willMoveToIndexPath:toIndexPath];
                            }
                        }
                    } else {
                        for (NSUInteger i = currentIndexPath.row; i > _emptyCellIndexPath.row; i--) {
                            //NSLog( @"Moving %u to %u", i, i-1 );
                            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                            NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:i - 1 inSection:0];
                            if (_dataSource != nil &&
                                [_dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
                                [_dataSource collectionView:(PSUICollectionView *)self.collectionView
                                                itemAtIndexPath:fromIndexPath
                                            willMoveToIndexPath:toIndexPath];
                            }
                        }
                    }

                    if (_dataSource != nil &&
                        [_dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
                        [_dataSource collectionView:(PSUICollectionView *)self.collectionView
                                        itemAtIndexPath:self.emptyCellIndexPath
                                    willMoveToIndexPath:currentIndexPath];
                        self.emptyCellIndexPath = currentIndexPath;
                    }
                } completion:^(BOOL finished) {
                    [self invalidateLayout];
                    _animating = NO;
                }];
            }
            break;
        }
        default: {
            break;
        }
    }
}

- (void)finishedSnap:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    _emptyCellIndexPath = nil;
    
    // dismiss our copy of the cell
    [_draggingCell removeFromSuperview];
    _draggingCell = nil;
    
    [self invalidateLayout];
}

@end

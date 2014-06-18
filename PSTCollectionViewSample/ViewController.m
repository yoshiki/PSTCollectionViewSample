#import "ViewController.h"
#import "Cell.h"

@interface ViewController ()

@property (nonatomic, strong) PSUICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *numbers;

@end

@implementation ViewController

- (void)loadView
{
    [super loadView];
    
    ReorderedCollectionViewLayout *layout = [[ReorderedCollectionViewLayout alloc] init];
    layout.itemSize = (CGSize){ 100, 140 };
    layout.minimumLineSpacing = 5.0f;
    layout.minimumInteritemSpacing = 5.0f;
    layout.delegate = self;
    layout.dataSource = self;
    
    _collectionView = [[PSUICollectionView alloc] initWithFrame:self.view.bounds
                                           collectionViewLayout:layout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor cyanColor];
    [_collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:_collectionView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _numbers = @[].mutableCopy;
    for (int i = 0; i < 100; i++) {
        [_numbers addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

#pragma mark - ReorderedCollectionViewDataSource

- (NSInteger)collectionView:(PSUICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [_numbers count];
}

- (NSInteger)numberOfSectionsInCollectionView:(PSUICollectionView *)collectionView
{
    return 1;
}

- (PSUICollectionViewCell *)collectionView:(PSTCollectionView *)collectionView
                    cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    NSString *number = [_numbers objectAtIndex:indexPath.row];
    [cell setNumber:number];
    
    return cell;
}

- (void)collectionView:(PSUICollectionView *)collectionView
       itemAtIndexPath:(NSIndexPath *)fromIndexPath
   willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
//    NSLog(@"will %d -> %d", fromIndexPath.row, toIndexPath.row);
    [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)collectionView:(PSUICollectionView *)collectionView
       itemAtIndexPath:(NSIndexPath *)fromIndexPath
    didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
//    NSLog(@"did %d -> %d", fromIndexPath.row, toIndexPath.row);
    [_numbers exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}

@end

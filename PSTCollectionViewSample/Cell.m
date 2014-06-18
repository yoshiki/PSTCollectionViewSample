#import "Cell.h"

@implementation Cell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor blackColor];
        _label.font = [UIFont systemFontOfSize:20.0f];
        [_label sizeToFit];
        [self addSubview:_label];
    }
    return self;
}

- (void)setNumber:(NSString *)number
{
    _label.text = number;
    [_label sizeToFit];
}

@end

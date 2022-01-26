
#define USE_TI_UILISTVIEW
#define USE_TI_UIREFRESHCONTROL

#import <objc/runtime.h>
#import "TiUIListSectionProxy.h"
#import "TiUISearchBarProxy.h"
#import "TiUIListView.h"
#import "TiUIListViewProxy.h"
#import "TiUIListItem.h"
#import "TiUIListItemProxy.h"
#import "TiUIListView+Extension.h"


@implementation TiUIListView (Extension)

- (void)windowWillClose
{
    [[self tableView] removeObserver:self forKeyPath:@"contentSize"];
}


-(void)runBlock:(void (^)(void))block
{
    block();
}
-(void)runAfterDelay:(CGFloat)delay block:(void (^)(void))block
{
    void (^block_)(void) = [block copy];
    [self performSelector:@selector(runBlock:) withObject:block_ afterDelay:delay];
}

- (TiUIListViewProxy *)listViewProxy
{
  return (TiUIListViewProxy *)self.proxy;
}

- (id)defaultItemTemplate
{
   id defaultTemplate = [self.proxy valueForKey:@"defaultTemplate"];
   if (![defaultTemplate isKindOfClass:[NSString class]] && ![defaultTemplate isKindOfClass:[NSNumber class]]) {
    ENSURE_TYPE_OR_NIL(defaultTemplate, NSString);
  }
  return [defaultTemplate copy];
}


- (id)valueWithKey:(NSString *)key atIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *item = [[self.listViewProxy sectionForIndex:indexPath.section] itemAtIndex:indexPath.row];
  id propertiesValue = [item objectForKey:@"properties"];
  NSDictionary *properties = ([propertiesValue isKindOfClass:[NSDictionary class]]) ? propertiesValue : nil;
  id theValue = [properties objectForKey:key];
  if (theValue == nil) {
    id templateId = [item objectForKey:@"template"];
    if (templateId == nil) {
      templateId = _defaultItemTemplate;
    }
    if (![templateId isKindOfClass:[NSNumber class]]) {
      TiViewTemplate *template = [_templates objectForKey:templateId];
      theValue = [template.properties objectForKey:key];
    }
  }

  return theValue;
}

- (void)fireEditEventWithName:(NSString *)name andSection:(TiUIListSectionProxy *)section atIndexPath:(NSIndexPath *)indexPath item:(NSDictionary *)item
{
  //Fire the delete Event if required
  if ([self.proxy _hasListeners:name]) {

    NSMutableDictionary *eventObject = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                                        section, @"section",
                                                                    NUMINTEGER(indexPath.section), @"sectionIndex",
                                                                    NUMINTEGER(indexPath.row), @"itemIndex",
                                                                    nil];
    id propertiesValue = [item objectForKey:@"properties"];
    NSDictionary *properties = ([propertiesValue isKindOfClass:[NSDictionary class]]) ? propertiesValue : nil;
    id itemId = [properties objectForKey:@"itemId"];
    if (itemId != nil) {
      [eventObject setObject:itemId forKey:@"itemId"];
    }
    [self.proxy fireEvent:name withObject:eventObject withSource:self.proxy propagate:NO reportSuccess:NO errorCode:0 message:nil];
  }
}




#pragma mark Public APIs

- (void)setScrollIndicatorInsets_:(id)value withObject:(id)props
{
  UIEdgeInsets insets = [TiUtils contentInsets:value];
  BOOL animated = [TiUtils boolValue:@"animated" properties:props def:NO];
  void (^setInset)(void) = ^{
    [[self tableView] setScrollIndicatorInsets:insets];
  };
  if (animated) {
    double duration = [TiUtils doubleValue:@"duration" properties:props def:300] / 1000;
    [UIView animateWithDuration:duration animations:setInset];
  } else {
    setInset();
  }
}


- (void)setScrollToBottomOnce_:(id)args
{
    ENSURE_TYPE(args, NSNumber);
    BOOL scrollToBottomAfterSetData = [TiUtils boolValue:args def:NO];
    if (scrollToBottomAfterSetData == YES){
        [[self tableView] addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior context:NULL];
    }
}
 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {

        NSValue *new = [change valueForKey:@"new"];
        NSValue *old = [change valueForKey:@"old"];

        if (new && old) {
            if (![old isEqualToValue:new]) {
                
                BOOL scrollToBottomAfterSetData = [TiUtils boolValue:[self.proxy valueForKey:@"scrollToBottomOnce"] def:NO];
                
                if (scrollToBottomAfterSetData == YES){
                    [self.proxy replaceValue:[NSNumber numberWithInt:0] forKey:@"scrollToBottomOnce" notification:NO];
                    //[[self tableView] removeObserver:self forKeyPath:@"contentSize"];


                    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                        NSInteger count = [[self tableView] numberOfSections];
                        NSInteger rowCount = [[self tableView] numberOfRowsInSection:(count -1)];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:(count -1)];

                        NSLog(@"[WARN] count,rowCount,indexPath  %i  %i  %i ",count,rowCount,indexPath.row);

                        
                          [UIView performWithoutAnimation:^{
                              [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                          }];
                    //});
                 }
                
                
                NSMutableDictionary *contentDictionary = [[NSMutableDictionary alloc]init];
                [contentDictionary setValue:[NSNumber numberWithFloat:[self tableView].contentSize.height] forKey:@"height"];
                [contentDictionary setValue:[NSNumber numberWithFloat:[self tableView].contentSize.width] forKey:@"width"];
                
                
                [self.proxy replaceValue:contentDictionary forKey:@"contentSize" notification:YES];
                
            }
        }
    }
}
    

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)ourTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowDimHeight = 44;
    
    //TiThreadPerformOnMainThread(
      //  ^{

    NSIndexPath *realPath = [self pathForSearchPath:indexPath];
    id heightValue = [self valueWithKey:@"height" atIndexPath:realPath];
    TiDimension height = self->_rowHeight;
    
    if (heightValue != nil) {
      height = [TiUtils dimensionValue:heightValue];
    }

    if (TiDimensionIsDip(height)) {
        rowDimHeight = ceil(height.value);
    } else {
        TiUIListSectionProxy *theSection = [self.listViewProxy sectionForIndex:realPath.section];
        NSDictionary *item = [theSection itemAtIndex:realPath.row]; //get the item data
        id templateId = [item objectForKey:@"template"];
        if (templateId == nil) {
            templateId = self->_defaultItemTemplate;
        }
        
        TiUIListItem *theCell = [self->_measureProxies objectForKey:templateId];

        TiUIListItemProxy *theProxy = [theCell proxy];
        
        //if (theProxy != nil){

            [theProxy layoutProperties]->height = TiDimensionAutoSize;
        //}

        rowDimHeight = ceil([theProxy minimumParentHeightForSize:CGSizeMake([self tableView].bounds.size.width, self.bounds.size.height)]);
        
    }
     //   },
       //         YES);
    return rowDimHeight;

}



    
#pragma mark - ScrollView Delegate


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  //Let the cell configure its background
  [(TiUIListItem *)cell configureCellBackground];

  NSIndexPath *realPath = [self pathForSearchPath:indexPath];
  id tintValue = [self valueWithKey:@"tintColor" atIndexPath:realPath];
  UIColor *theTint = [[TiUtils colorValue:tintValue] color];
  if (theTint == nil) {
    theTint = [tableView tintColor];
  }
  [cell setTintColor:theTint];

  if (searchActive || [searchController isActive]) {
    return;
  } else {
    //Tell the proxy about the cell to be displayed for marker event
    [self.listViewProxy willDisplayCell:indexPath];
  }
}





- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![self.proxy _hasListeners:@"pull"] && ![self.proxy _hasListeners:@"scroll"]) {
        return;
    }

    if ([self.proxy _hasListeners:@"scroll"]) {
        if ([[self tableView] isDragging] || [[self tableView] isDecelerating]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                     @"contentOffset" : [TiUtils pointToDictionary:[self tableView].contentOffset],
                     @"contentSize" : [TiUtils sizeToDictionary:[self tableView].contentSize]
                }];
                [self.proxy fireEvent:@"scroll" withObject:event];
            });
        }
    }
    if (![self.proxy _hasListeners:@"pull"]) {
        return;
    }

    if (_pullViewProxy != nil && [scrollView isTracking]) {
        if (scrollView.contentOffset.y < pullThreshhold && !pullActive) {
          pullActive = YES;

        [self.proxy fireEvent:@"pull" withObject:[NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(pullActive), @"active", nil] withSource:self.proxy propagate:NO reportSuccess:NO errorCode:0 message:nil];
        } else if (scrollView.contentOffset.y > pullThreshhold && pullActive) {
            pullActive = NO;
          [self.proxy fireEvent:@"pull" withObject:[NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(pullActive), @"active", nil] withSource:self.proxy propagate:NO reportSuccess:NO errorCode:0 message:nil];
      }
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    BOOL paging = [TiUtils boolValue:[self.proxy valueForUndefinedKey:@"pagingEnabled"] def:NO];
    BOOL snapping = [TiUtils boolValue:[self.proxy valueForUndefinedKey:@"snappingEnabled"] def:NO];
    

          if (snapping == YES && paging == NO){
              NSIndexPath *indexPath = nil;
              indexPath = [[self tableView] indexPathForRowAtPoint:*targetContentOffset];
              CGRect cellRect = [[self tableView] rectForRowAtIndexPath:indexPath];
              CGFloat cellHeight = cellRect.size.height;
              CGFloat headerHeight = 0;
              CGFloat headerTopPadding = 0;

              CGFloat thisHeaderOriginY = [[[self tableView] delegate] tableView:[self tableView] viewForHeaderInSection:indexPath.section].bounds.origin.y;
              
              headerHeight = [[[self tableView] delegate] tableView:[self tableView] heightForHeaderInSection:indexPath.section];

              if (@available(iOS 15.0, macCatalyst 15.0, *)) {
                    if ([self tableView].sectionHeaderTopPadding == UITableViewAutomaticDimension){
                        headerTopPadding = 44;
                    }
                    else {
                        headerTopPadding = [self tableView].sectionHeaderTopPadding;
                    }
              }
              else {
                  
              }

                if (targetContentOffset->y >= ([self tableView].contentSize.height - [self tableView].frame.size.height - [self tableView].contentInset.top)) {
                }
                else {
                    
                    if (targetContentOffset->y <= 0){
                    }
                    else {
                        targetContentOffset->y = cellRect.origin.y - [self tableView].contentInset.top - headerHeight;
                    }
                }
              
                if ([self.proxy _hasListeners:@"scrolling"]) {

                    NSString *direction = nil;

                    if (velocity.y > 0) {
                      direction = @"up";
                    }

                    if (velocity.y < 0) {
                      direction = @"down";
                    }
                      
                    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                      @"targetContentOffset" : NUMFLOAT(targetContentOffset->y),
                      @"contentSize" : [TiUtils sizeToDictionary:scrollView.contentSize],
                      @"velocity" : NUMFLOAT(velocity.y)
                    }];
                    if (direction != nil) {
                      [event setValue:direction forKey:@"direction"];
                    }

                    [self.proxy fireEvent:@"scrolling" withObject:event];
                 }
          }
            
          else if (snapping == YES && paging == YES){
              
              CGFloat pageHeight = scrollView.frame.size.height;
              CGFloat currentOffset = scrollView.contentOffset.y;
              CGFloat targetOffset = targetContentOffset->y;
              CGFloat newTargetOffset = 0;

              if (targetOffset > currentOffset){
                  newTargetOffset = ceilf(currentOffset / pageHeight) * pageHeight;
              }
              else {
                  newTargetOffset = floorf(currentOffset / pageHeight) * pageHeight;
              }

              
              if (newTargetOffset == 0){
                  newTargetOffset = -(scrollView.contentInset.top);
              }
              
              
              if (newTargetOffset < -(scrollView.contentInset.top)){
                  newTargetOffset = -(scrollView.contentInset.top);
              }
              else if (newTargetOffset > scrollView.contentSize.height){
                  newTargetOffset = scrollView.contentSize.height;
              }
              else {
                  newTargetOffset = newTargetOffset - scrollView.contentInset.top;

              }

              
              NSIndexPath *indexPath = nil;
              indexPath = [[self tableView] indexPathForRowAtPoint:CGPointMake(scrollView.contentOffset.x, newTargetOffset)];
              CGRect cellRect = [[self tableView] rectForRowAtIndexPath:indexPath];
              CGFloat cellHeight = cellRect.size.height;
              CGFloat headerHeight = 0;
              CGFloat headerTopPadding = 0;
              CGFloat thisHeaderOriginY = [[[self tableView] delegate] tableView:[self tableView] viewForHeaderInSection:indexPath.section].bounds.origin.y;

              headerHeight = [[[self tableView] delegate] tableView:[self tableView] heightForHeaderInSection:indexPath.section];

              if (@available(iOS 15.0, macCatalyst 15.0, *)) {
                    if ([self tableView].sectionHeaderTopPadding == UITableViewAutomaticDimension){
                        headerTopPadding = 44;
                    }
                    else {
                        headerTopPadding = [self tableView].sectionHeaderTopPadding;
                    }
              }
              else {
                  
              }
              if (targetContentOffset->y >= ([self tableView].contentSize.height - [self tableView].frame.size.height - [self tableView].contentInset.top)) {
                  //[scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, newTargetOffset) animated:YES];

                  if ([self.proxy _hasListeners:@"scrolling"]) {

                    NSString *direction = nil;

                    if (velocity.y > 0) {
                      direction = @"up";
                    }

                    if (velocity.y < 0) {
                      direction = @"down";
                    }
                      
                    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                      @"targetContentOffset" : NUMFLOAT(newTargetOffset),
                      @"contentSize" : [TiUtils sizeToDictionary:scrollView.contentSize],
                      @"velocity" : NUMFLOAT(velocity.y)
                    }];
                    if (direction != nil) {
                      [event setValue:direction forKey:@"direction"];
                    }

                    [self.proxy fireEvent:@"scrolling" withObject:event];
                  }
              }
              else {
                  
                  if (targetContentOffset->y <= 0){
                  }
                  else {
                      //targetContentOffset->y = cellRect.origin.y - [self tableView].contentInset.top - headerHeight;
                      targetContentOffset->y = currentOffset;
                      [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, cellRect.origin.y - [self tableView].contentInset.top - headerHeight) animated:YES];

                  }
                  


                  if ([self.proxy _hasListeners:@"scrolling"]) {

                    NSString *direction = nil;

                    if (velocity.y > 0) {
                      direction = @"up";
                    }

                    if (velocity.y < 0) {
                      direction = @"down";
                    }
                      
                      if (targetContentOffset->y <= 0){
                          headerHeight = 0;
                      }
                      
                    NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                      @"targetContentOffset" : NUMFLOAT(cellRect.origin.y - [self tableView].contentInset.top - headerHeight),
                      @"contentSize" : [TiUtils sizeToDictionary:scrollView.contentSize],
                      @"velocity" : NUMFLOAT(velocity.y)
                    }];
                    if (direction != nil) {
                      [event setValue:direction forKey:@"direction"];
                    }

                    [self.proxy fireEvent:@"scrolling" withObject:event];
                  }
              }
              
          }
            
          else if (snapping == NO && paging == YES){
              
              CGFloat pageHeight = scrollView.frame.size.height;
              CGFloat currentOffset = scrollView.contentOffset.y;
              CGFloat targetOffset = targetContentOffset->y;
              CGFloat newTargetOffset = 0;

              if (targetOffset > currentOffset){
                  newTargetOffset = ceilf(currentOffset / pageHeight) * pageHeight;
              }
              else {
                  newTargetOffset = floorf(currentOffset / pageHeight) * pageHeight;
              }

              
              if (newTargetOffset == 0){
                  newTargetOffset = -(scrollView.contentInset.top);
              }
              
              
              if (newTargetOffset < -(scrollView.contentInset.top)){
                  newTargetOffset = -(scrollView.contentInset.top);
              }
              else if (newTargetOffset > scrollView.contentSize.height){
                  newTargetOffset = scrollView.contentSize.height;
              }
              else {
                  newTargetOffset = newTargetOffset - scrollView.contentInset.top;
                  targetContentOffset->y = currentOffset;

              }

              [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, newTargetOffset) animated:YES];

              if ([self.proxy _hasListeners:@"scrolling"]) {

                NSString *direction = nil;

                if (velocity.y > 0) {
                  direction = @"up";
                }

                if (velocity.y < 0) {
                  direction = @"down";
                }
                  
                NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                  @"targetContentOffset" : NUMFLOAT(newTargetOffset),
                  @"contentSize" : [TiUtils sizeToDictionary:scrollView.contentSize],
                  @"velocity" : NUMFLOAT(velocity.y)
                }];
                if (direction != nil) {
                  [event setValue:direction forKey:@"direction"];
                }

                [self.proxy fireEvent:@"scrolling" withObject:event];
              }
          }
          else {
              if ([self.proxy _hasListeners:@"scrolling"]) {

                  NSString *direction = nil;

                  if (velocity.y > 0) {
                    direction = @"up";
                  }

                  if (velocity.y < 0) {
                    direction = @"down";
                  }
                    
                  NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                    @"targetContentOffset" : NUMFLOAT(targetContentOffset->y),
                    @"contentSize" : [TiUtils sizeToDictionary:scrollView.contentSize],
                    @"velocity" : NUMFLOAT(velocity.y)
                  }];
                  if (direction != nil) {
                    [event setValue:direction forKey:@"direction"];
                  }

                  [self.proxy fireEvent:@"scrolling" withObject:event];
               }
          }
}


@end


#define USE_TI_UILISTVIEW
#define USE_TI_UIREFRESHCONTROL

#import "TiBase.h"
#import "TiUIListView.h"
#import "TiUIListViewProxy.h"
#import "TiUIListItem.h"
#import "TiUIListItemProxy.h"
#import <TitaniumKit/TiViewProxy.h>
#import <TitaniumKit/TiUIView.h>
#import "TiUIRefreshControlProxy.h"


@interface TiUIListView () {
    
    UITableView *_tableView;
    NSDictionary<id, TiViewTemplate *> *_templates;
    id _defaultItemTemplate;

    TiDimension _rowHeight;
    TiViewProxy *_headerViewProxy;
    TiViewProxy *_searchWrapper;
    TiViewProxy *_headerWrapper;
    TiViewProxy *_footerViewProxy;
    TiViewProxy *_pullViewProxy;
    TiUIRefreshControlProxy *_refreshControlProxy;

    TiUISearchBarProxy *searchViewProxy;
    UISearchController *searchController;
    UIViewController *searchControllerPresenter;

    NSMutableArray<NSString *> *sectionTitles;
    NSMutableArray<NSNumber *> *sectionIndices;
    NSMutableArray<NSString *> *filteredTitles;
    NSMutableArray<NSNumber *> *filteredIndices;

    UIView *_pullViewWrapper;
    CGFloat pullThreshhold;

    BOOL pullActive;
    CGPoint tapPoint;
    BOOL editing;
    BOOL pruneSections;

    BOOL caseInsensitiveSearch;
    NSString *_searchString;
    BOOL searchActive;
    BOOL keepSectionsInSearch;
    NSMutableArray *_searchResults;
    UIEdgeInsets _defaultSeparatorInsets;
    UIEdgeInsets _rowSeparatorInsets;

    NSMutableDictionary<id, TiUIListItem *> *_measureProxies;

    BOOL canFireScrollStart;
    BOOL canFireScrollEnd;
    BOOL isScrollingToTop;

    BOOL _dimsBackgroundDuringPresentation;
    CGPoint tableContentOffset;
    BOOL isSearched;
    UIView *dimmingView;
    BOOL isSearchBarInNavigation;
}



#pragma mark - Private APIs
@property (nonatomic, readwrite) UITableView *tableView;
@property (nonatomic, readwrite) BOOL isSearchActive;

- (void)setDictTemplates_:(id)args;
- (void)setContentOffset_:(id)value withObject:(id)args;
- (void)setContentInsets_:(id)value withObject:(id)props;
- (void)deselectAll:(BOOL)animated;
- (void)updateIndicesForVisibleRows;
- (void)viewResignFocus;
- (void)viewGetFocus;
+ (UITableViewRowAnimation)animationStyleForProperties:(NSDictionary *)properties;
- (NSIndexPath *)pathForSearchPath:(NSIndexPath *)indexPath;
@end


@interface TiUIListView (Extension)
#pragma mark - Public APIs

@end

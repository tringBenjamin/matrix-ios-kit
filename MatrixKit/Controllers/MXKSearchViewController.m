/*
 Copyright 2015 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXKSearchViewController.h"

// TODO: To replace with dedicated search cell
#import "MXKRecentTableViewCell.h"

@interface MXKSearchViewController ()
{
    /**
     Optional bar buttons
     */
    UIBarButtonItem *searchBarButton;

    /**
     Search handling
     */
    BOOL ignoreSearchRequest;
}
@end

@implementation MXKSearchViewController
@synthesize dataSource, shouldScrollToTopOnRefresh;

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([MXKSearchViewController class])
                          bundle:[NSBundle bundleForClass:[MXKSearchViewController class]]];
}

+ (instancetype)searchViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([MXKSearchViewController class])
                                          bundle:[NSBundle bundleForClass:[MXKSearchViewController class]]];
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Check whether the view controller has been pushed via storyboard
    if (!_searchTableView)
    {
        // Instantiate view controller objects
        [[[self class] nib] instantiateWithOwner:self options:nil];
    }

    // Adjust Top and Bottom constraints to take into account potential navBar and tabBar.
    if ([NSLayoutConstraint respondsToSelector:@selector(deactivateConstraints:)])
    {
        [NSLayoutConstraint deactivateConstraints:@[_searchSearchBarTopConstraint, _searchTableViewBottomConstraint]];
    }
    else
    {
        [self.view removeConstraint:_searchSearchBarTopConstraint];
        [self.view removeConstraint:_searchTableViewBottomConstraint];
    }

    _searchSearchBarTopConstraint = [NSLayoutConstraint constraintWithItem:self.topLayoutGuide
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.searchSearchBar
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0f
                                                                   constant:0.0f];

    _searchTableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.searchTableView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0f
                                                                      constant:0.0f];

    if ([NSLayoutConstraint respondsToSelector:@selector(activateConstraints:)])
    {
        [NSLayoutConstraint activateConstraints:@[_searchSearchBarTopConstraint, _searchTableViewBottomConstraint]];
    }
    else
    {
        [self.view addConstraint:_searchSearchBarTopConstraint];
        [self.view addConstraint:_searchTableViewBottomConstraint];
    }

    // Hide search bar by default
    self.searchSearchBar.hidden = YES;
    self.searchSearchBarHeightConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];

    searchBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];

    // Add search option in navigation bar
    self.enableSearchButton = YES;

    // Finalize table view configuration
    _searchTableView.delegate = self;
    _searchTableView.dataSource = dataSource; // Note: dataSource may be nil here


    //@TODO
    // Set up classes to use for cells
    [self.searchTableView registerNib:MXKRecentTableViewCell.nib forCellReuseIdentifier:MXKRecentTableViewCell.defaultReuseIdentifier];

    //_searchTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Restore search mechanism (if enabled)
    ignoreSearchRequest = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // The user may still press search button whereas the view disappears
    ignoreSearchRequest = YES;
}


#pragma mark - Override MXKViewController

- (void)onKeyboardShowAnimationComplete
{
    // Report the keyboard view in order to track keyboard frame changes
    self.keyboardView = _searchSearchBar.inputAccessoryView.superview;
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight
{
    // Deduce the bottom constraint for the table view (Don't forget the potential tabBar)
    CGFloat tableViewBottomConst = keyboardHeight - self.bottomLayoutGuide.length;
    // Check whether the keyboard is over the tabBar
    if (tableViewBottomConst < 0)
    {
        tableViewBottomConst = 0;
    }

    // Update constraints
    _searchTableViewBottomConstraint.constant = tableViewBottomConst;

    // Force layout immediately to take into account new constraint
    [self.view layoutIfNeeded];
}

- (void)destroy
{
    _searchTableView.dataSource = nil;
    _searchTableView.delegate = nil;
    _searchTableView = nil;
    
    dataSource.delegate = nil;
    dataSource = nil;
    
    [super destroy];
}

#pragma mark -

- (void)displaySearch:(MXKSearchDataSource*)searchDataSource
{
    dataSource = searchDataSource;
    dataSource.delegate = self;

    if (_searchTableView)
    {
        // Set up table data source
        _searchTableView.dataSource = dataSource;
    }
}


#pragma mark - UIBarButton handling

- (void)setEnableSearchButton:(BOOL)enableSearchButton
{
    _enableSearchButton = enableSearchButton;
    [self refreshUIBarButtons];
}

- (void)refreshUIBarButtons
{
    if (_enableSearchButton)
    {
        self.navigationItem.rightBarButtonItems = @[searchBarButton];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

#pragma mark - MXKDataSourceDelegate

- (Class<MXKCellRendering>)cellViewClassForCellData:(MXKCellData*)cellData
{
    // Return the default recent table view cell
    return MXKRecentTableViewCell.class;
}

- (NSString *)cellReuseIdentifierForCellData:(MXKCellData*)cellData
{
    // Return the default recent table view cell
    return MXKRecentTableViewCell.defaultReuseIdentifier;
}

- (void)dataSource:(MXKDataSource *)dataSource didCellChange:(id)changes
{
    // For now, do a simple full reload
    [_searchTableView reloadData];
}

- (void)dataSource:(MXKDataSource*)dataSource didStateChange:(MXKDataSourceState)state
{
    // MXKSearchDataSource comes back to the `MXKDataSourceStatePreparing` when searching
    if (state == MXKDataSourceStatePreparing)
    {
        [self startActivityIndicator];
    }
    else
    {
        [self stopActivityIndicator];
    }
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MXKSearchCellDataStoring> cellData = [dataSource cellDataAtIndex:indexPath.row];

    Class<MXKCellRendering> class = [self cellViewClassForCellData:cellData];
    return [class heightForCellData:cellData withMaximumWidth:0];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: This requires context api
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Release here resources, and restore reusable cells
    if ([cell respondsToSelector:@selector(didEndDisplay)])
    {
        [(id<MXKCellRendering>)cell didEndDisplay];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // "Done" key has been pressed
    [searchBar resignFirstResponder];

    // Apply filter
    if (searchBar.text.length)
    {
        shouldScrollToTopOnRefresh = YES;
        [dataSource searchMessageText:searchBar.text];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Leave search
    [searchBar resignFirstResponder];

    self.searchSearchBar.hidden = YES;
    self.searchSearchBarHeightConstraint.constant = 0;
    [self.view setNeedsUpdateConstraints];

    self.searchSearchBar.text = nil;
}

#pragma mark - Actions

- (void)search:(id)sender
{
    // The user may have pressed search button whereas the view controller was disappearing
    if (ignoreSearchRequest)
    {
        return;
    }

    if (self.searchSearchBar.isHidden)
    {
        self.searchSearchBar.hidden = NO;
        self.searchSearchBarHeightConstraint.constant = 44;
        [self.view setNeedsUpdateConstraints];

        [self.searchSearchBar becomeFirstResponder];
    }
    else
    {
        [self searchBarCancelButtonClicked: self.searchSearchBar];
    }
}

@end

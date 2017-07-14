# ios-KonoContentKit-Demo

## We build this demo app for showing integration with Kono Content Kit

[KCService contentManager] is a singleton instance provided by Kono-Content Kit, which would provide the communication interface for we to require the content information and asset from Kono's content server. We will highlight the key point and reference to the demo project's code.

### Kono-Content Kit setup code
  Before we start to use the content manager, we must setup the default configuration accroding to the project.
[Init code](KonoContentKit-Demo/AppDelegate.m)

  ```objc
  [contentManager initializeApiURL:{Kono Content server address}];
  [contentManager initializeHTMLDecryptSecret:{random string}];
  [contentManager initializeBundleDecryptSecret:{random string}];

  //We will use the AccessID and Token as the parameter to retrieve all content through ContentKit
  [contentManager initializeAccessID:{A Kono user id}];
  [contentManager initializeToken:{The Kono user's access token}];
  ```

### Fetch Title information and show all books sorted by years
  [KEBookLibraryTitleViewController](KonoContentKit-Demo/Issue%20List/KEBookLibraryTitleViewController.m) would show the title description in the beginning and use a UITableview as the frame to display all magazines sorted by year. For each year, we use a collectionview for horizontal scroll design. The following code shows how we get information for all magazines.

  ```objc
- (void)getTitleBooksDictionary {

  [[KCService contentManager] getAllYearsContainBooksForTitleID:KonoContentKitDemoMagazine complete:^(NSArray *yearArray) {

    self.categoryYearArray = [NSMutableArray arrayWithArray:yearArray];
    for( NSDictionary* titleYear in yearArray ) {
      NSString *year;
      year = [[titleYear objectForKey:@"year"] stringValue];
      NSMutableArray *booksArray = [self.booksDictionary objectForKey:[[titleYear objectForKey:@"year"] stringValue]];
      if( booksArray == nil ){
        [[KCService contentManager] getAllBooksForTitleID:KonoContentKitDemoMagazine forYear:year complete:^(NSArray *bookArray) {
          [self.booksDictionary setObject:bookArray forKey:year];
          [weakSelf.tableView reloadData];
        } fail:^(NSError *error) {
        }];
      }
    }
    [weakSelf.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];

  } fail:^(NSError *error) {
    [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
  }];
}
  ```

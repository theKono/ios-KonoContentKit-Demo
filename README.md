# ios-KonoContentKit-Demo

## We build this demo app for showing integration with Kono Content Kit

[KCService contentManager] is a singleton instance provided by Kono-Content Kit, which would provide the communication interface for we to require the content information and asset from Kono's content server. We will highlight the key point and reference to the demo project's code. We will also try to explain the viewer implement concept.

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

### Article Viewer  - [Data] Get magazine(Book) info
[KEArticleViewController](KonoContentKit-Demo/Article/KEArticleViewController.m) is the main article viewer controller. 

We use fetchTOCInfo function to get magazine public infofmation. In fetchTOCInfo, we will fetch the magazine detail info including each articles' properties. In Kono-Content Kit, we will parse these information into KEBook object and construct articleArray with KEBookArticle object, pageMappingArray with KCBookPage.

```objc
[[KCService contentManager] getAllArticlesForBook:self.bookItem complete:^(KCBook *book) {

  [[KCService contentManager] getThumbnailForBook:self.bookItem complete:^(KCBook *book) {

    NSInteger tableViewIdx = [self getTableViewIndex:0];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.articlePDFView.tableView reloadData];
        [self.articlePDFView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tableViewIdx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });

    } fail:^(NSError *error) {
  }];

  } fail:^(NSError *error) {
}];
```

### Article Viewer - [Data] Get PDF file

Each PDF page in our Content server is stored as an encrypted zip file. If we want to show the page, we need to use premium user id and user access token. Then start to download the encrypted zip file. After download complete, use the html secret (we get it in the init code) to decrypt, then unzip. Finally, we let webview to load the unzip file folder. We focus on the data part.

```objc

[[KCService contentManager] getPageHTMLForBookPage:page progress:nil complete:^(NSString *bundleFilePath) {
  
  // bundleFilePath is default file path we construct in SDK, it would be the same value as page.htmlFilePath
  [self.articlePDFView reloadPageAtIndex:index];
                  
  }fail:^(NSError *error) {
                        NSLog(@"download HTML file failed:%@",error);
}];

```

### Article Viewer - [View] PDF viewer portrait

We create [NESandwichView](KonoContentKit-Demo/Sandwich/NESandwichView.m) class as the frame. It based on a rotate UITableView, and each tableviewCell contains Webview to render data. [KEPageWebView](KonoContentKit-Demo/Sandwich/KEPageWebView.m) is inherited from WKWebview for iOS9 or above iOS version, [KEFatPageWebView](KonoContentKit-Demo/Sandwich/KEFatPageWebView.m) is inherited from UIWebview for iOS 8.

* Code execution flow
1. Triggered by tableview delegate (NESandwichView.m)
2. Try to load content into certain webview (NESandwichView.m)
3. Call the delegate to get content (KEArticleViewController.m)
4. Ask webview to load content

```objc
// NESandwichView.m
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //....
    [self loadPageAtIndex:indexPath.row inWebView:webview isPreload:NO];
}

- (void)loadPageAtIndex:(NSInteger)idx inWebView:(KEPageWebView*)webview isPreload:(BOOL)isPreload {
    NSString *path = [self.dataSource htmlFilePathForItemAtIndex:idx isPreload:isPreload];

    //.....
}

// KEArticleViewController.m
- (NSString *)htmlFilePathForItemAtIndex:(NSInteger)index isPreload:(BOOL)isPreload {
    // if we have already fetched data through SDK, we can return file path
    NSString *filePath = [page.htmlFilePath stringByAppendingPathComponent:@"index.html"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                
      if (self.currentMagazineIndex == magazinePageIdx) {
          [self showArticlePDFView];
      }
      if (self.isNeedShowFlipIndicator) {
        [self showSwipeIndicator];
      }
                                
      return filePath;
    }
    //...
}

// NESandwichView.m
- (void)loadPageAtIndex:(NSInteger)idx inWebView:(KEPageWebView*)webview isPreload:(BOOL)isPreload {
  
  //...
  NSURL *url = [NSURL fileURLWithPath:path];
  NSString *directory = [path stringByDeletingLastPathComponent];
  NSURL *dir_url = [NSURL fileURLWithPath:directory isDirectory:YES];

  [webview loadFileURL:url allowingReadAccessToURL:dir_url withComplete:^{
  //...

  }withFail:^(NSError *error) {
    //...
  }];

}

```

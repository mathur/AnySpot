#import <substrate.h>
#import <UIKit/UIKit.h>

@interface SBSearchHeader
@property(readonly, retain, nonatomic) UITextField *searchField;
@end


@interface SBSearchViewController
- (void)_searchFieldEditingChanged;
@end


%hook SBSearchViewController
- (void)_searchFieldReturnPressed {
	SBSearchHeader *_searchHeader = MSHookIvar<SBSearchHeader*>(self, "_searchHeader");
	UITextField *searchField = _searchHeader.searchField;
	NSString *searchString = [searchField.text lowercaseString];
	NSString *myUrl = @"";
	NSString *my_bool = @"no";

	// d = DuckDuckGo
	if ([searchString hasPrefix:[[@"d" lowercaseString] stringByAppendingString:@" "]])
	{
		searchString = [searchString stringByReplacingOccurrencesOfString:[[@"d" lowercaseString] stringByAppendingString:@" "] withString:@""];
		myUrl = @"https://duckduckgo.com/?q=";
		my_bool = @"search";
	}
	// g = google
	else if ([searchString hasPrefix:[[@"g" lowercaseString] stringByAppendingString:@" "]])
	{
		searchString = [searchString stringByReplacingOccurrencesOfString:[[@"g" lowercaseString] stringByAppendingString:@" "] withString:@""];
		myUrl = @"http://www.google.com/search?q=";
		my_bool = @"search";
	}
	// s = siri
	else if ([searchString hasPrefix:[[@"s" lowercaseString] stringByAppendingString:@" "]])
	{
		NSString *searchStringWithoutSiri = [searchString stringByReplacingOccurrencesOfString:@"siri" withString:@""];
			if (![[searchStringWithoutSiri stringByReplacingOccurrencesOfString:@" " withString:@""] isEqual:@""]) {
				NSArray *myStrings = [NSArray arrayWithObjects:searchStringWithoutSiri, nil];
				[(SpringBoard *)[UIApplication sharedApplication] setNextAssistantRecognitionStrings:myStrings];
			}
		SBAssistantController *assistantController = [%c(SBAssistantController) sharedInstance];
		[assistantController handleSiriButtonDownEventFromSource:1 activationEvent:1];
		[assistantController handleSiriButtonUpEventFromSource:1];
		searchField.text = @"";
		[self _searchFieldEditingChanged];
		[self dismissAnimated:YES completionBlock:nil];
	}
	// w = wikipedia
	else if ([searchString hasPrefix:[[@"w" lowercaseString] stringByAppendingString:@" "]])
	{
		searchString = [searchString stringByReplacingOccurrencesOfString:[[@"w" lowercaseString] stringByAppendingString:@" "] withString:@""];
		myUrl = @"http://en.wikipedia.org/wiki/";
		my_bool = @"search";
	}
	// y = yahoo
	else if ([searchString hasPrefix:[[@"y" lowercaseString] stringByAppendingString:@" "]])
	{
		searchString = [searchString stringByReplacingOccurrencesOfString:[[@"y" lowercaseString] stringByAppendingString:@" "] withString:@""];
		myUrl = @"https://search.yahoo.com/search?p=";
		my_bool = @"search";
	}

	if([my_bool isEqualToString: @"no"])
	{
		myUrl = searchString;
		%orig;
	}
	else if([my_bool isEqualToString: @"search"])
	{
		if (![[searchString stringByReplacingOccurrencesOfString:@" " withString:@""] isEqual:@""])
		{
			searchString=	[searchString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
			myUrl=[myUrl stringByAppendingString:searchString];
			Class aClass = objc_getClass("UIApplication");
			[[aClass sharedApplication] openURL:[NSURL URLWithString:myUrl]];
			searchField.text = @"";
			[self _searchFieldEditingChanged];
		}
		else{
		searchString = myUrl;
		%orig;
		}
	}
	else
	{
		// nothing
	}
}

%end

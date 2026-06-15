//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
#if __has_include(<AppKit/AppKit.h>)
#import <AppKit/AppKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol NSTextSuggestionsDelegate;
@class NSSavePanel, NSDocument;
/// Private out-of-process Save panel (subclass of NSSavePanel). Minimal stub for the category below.
@interface NSRemoteSavePanel : NSSavePanel
@end

#pragma mark - AppKit global preference & C entry points

/// Cached global default (NSGlobalDomain). Returns YES when Smart Naming is suppressed.
/// Read via AppKit's `_NSGetBoolAppConfig`; on by default (TextEdit drives it from autosave).
extern BOOL NSSmartNamingDisabled(void);
extern void SetNSSmartNamingDisabled(BOOL);   ///< debug setter (writes the cached value)
extern void ResetNSSmartNamingDisabled(void); ///< debug reset (re-reads the default)

/// userInfo keys for the dictionary handed to
/// `+[NSSmartNamingSuggestionWrapper requestSmartNameSuggestionsForURL:...]`'s completion block.
/// (Names are exact; their use as the response-dictionary keys is inferred from naming + flow.)
extern NSString * const NSSmartNamingSuggestionsRequestKey;
extern NSString * const NSSmartNamingSuggestionsRequestURLKey;
extern NSString * const NSSmartNamingSuggestionsRequestDestinationURLKey;
extern NSString * const NSSmartNamingSuggestionsResponseKey;
extern NSString * const NSSmartNamingSuggestionsResponseSuggestionsKey; ///< NSArray<NSString *> *
extern NSString * const NSSmartNamingSuggestionsResponseErrorKey;       ///< NSError *

#pragma mark - SmartNameSuggestions.framework (the engine)
// /System/Library/PrivateFrameworks/SmartNameSuggestions.framework  (NEW in 27.0)
// dlopen(".../SmartNameSuggestions.framework/SmartNameSuggestions", RTLD_NOW) before use.

@class SNNameSuggestionResponse;

/// Abstract base request. Concrete subclasses below describe a file, a folder, or (internally)
/// an image. Backed by a URL + UTType; `localeIdentifier` lets the model name in the user's locale,
/// and `siblingNames` is used to avoid colliding with names already in the destination folder.
API_AVAILABLE(macos(27.0))
@interface SNNameSuggestionRequest : NSObject
@property (nonatomic, copy) NSArray<NSString *> *siblingNames;     // T@"NSArray",N,C
@property (nonatomic, readonly) BOOL isDirectory;                  // TB,N,R
@property (nonatomic, readonly) NSURL *url;                        // T@"NSURL",N,R
@property (nonatomic, copy) NSString *localeIdentifier;           // T@"NSString",N,C
/// Lists the visible item names in a directory (used to build sibling/children context).
+ (nullable NSArray<NSString *> *)visibleItemNamesIn:(NSURL *)directory
                                  forChildrenRequest:(BOOL)forChildren
                                        forDirectory:(BOOL)forDirectory
                                            dropName:(nullable NSString *)dropName
                                               error:(NSError **)error; // @48@0:8@16B24B28@32^@40
- (BOOL)fetchMissingAttributes;                                   // B16@0:8 — lazily pulls metadata
@end

/// Request to name a FILE. The service fills `textContent`/`textSummary` (it reads the doc's
/// Spotlight `kMDItemTextContent`, summarizes, and truncates to a word limit) and, for media,
/// a `locationString` (city/region from EXIF). `speculative` requests are the cheap background
/// ones AppKit fires during autosave.
API_AVAILABLE(macos(27.0))
@interface SNFileSuggestionRequest : SNNameSuggestionRequest <NSSecureCoding>
@property (nonatomic, copy) NSString *textSummary;                // T@"NSString",N,C
@property (nonatomic, copy) NSString *textContent;                // T@"NSString",N,C
@property (nonatomic, copy) NSString *locationString;             // T@"NSString",N,C
@property (nonatomic, copy) NSDate *creationDate;                 // T@"NSDate",N,C
/// Designated initializer. `typeIdentifier` is a UTType id (e.g. "public.rtf"); pass
/// `speculative:YES` for background/autosave requests.
- (nullable instancetype)initWithURL:(NSURL *)url
                       typeIdentifier:(nullable NSString *)typeIdentifier
                          speculative:(BOOL)speculative
                                error:(NSError **)error;          // @44@0:8@16@24B32^@36
@end

/// Request to name a FOLDER, derived from the names of its children.
API_AVAILABLE(macos(27.0))
@interface SNDirectorySuggestionRequest : SNNameSuggestionRequest <NSSecureCoding>
@property (nonatomic, copy) NSArray<NSString *> *childrenNames;   // T@"NSArray",N,C
- (nullable instancetype)initWithURL:(NSURL *)url
                       typeIdentifier:(nullable NSString *)typeIdentifier
                          speculative:(BOOL)speculative
                                error:(NSError **)error;          // @44@0:8@16@24B32^@36
@end

/// The model's answer. `suggestions` / suggested base names are ranked; `reasoning` is the model's
/// rationale; `bestExtension` is the recommended path extension; `suggestionsWithExtension:` returns
/// names with/without the extension appended.
API_AVAILABLE(macos(27.0))
@interface SNNameSuggestionResponse : NSObject <NSSecureCoding>
@property (nonatomic, readonly) NSArray<NSString *> *suggestions; // T@"NSArray",N,R
@property (nonatomic, readonly) BOOL isDirectory;                 // TB,N,R
@property (nonatomic, readonly) NSURL *requestURL;                // T@"NSURL",N,R
@property (nonatomic, readonly, nullable) NSString *reasoning;    // T@"NSString",N,R
@property (nonatomic, readonly, nullable) NSString *bestExtension;// T@"NSString",N,R
- (NSArray<NSString *> *)suggestionsWithExtension:(BOOL)withExtension; // @20@0:8B16
- (instancetype)initWithSuggestions:(NSArray<NSString *> *)suggestions
                                url:(NSURL *)url
                          directory:(BOOL)directory
                       pathExtension:(nullable NSString *)pathExtension; // @44@0:8@16@24B32@36
- (instancetype)initWithSuggestions:(NSArray<NSString *> *)suggestions
                                url:(NSURL *)url
                          directory:(BOOL)directory
                          reasoning:(nullable NSString *)reasoning;       // @44@0:8@16@24B32@36
@end

/// High-level client. This is the most convenient probing entry point: check `+isAvailable`
/// (Apple Intelligence + feature flag), build an SN*SuggestionRequest, and call
/// `-suggestNamesFor:completion:`. Internally it XPCs to com.apple.SmartNameSuggestionsService.
API_AVAILABLE(macos(27.0))
@interface SNSmartNameSuggestionsClient : NSObject
+ (BOOL)isEnabled;                                  // B16@0:8 — feature flag / user default
+ (BOOL)isAvailable;                                // B16@0:8 — model assets downloaded & usable
+ (NSNotificationName)availabilityDidChangeNotification; // @16@0:8 (SNSmartNameSuggestionsAvailabilityDidChange)
- (instancetype)init;
- (void)invalidate;                                 // tears down the XPC connection
- (void)suggestNamesFor:(SNNameSuggestionRequest *)request
             completion:(void (^)(SNNameSuggestionResponse *_Nullable response,
                                  NSError *_Nullable error))completion;
                 // v32@0:8@"SNNameSuggestionRequest"16@?<v@?@"SNNameSuggestionResponse"@"NSError">24
@end

/// Raw XPC protocol vended by com.apple.SmartNameSuggestionsService (the .xpc inside the
/// framework). Useful if you want to talk to the service directly via NSXPCConnection.
API_AVAILABLE(macos(27.0))
@protocol SmartNameSuggestionsServiceProtocol <NSObject>
@required
- (void)warmupWith:(void (^)(void))reply;                                   // v24@0:8@?16
- (void)getSuggestionsWithRequest:(SNNameSuggestionRequest *)request
                             with:(void (^)(SNNameSuggestionResponse *_Nullable,
                                            NSError *_Nullable))reply;        // v32@0:8@16@?24
@end

#pragma mark - AppKit SPI (how the UI/document layer drives it)

/// Thin AppKit shim around SNSmartNameSuggestionsClient. The completion block receives an
/// NSDictionary keyed by the NSSmartNamingSuggestions*Key constants above (response array + error).
API_AVAILABLE(macos(27.0))
@interface NSSmartNamingSuggestionWrapper : NSObject
+ (void)requestSmartNameSuggestionsForURL:(NSURL *)url
                     destinationDirectory:(nullable NSURL *)destinationDirectory
                        completionHandler:(void (^)(NSDictionary *response))completionHandler;
                                                    // v40@0:8@16@24@?32  (block sig not embedded; type inferred)
@end

/// Owns the request lifecycle for a save panel / titlebar popover and refreshes the suggestion UI.
/// Plugs into the standard text-suggestions delegate machinery (NSTextSuggestionsDelegate).
API_AVAILABLE(macos(27.0))
@interface NSSmartNamingSuggestionController : NSObject <NSTextSuggestionsDelegate>
@property (nonatomic, weak) id refreshTarget;              // target/action invoked when names update
@property (nonatomic) SEL refreshAction;
@property (nonatomic, copy) NSURL *currentURL;            // the document being named
@property (nonatomic, copy) NSURL *destinationDirectory;  // where it will be saved (sibling context)
- (void)requestSmartNameSuggestionsWithCompletionHandler:(void (^)(NSArray<NSString *> *suggestions,
                                                                   NSError *_Nullable error))completionHandler;
                                                    // v24@0:8@?<v@?@"NSArray"@"NSError">16
- (void)updateSuggestedNames;
@end

/// NSDocument hooks. `smartNamingURL` is the URL used to derive a name; when AppKit applies a
/// suggested name it sets the private `_docFlags.displayNameIsSmartNamingSuggestion` bit.
API_AVAILABLE(macos(27.0))
@interface NSDocument (SmartNaming)
- (nullable NSURL *)smartNamingURL;                        // @16@0:8
- (id)_ensureSmartNamingViewController;                    // returns an NSTitlebarPopoverViewController
// ivars (for reference): NSTitlebarPopoverViewController *_smartNamingViewController;
//                        NSString *_smartNamingBaseSuggestedName;
//                        _docFlags bit: displayNameIsSmartNamingSuggestion
@end

/// The out-of-process Save panel host wiring.
API_AVAILABLE(macos(27.0))
@interface NSRemoteSavePanel (SmartNaming)
@property (nonatomic, strong) NSSmartNamingSuggestionController *smartNamingSuggestionsController;
- (void)_configureSmartNamingSuggestionsController;
- (void)_updateSmartNamingURL;
@end

NS_ASSUME_NONNULL_END

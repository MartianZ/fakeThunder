`SFBCrashReporter` is a framework for submitting application crash logs to an HTTP server.

Adding `SFBCrashReporter` support to your application is easy:

1.  Add the URL for crash log submission as `SFBCrashReporterCrashSubmissionURL` to your application's `Info.plist`

2.  Add the following code to your application's delegate:

```objective-c
# import <SFBCrashReporter/SFBCrashReporter.h>

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Check for and send crash reports
  [SFBCrashReporter checkForNewCrashes];
}
```

Adding support to your HTTP server to receive the crash logs is also easy.  `SFBCrashReporter` comes with a PHP script that will e-mail the submitted crash logs to a specified email account.

0.  Install PHP!

1.  Modify <tt>handle_crash_report.php</tt> as appropriate.

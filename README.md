# GetSocial Flutter SDK

## Overview

GetSocial is a social engagement and referral marketing platform for mobile apps to increase user engagement, retention, acquisition and monetization.
Key benefits of the technology include:
- Referral marketing and content sharing solution to drive organic growth
- Community engagement solution to enable user-to-user and developer-to-user interaction
- Mobile marketing automation to create automated marketing flows that engage, re-engage and retain users
- User segmentation and targeting with push notifications
- Social graph and friend recommendation to connect users with their invited friends, and other users
- Deeplinks for emails, social media, influencer, and other marketing promotions to measuring the performance of your marketing campaigns
- Convert mobile and desktop web visitors to high-value app installs.

## System Requirements

To use GetSocial SDK your execution and development environment should match the following requirements:

### Android

* Android v4.0.3 (SDK v15) or higher
* Android Developers Tools (ADT) version 19 or above
* Google Play Services library v6.1.11 or above (for push notifications)

### iOS

- Xcode 10.2 or above
- iOS 8 or higher

Not sure if GetSocial is going to work in your specific configuration? Feel free to reach us via <a href="#" onclick="openIntercom('Could you please help me with the Android integration?')">Intercom</a> or [email](mailto:support@getsocial.im).

## Adding GetSocial to Your App

### Create App on the Dashboard

To start using GetSocial, you have to [create a free account](https://dashboard.getsocial.im/#/register) and login to GetSocial Dashboard. Dashboard provides a web interface to manage all GetSocial services.

1. Login to [GetSocial Dashboard](https://dashboard.getsocial.im/).
1. Open **Add new app** wizard.
1. Fill in **App name** and upload **App icon image**.
1. Select React Native platform and **Finish** the wizard. 

Learn more about the products we build at [getsocial.im](https://www.getsocial.im).

### Install Flutter package

1. Add `getsocial_flutter_sdk` package to your app's `pubspec.yaml`.
1. Execute `flutter pub get`

### Enable Supported App Stores on the Dashboard

Next step is to enable Google Play and Apple App Store on the [GetSocial Dashboard](https://dashboard.getsocial.im): 

1. On the **App settings** section --> **App information** tab.  
1. Enable **Google Play** store --> fill in **Package name** and **Signing-certificate fingerprint** fields.

    **Package name** is the `applicationId` in your app-level `build.gradle` file.

    **Signing-certificate fingerprint** is a list of SHA-256 hashes of the certificates you use to sign your application. You have to add fingerprints of all keys you use to sign app. GetSocial Gradle plugin adds a helper task `printSigningCertificateSHA256` to print SHA-256 fingerprints for all configured build flavors:

    ```sh
    gradle printSigningCertificateSHA256
    ```

    !!! tip "Using Google Play App Signing?"
        If you are using [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/7384423) you can copy SHA256 from the Play Console. If you're using a separate **Upload certificate**, please add his SHA256 to GetSocial Dashboard as well. Learn more in the [detailed guide](https://docs.getsocial.im/knowledge-base/android-signing-key-sha256/). 

1. Enable **Apple App Store** --> fill in **Bundle ID**, **Team ID** and optionally **App Store ID** fields:

    **Bundle ID** is a part of the iOS App ID. You can find bundle identifier in the Xcode project --> General Settings --> Identity --> Bundle Identifier.

    **Team ID** is a unique 10-character string generated by Apple that’s assigned to your team. You can find your Team ID using your [Apple developer account](https://developer.apple.com/account) --> Membership.

    **App Store ID** number can be found in the iTunes store URL as the string of numbers directly after `id`. For Example, in `https://itunes.apple.com/us/app/yourapp/id284709449` the ID is: `284709449`.

### Configure GetSocial SDK

#### Android

To start using GetSocial, you have to add and configure [GetSocial Gradle Plugin](https://plugins.gradle.org/plugin/im.getsocial) to your Android project. Plugin adds all GetSocial dependencies to the project and configures `AndroidManifest.xml`.

To add GetSocial Gradle plugin: 

1. Add repository and classpath dependency for the plugin in your top-level `build.gradle`. This file is for the entire project so it will be used for global project configurations:

    ```groovy hl_lines="5 10"
    buildscript {
        repositories {
            ...
            maven {
                url "https://plugins.gradle.org/m2/"
            }
        }
        dependencies {
            ...
            classpath "im.getsocial:plugin-v7:[1,2)"
        }
    }
    ```

1. In the Android application project `build.gradle` (this file is the module build file, so it will be used for specific module level configs) apply `im.getsocial` plugin after `com.android.application` plugin:

    ```groovy hl_lines="2 5"
    apply plugin: 'com.android.application'
    apply plugin: 'im.getsocial' // should be applied after com.android.application plugin
    ```

1. In the same `build.gradle` configure GetSocial plugin with GetSocial App id: 

    ```groovy 
    getsocial {
        appId "put-your-getsocial-app-id-here"
        ...
    }
    ```

Check the [GetSocial Gradle plugin reference](https://docs.getsocial.im/knowledge-base/gradle-plugin-reference/) for the full list of available configurations.

#### iOS

To start using GetSocial, you have to add and configure [GetSocial installer script](https://docs.getsocial.im/knowledge-base/ios-installer-reference/) to your Xcode project. The script adds GetSocial frameworks to the project and configures app entitlements, plist files, and Xcode project settings.

To add GetSocial installer script:

1. In your Xcode project go to **Project Settings** --> select target you want to modify --> **Build Phases** tab.
1. Create new **Run Script** phase with the content:

    ```sh
    "$PROJECT_DIR/getsocial-sdk7.sh" --app-id="your-getsocial-app-id"
    ```

1. Move **Run Script** phase before the **Compile Sources** phase.
1. Build your project.

!!! tip "Project Backups"
    GetSocial installer script creates a backup of your `project.pbxproj` file every time it is executed. If something goes wrong, you can always roll back to the previous version.

!!! tip "Source Control Configuration"
    We suggest adding `.backup` files under `.xcodeproj` to ignore list to keep your version control history clean.


## Start Using GetSocial

### SDK Initialization

GetSocial SDK is auto-initialized, just provide a GetSocial App Id in the Gradle plugin on Android, or as a parameter to the iOS Installer Script on iOS, and we will do the magic.

If you want to be notified about initialization complete, you can register a listener, which will be invoked when SDK gets initialized or invoked immediately if it is already initialized:

```flutter
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
...
GetSocial.addOnInitializedListener(() => {
    // GetSocial SDK is ready to use
});
```

### Send your first invite

```flutter 
import 'package:getsocial_flutter_sdk/getsocial_flutter_sdk.dart';
...

Invites.send(nil, onChannel: InviteChannelIds.email, success: {
    print('Invitation via email was sent')
}, cancel: {
    print('Invitation via email was cancelled')
}, failure: { error in
    print('Failed to send invitation via email failed, error: \(error)')
})
```

After calling this method email client will be opened:

!!! note "Note about Simulator"
    Try this example on the device. On the simulator `failure` block will be invoked, as the email client is not configured.


## Demo Application

To showcase all GetSocial Flutter SDK features, we have created a simple demo application, it is available in the `example` folder of the Flutter package.

## Next Steps

Well-done! GetSocial SDK is now set up and ready to rock, check what you can do next:

* Set up deep linking and drive users from web to your mobile app with [Smart Links](https://docs.getsocial.im/guides/smart-links/introduction/), [Smart Widget](https://docs.getsocial.im/guides/smart-widget/) and [Smart Banners](https://docs.getsocial.im/guides/smart-banners/).
* Implement referral campaigns or content sharing with [Smart Invites](https://docs.getsocial.im/guides/smart-invites/introduction/).

OpenTok iOS SDK Samples
=======================

This repository is meant to provide some examples for you to better understand
the new features presented in the OpenTok iOS SDK. The applications herein are
meant to be used with version 2.2.0 and higher of the OpenTok iOS SDK. Feel free
to copy and modify the source code herein for your own projects.
If you are able, please consider sharing with us your modifications, especially
if they might benefit other developers using the OpenTok SDK. See the
[License](LICENSE) for more information.

What's Inside
-------------

There are three projects that each build on the lessons of the previous. By the
end of a code review of all, you will have an understanding of the new video
capture and render API. Additionally, you will be able to get started with
writing your own extensions to the default capture implementations provided 
herein.

1.	**Hello World** - This basic application demonstrates a short path to 
	getting started with the OpenTok iOS SDK.

2.	**Let's Build OTPublisher** - This project provides classes that implement
	the OTVideoCapture and OTVideoRender interfaces of the core Publisher and
	Subscriber classes. Using these modules, we can see the basic workflow of
	sourcing video frames from the device camera in and out of OpenTok, via the
	OTPublisherKit and OTSubscriberKit interfaces.

3.	**Live Photo Capture** - This project extends the video capture module 
	implemented in project 2, and demonstrates how the AVFoundation media 
	capture APIs can be used to simultaneously stream video and capture 
	high-resolution photos from the same camera.

4.	**Overlay Graphics** - This project shows how to overlay graphics on 
	publisher and subscriber views and uses SVG graphic format for icons.
	This project barrows publisher and subscribers modules implemented in 
	project 2.
	
5.	**Multi Party Call** - This project demonstrate how to use OpenTok SDK for 
	a multi party call. The application publish audio/video from iOS device and
	can connect to N number of subscribers. However it shows only one
    subscriber video at a time due to cpu limitations on iOS devices. 


Referencing OpenTok.framework
-----------------------------

Each project includes a symlink to `OpenTok.framework`, up one directory level
from the root of this repository. If you are reading this from a distribution
tarball of the OpenTok iOS SDK, then these links should work fine. If you have
[cloned][opentok-ios-samples] this repository
directly, you will have to update the links to point to your copy of
`OpenTok.framework`.


Getting Sample Code Updates
===========================

This README, and the sample applications herein, are maintained separately from
releases of the [OpenTok iOS SDK][opentok-ios-sdk]. A snapshot of this 
repository is included in the distribution of the SDK. To get the latest
updates to these example applications and accompanying documentation, be sure
to clone the sample repository itself:
https://github.com/opentok/opentok-ios-sdk-samples/



[opentok-ios-samples]: https://github.com/opentok/opentok-ios-sdk-samples/
[opentok-ios-sdk]: http://tokbox.com/opentok/libraries/client/ios 
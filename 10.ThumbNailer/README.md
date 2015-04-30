ThumbNailer
===========

This example demonstrates how you might go about sending periodic thumbnails
of a publisher to all connections using out of band signaling. This might be
useful in case you want to preview a stream's view without actually connecting.

In this app, we use OpenTok signaling to distribute thumbnails, but a higher
capacity out of band signaling could be used to achieve higher fidelity in the
quality of the image transmitted.


App Notes
=========

I learned a few things about the image APIs in iOS while trying to make this
work.

* UIImage is a wrapper for CIImage and CGImage, both of which have interesting
  interfaces for manipulation, but do not provide equal functionality. There are
  more functions in the TBThumbnailGenerator class for different uses, but what
  is compiled is just what I found works well for the iPhone renderer.
  
* Similarly, the default UIView for the OTPublisher preview renderer does not 
  support draw instructions from Core Animation. The result of this is that we
  have to bind to the publisher renderer itself to grab snapshots, rather than
  use CALayer's `renderInContext:`. Given the size and infrequency of the
  data set, I don't suspect there are significant implications, even though this
  is probably not the best implementation.
  
* `OTSession.signal` limits payload size to 8KiB. Be careful turning up the
  resolution and compression quality too much that the signal will be rejected.
  
* The thumbnail is placed on the view hierarchy in the same place a subscriber
  is going to go. For best results, just test on one device to see the thing
  in action.

* The interesting functions for this feature are in ViewController.m, functions
  `broadcastThumbnail` and
  `session:receivedSignalType:fromConnection:withString:`.

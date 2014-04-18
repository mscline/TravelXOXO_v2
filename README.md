

TravelXOXO Version 2.0

I wanted to rewrite TravelXOXO using a more object oriented / design pattern approach.  First and foremost, the recursive timing sequences are hard to work with and result in unnecessary confusion.  So, I replaced them with a queue of timed invocations.  Secondly, I wanted to break some of the components out of the main view controller, partially to make it cleaner and partially to facilitate reuse.  Finally, the map kit leaves a great deal to be desired, most notably, the line width of polyline overlays is often distorted when zooming, which takes a lot away from the user experience.  

Unfortunately, there is no easy way to address this problem without writing a custom overlay, which has to scale with the MapView.  It is very messy and being a "fun project," I have decided to hold off, at least for the time being.  (In addition, Apple will address many of the bugs in MapKit in iOS 8, coming soon.)  As a result, this project is at somewhat of an intermediate state; and if you want a fully functional version, stick with Version 1.0. 
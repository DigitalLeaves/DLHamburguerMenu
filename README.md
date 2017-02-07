# DLHamburguerMenu

DLHamburguerMenu is a "hamburguer" sidebar menu control written entirely in swift. It presents a menu over the current visual contents (i.e: Above the current UINavigationController). It's easy to integrate using storyboards.

Works for iOS 7+

![](http://digitalleaves.com/wp-content/uploads/2015/03/hamburguerMenu.gif)

## Structure

The menu works by setting a main container view controller, called the "Root" view, and then inserting two view controllers, the menu view controller and the content view controller. The first will contain the sidebar menu, and the second will be the main content of the App, presumably a UINavigationController subclass.

For convinience, a UINavigationController subclass called DLHamburguerNavigationController is included. Thus, you only need to set up three view controllers in a storyboard:

* A RootViewController, subclass of DLHamburguerViewController.
* A view controller that acts as a menu.
* A view controller that acts as the main content, possibly embeded in a DLHamburguerNavigationController.
* Whatever other view controllers that are accesed by means of a segue from the content view controller.

![](http://digitalleaves.com/wp-content/uploads/2015/03/Captura-de-pantalla-2015-03-09-a-las-10.27.08.png)

## Use & Integration.

Drag & drop the files DLHamburguerContainerViewController.swift, DLHamburguerNavigationController.swift	and DLHamburguerViewController.swift to your project. Set a Storyboard with at least three view controllers, the root view controller, subclass of DLHamburguerViewController, a view controller to act as content view controller, embedded in a DLHamburguerNavigationController, and a menu view controller. 

Those three view controllers don't need to be linked by any segue. Also, add as many segues to the content view controller as you wish.

Then, in your root view controller, instanciate the content and menu view controller in awakeFromNib():

```
override func awakeFromNib() {
  self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DLDemoNavigationViewController") as UIViewController
  self.menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DLDemoMenuViewController") as UIViewController
}
```

## Choosing an option from the menu

To properly segue from the content view controller, in your menu, once you have presented (by pushing or showing) another view controller, you should update the content view controller. In the case of a navigation controller, simply assign it as the new content controller once you push the view:

```
func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  let nvc = self.mainNavigationController()
    if let hamburguerViewController = self.findHamburguerViewController() {
      hamburguerViewController.hideMenuViewControllerWithCompletion({ () -> Void in
        nvc.visibleViewController.performSegueWithIdentifier(self.segues[indexPath.row], sender: nil)
          hamburguerViewController.contentViewController = nvc
      })
    }
}
```
    
The function findHamburguerViewController() can be used to retrieve the current hamburguer view controller, so you can access its content and menu view controllers.

## Rotations and Transitions

The hamburguer menu is compatible with iOS 7 rotation and iOS 8 transitions.

## Credits and Acknowledgements

Developed by Ignacio Nieto Carvajal, inspired by REFrostedViewController by Roman Efimov (https://github.com/romaonthego/REFrostedViewController).

## License

The MIT License (MIT)

Copyright (c) 2015 Ignacio Nieto Carvajal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

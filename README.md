# The LinkToId Chrome extension

This is an extension for the Chrome web browser that allows you to easily identify
and navigate to linkable elements on a web page. A linkable element is any element
with a non-empty ID attribute.

## What for?

Not too seldom, I find that I want to link to a specific part of a web page. In 
the old days, I would go hunting in the web page source for a named anchor, and
manually construct the URL. Recently, I learned that any element with a non-empty
ID can be linked to. I decided to make a Chrome extension to make the linking 
process more convenient, and to learn how to write an extension. :-)

## How does it work?

When the trigger keys are pressed, a tooltip will show information about the
current linkable element, which may be an ancestor of the element under the mouse
if that element does not have a non-empty ID.

The trigger keys are Ctrl + Alt. This is currently hard-coded in the extension.

## Installing

The extension is available in the Chrome Web Store:

https://chrome.google.com/webstore/detail/linktoid/cggiopngamlojpeoliehhppmdphinjen

## License

The code is released under the MIT license. See http://per.mit-license.org/2012 for
further details, or the LICENSE file.

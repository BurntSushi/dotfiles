Description
===========
dzen-workspaces listens to events from Wingo and emits a dzen formatted string 
whenever there is a change. The formatting is configurable and is based on the 
kind of workspace: current, visible, hidden or empty.


Example
=======
In your `Autostart` hook:

    startup := Shell "dzen2 -dock | ~/.config/wingo/scripts/dzen-workspaces/dzen-workspaces"

The formatting options can be changed in

    ~/.config/wingo/scripts/dzen-workspaces/dzen-workspaces.cfg


Dependencies
============
* pywingo
* dzen2


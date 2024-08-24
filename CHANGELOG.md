## V1.11g - 22 August 2024
- ColorPicker pane now has a button for toggling all swatch locks on/off
	- Default button once again no longer removes locks
- [Bug] Selecting an item in outfit manager now properly selects it, so it shows up as selected when visiting the pane
- [Code] Rewrote some customization related code to be much more straightforward, cleaner, and standardized


## V1.11f - 11 August 2024
- Grid buttons now properly center in empty area on all panes with custom buttons on right side of infobar
- Folder button in color finder moved onto infobar
- [Code] `ShopTabList` and (some) `PushButton` polish


## V1.11e - 3 August 2024
- Added default vanilla versions of items, as well as the Transformice map mode versions
- Imgur feature overhaul
	- Now works in air app (only worked on browser before)
	- Moved button from being on main toolbar to being on the share screen
	- Instead of forcing the user to open the link for the uploaded file, the imgur link now appears in a "copy" input
- (8 Aug) Added a new "Hardcoded image save size" setting on About screen that lets users save an image at a consistent placement and scale 
- [Code] Some small `I18n` and `fewfre` lib tweaks
- [Code] `WorldPaneManager` added, and some tweaks to logic in `World`
- [Code] Rewrote MovieClip color update logic for when using color picker


## V1.11d - 31 July 2024
- [Code] Color picker logic polished
- [Code] `RoundedRectangle` rewritten + renamed to `RoundRectangle` and moved to `com.fewfre.display`


## V1.11c - 28 July 2024
- Redesign for "copy share code" text fields / copy button to make it feel more polished
- [Code] Some code tweaks, including polish for popup screens


## V1.11b - 27 June 2024
- [Code] Rewrote grid button logic such that only 1 grid is needed for additional buttons in same cell (such as delete button)
- [Code] Color Finder cropping code made a tiny bit clearer
- Added ability to favorite items and have them appear above the items grid
- [Misc] (6 Jul) Converted changelog into markdown
- [Misc] (7 Jul) Added some analytics (via tracking pixel) for user language + whether using app or browser


## V1.11 - 19 June 2024
- Added badges as a new "item" type.
- Color locks are now remembered on a per-item basis until you close the app or hit "Defaults" button on color picker
- [Code] App can now load PNGs
- Replaced bottom left github button/version text with a new button to a new "About" screen (where aforementioned content has been moved)
	- Added a discord link button on new About screen
- [Code] Cleaned up `Toolbox` and made it `Event` driven
- Mouse & color finder drag code tweaked
	- Letting go of mouse outside of drag area no longer keeps it in drag mode
	- The spot you grabbed can no longer leave the "safe area" / drag zone
	- Changing the scale when the center of the mouse / item is outside the safe zone will clamp the center into the safe area to prevent it being scaled down to where it can no longer be clicked
- [Code] Rewrote the `TabPane` (now `SidePane`) and scrollbox logic
- [Bug] Fixed lag caused by a recent update
- Optimized Outfit Manager pane so list isn't fully re-rendered on outfit adding, deleting, or list reversing.
- [Code] `ShopInfobar` rewrite (and renamed to `Infobar`)
	- Moved grid management logic to it's own component
	- Grid management button groups can now be hidden individually, instead of all or nothing
	- Hovering over item preview on infobar now properly shows a pointer cursor (to make it more obvious it's clickable)
- Updated back button arrow to have a larger hit area
- [Code] Rewrote `RoundedRectangle` to have width/height as normal params
- [Code] Renamed `TextBase` to `TextTranslated`, and then a new `TextBase` made (which `TextTranslated` inherits from)
- [Bug] Fixed outfit manager delete button bug


## V1.10e - 24 March 2024
- Selecting something in outfit manager no longer forces you to go to that item's category pane
	- Added a new small button that can do the old behavior
- Selecting an already "selected" shop tab when a different pane is open (ie outfit manager, color picker, etc) now properly switches to it.


## V1.10d - 6 December 2023
- Fixed bug causing color history to stay in delete mode when it shouldn't


## V.10c - 9 October 2023
- Changed default color detect to account for weird color values


## V1.10b - 30 June 2023
- share code now scrolls item into view
- Allow traversing color swatches using up/down arrow keys


## V1.10 - 1 May 2023
- [Bug] Clicking scale slider will no longer prevent left/right arrow keys from traversing item grid
- Scale slider code polished - track hitbox increased & clicking anywhere on track now starts drag
- Share code support added
- "Outfit" manager for saving shaman items like in the tfm dressroom


## V1.9 - 25 February 2023
- Each category now has newest item selected by default
- Items can no longer be unselected; there will always be something selected in a given category
- Ported over TFM dressroom changes:
	- TabPane infobar redesigned
	- Added left/right arrows to infobar that do same as keyboard arrow keys (mobile support)
	- Using arrows / randomize button to select an item off-screen will now scroll the button into view
	- Copy button added to toolbox (app only, due to AIR requirements)
	- Resource update system redone to be more user friendly - it is now run from `/resources/update/` instead of `/resources/update.php`
	- Fixed color swatches not formatting number with 0s
		- Reworked color picker code a bit to finally fix this issue
			- Moved `ColorSwatch` and `ColorPickerTab` into the same folder
			- Moved color history into it's own component
	- The black handle above color picker updated to be white to be more visible
	- Up/Down arrow keys now traverse the grids vertically
	- Some code cleanup / rework
		- Moved shop item pane code from `World` into `ShopCategoryPane`
		- `ITEM` renamed to `ItemType` and given proper enum typing
		- `ImgurApi` moved to `com.fewfre.utils`
		- `Grid` revamped and moved to `com.fewfre.display`
		- Some components in `ui` moved to new `ui.common` folder
		- Small `RoundedRectangle` revamp
		- Multiple `_drawLine` function replaced with new `GameAssets.createHorizontalRule()`
		- Updated/polished `GameAssets` color functions to be less awful
		- `PNGEncoder` updated to match source
		- `com.piterwilson` lib source polished + moved `com.paulcoyle`'s `AngularColour` into it


## V1.8b - 17 February 2023
- One item in each category may now be selected
	- changing back to a tab pane with a selected item will now change active item back to it
- Item selected by default on launch is now newest small box, not oldest


## V1.8 - 24 January 2023
- Removed duplicate balloon (hardcoded)
- Added ability to traverse through item buttons using left/right arrow key (suggestion by Barberserk)


## V1.7b - 19 October 2022
- Hovering over color swatch square on color picker will temporarily invert the corresponding color on the target item until hovering is stopped
- Tweaked top bar on shop tab panes to have a larger item preview size


## V1.7 - 6 October 2022
- Added randomize color button to item color picker page
- Undo button added on color picker - clicking it will show colors previously used on the specific color swatch for that specific item.
- Updated color buttons to look nicer
- Recent colors list design reworked and moved to it's own class
- Recent colors now also shown on color finder
- Color finder now supports scaling image & dragging it around
- Files can now be uploaded from the user's computer into the color finder (request by Milinili)
- Manually selecting a language will now cause the app to remember it the next time it is opened (request by Zelenpixel#9767)
- Items now listed in reverse order by default, and a button has been added to reverse the order of the list
- Back button added when in downloadable app
- Recent colors now remembered across dressrooms in the app
- Increased max costumes to check constant + made the checking more efficient

## V1.6 - 6 May 2022
- Android support
- Color picker now has show a recent list of colors along the bottom

## V1.5 - 23 February 2021
- Shaman orbs added


## V1.4 - 2 January 2020
- Added support for being externally loaded by AIR app


## V1.3 - 9 June 2018
- Code cleanup / validation for "strict" compilation
- Small changes to code strucutre (including old file removal)
- Re-added infobar download button (for consitent name/scale for wiki)


## V1.2 - 16 December 2017
- Increased color swatches to 10 so there are enough for all items.
- Item resource swfs now loaded based on config.json
- Renamed "Costumes" to "GameAssets" and changed it from a singleton to a static class.


## V1.1 - 6 September 2017
- Adding various languages
- Moved over TFM Dressroom rework:
	- V1.5
		- Added app info on bottom left
			- Moved github button from Toolbox
			- Now display app's version (using a new "version" i18n string)
			- Now display translator's name (if app not using "en" and not blank) (using a new "translated_by" i18n string)
		- Bug: ConstantsApp.VERSION is now stored as a string.
		- Download button on Toolbox is now bigger (to show importance)
		- ShopInfoBar buttons tweaked
			- Refresh button is now smaller and to the right of download button
			- Added a "lock" button to prevent randomizing a specific category (inspired by micetigri Nekodancer generator)
			- If a button doesn't exist, there is no longer a blank space on the right.
			- Download button is now smaller (so as to not be bigger than main download button).
		- AssetManager now stores the loaded ApplicationDomains instead of the returned content as a movieclip
		- AssetManager now loads data into currentDomain if "useCurrentDomain" is used for that swf
		- Moved UI assets into a separate swf
		- Fewf class now keeps track of Stage, and has a MovieClip called "dispatcher" for global events.
		- I18n & TextBase updated to allow for changing language during runtime.
		- You can now change language during run-time
	- V1.6
		- Color finder feature added for items.
		- [bug] If you selected an item + colored it, selected something else, and then selected it again, the infobar image showed the default image.
		- [bug] Downloading a colored image (vs whole mouse) didn't save it colored.
	- V1.7
		- Imgur upload option added.
		- Resources are no longer cached.

## V1.0 - 4 July 2017
- Initial (rough) Commit - fully functional

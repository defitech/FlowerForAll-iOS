HOW TO WRITE A GAME
===================
  

- VolcanoApp is you friend if you're looking for an example
- ExampleApp shows a skeleton of what you should get at the end of this tutorial

- Choose a name for your game, let's say "FunGame"

# YOU MUST 
- All your files must be stored in their own "FunGame" subdirectory

- As the iApp packages are "flat" (no subdirs) it's difficult to deal with files having identical names. This is why every single file of your package must start with 
the App name.   
for example you will rename Icon.png MyClass.h and ressource.data to:
FunGame-Icon.png FunGame-MyClass.h and FunGame-ressources.data

- All strings must be ready to be translated using the method 
 `NSLocalizedStringFromTable(XXX,@"FunGame",XXXX);`
to be sure we will find the string to translate at the right place.

# CREATE THE SUBDIR ENVIRONNEMENT 
- in the Apps directory create a sub directory called "FunGame" 
respect the case of the name you choose. Do this from the Finder or Terminal,
NOT from Xcode.
- create the subdir en.lproj to hold your localized elements in english 
- add an empty string files to hod your localized Strings with the name: "FunGame.strings"

In a terminal that would do:

	$ cd FlowerForAll/Apps/
	$ mkdir FunGame
	$ mkdir FunGame/en.lproj
	$ touch FunGame/en.lproj/FunGame.strings


# MAP THE CREATED SUBDIR WITH XCODE 
In Xcode, on the FlowerForAll project

- right-click on the "Apps" group Folder and select "New Group"
- rename the newly created group to "FunGame"
 
**you need to have the "utilities view open" (right layer) 
    and show the "File inspector"**
- Select the "FunGame" icone, and in the File inspector, 
  just below the "Path" that must be set to "Relative to Group"
  change the "None" to your "FunGame" directory
      (your "FunGame" group is now mapped to your directory)

* add the localized strings file
   right click on your "FunGame" group icon and choose "Add Files to FlowerForAll"
   select the file FunGame.strings in the "en.lproj" directory
The following command from the FunGame/ source directory will do the job for you
`$ genstrings *.m -o en.lproj` 

- you can create "FunGame.strings" for other languages and add them the same way.
  (for french it would be the file FunGame/fr.lproj/FunGame.strings)


# CREATE YOU GAME CONTROLLER 
* You must Subclass "FlowerApp"
* Right click on you "FunGame" group icon and choose "New File" 
    - CocoaTouch -> UIViewController subclass"
    - in the subclass entry field choose "FlowerApp"
              check the "with XIB for user interface"
    - in the Save As entry field choose "FunGame"
       be sure "Where" and "Group"  are set to "FunGame"

# OVERRIDING FLOWER APP 
in Classes/AppsMenu/

* look at FlowerApp header and implementation to get an idea of what it does

You must override at least 

	/** Used to put in as label on the App Menu (Localized)**/
	+(NSString*)appTitle ;

The following code will do the trick 

	/** Used to put in as label on the App Menu (Localized)**/
	+(NSString*)appTitle {
	    return NSLocalizedStringFromTable(@"My Fun Game",@"FunGame",@"App Title");
	}

The following command from the FunGame/ source directory will complete your english dictonary file

`$ genstrings *.m -o en.lproj`


* If you don't want to provide an FunGame-Icon.png file then you must override
`+(UIImage*)appIcon;`

* If you don't want to use XIB user interface override 
`+(FlowerApp*)autoInit;`

* To catch events from the Application and from FLAPIX (the library that does the sound processing)
you just have to override any of the flapixEventXXXXX method you need.


# SHOWING A START / STOP BUTTON 
* look at VolcanoApp refreshStartButton method if you want to add your own control method


# INSTALLING YOUR APP ON THE MENU
* Add a FunGame-Icon.png file to your App directory or implement +(UIImage*)appIcon

* We will soon automate this part, but for now, you have to manually add your app
to FlowerController-viewDidLoad appList
then add your Icon and Title to MenuView.xib and The IBAction to open your app in MenuView.m

* If you start developping your own app, just let us know, we will work on this with you




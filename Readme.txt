Development Enviroment:
=======================

Embarcadero Delphi XE4:
http://www.embarcadero.com/products/delphi/


Used packages:
==============

Active Query Builder VCL Edition:
http://www.activequerybuilder.com/

Axialis Pure Flat 2013 Toolbar Icons:
http://www.axialis.com/stock-icons/pure-flat-2013-toolbar.html

FastMM:
https://github.com/pleriche/FastMM4/

Synopse PDF:
https://github.com/synopse/SynPDF/

SynEdit:
https://github.com/SynEdit/SynEdit/

BCHexEditor:
https://github.com/bonecode/BCHexEditor/


Tools to build the setup program:
=================================

EurekaLog:
http://www.eurekalog.com/

Gawk for Windows:
http://gnuwin32.sourceforge.net/packages/gawk.htm

Help & Manual:
http://www.ec-software.com/

HTML Help Workshop:
http://go.microsoft.com/fwlink/?LinkId=14188

Inno Setup:
http://www.jrsoftware.org/isinfo.php


Placing the packages into the file system:
==========================================

Cleanup.bat will create the empty folders for the used packages.

Please download the packages from the given URLs and copy the sources /
resources into the related folders below the source folder: The .dpr and .pas
files into the "Source" folders, .res and .dfm files into the "Resource"
folders.

To get detailed memory leak information while debugging, please store the
FastMM_FullDebugMode.dll file into the "FastMM" folder directly. After this
please call Cleanup.bat again to copy it into the Temp folder.



Developing the program:
=======================

Inside Delphi first of all, you have to built all packages inside Delphi
(Menu: Project -> Build All Project).

All Designtime packages needs to be installed. This will be done inside the
IDE with the project manager (Menu: View -> Project Manager). For each
package, you have to make a right click -> Install.

Now, please close Delphi again and call Build_Setup.bat. This will build the
.res file for this program. If you did not install all tools for building the
setup program, the Build_Setup.bat will fail - but this is not a problem,
the .res file was build hopefully.

Now you can start Delphi again and build the program to execute it.


Building the setup program:
===========================

The setup program will be built with the Build_Setup.bat file.

With Cleanup.bat all temporary files can be deleted easily.
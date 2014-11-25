#### Zoë

Zoë is an open source tool for generating spritesheet images and frame data from SWF files.

The source code is licensed under the MIT public license.

If you just want to use Zoë, the latest stable .air installer can be found on the [Zoë](http://createjs.com/zoe) website.

#### Using

[Zoë](http://www.createjs.com/#!/Zoe) is designed to work with any AS3 SWF file version 9 or greater.  It's best practice to have all your animations on the root timeline, and use labels to identify your different animations or frames.  To begin, simply drag a swf file into Zoë, and click Export to create a SpriteSheet.

Zoë and [Easel](http://www.createjs.com/#!/EaselJS) support custom registration points on images. To define one, simply place an empty clip on your timeline labeled registrationPoint.  If needed, you can also define multiple points per file.

#### Building

**Command line (Recommended)**

* Install the latest Flex SDK from Apache (http://flex.apache.org/)
** The latest version is built against Apace Flex 4.13.0
* Make sure java is available on your PATH
* Rename FlexSdkPath.conf.sample to FlexSdkPath.conf and edit the FLEX_SDK variable to point to your Flex SDK
* For OSX run build.sh and for Windows run build.bat
* Note that we don't distribute the default application *.p12 key
** To create your own key for testing visit: http://help.adobe.com/en_US/air/build/WS901d38e593cd1bac1e63e3d128fc240122-7ffc.html

**FlexBuilder**

* You can also build using Flex Builder by checking out the repo a creating a new Flex AIR/MXML project, and use this repo as your project root.

#### Support

You can ask questions and interact with other users at our [Community site](http://community.createjs.com/).

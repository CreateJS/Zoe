#### Zoë

Zoë is an open source tool for generating spritesheet images and frame data from SWF files.

The source code is licensed under the MIT public license.

If you just want to use Zoë, the latest stable .air installer can be found on the [Zoë](http://createjs.com/zoe) website.

#### Using

[Zoë](http://www.createjs.com/#!/Zoe) is designed to work with any AS3 SWF file version 9 or greater.  It's best practice to have all your animations on the root timeline, and use labels to identify your different animations or frames.  To begin, simply drag a swf file into Zoë, and click Export to create a SpriteSheet.

Zoë and [Easel](http://www.createjs.com/#!/EaselJS) support custom registration points on images. To define one, simply place an empty clip on your timeline labeled registrationPoint.  If needed, you can also define multiple points per file.

#### Building

Zoë is typically built using Flash Builder 4.5, and has been compiled against the Adobe Flex SDK 4.6.0 and Adobe AIR 3.x.  To build a copy your self, or to just test changes locally.  Create a new Flex AIR Project, and point to the Zoe root folder, and test.

#### Support

You can ask questions and interact with other users at our [Community site](http://community.createjs.com/).
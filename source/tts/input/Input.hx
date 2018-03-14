package tts.input;

import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;

class Input extends FlxGroup
{
    public var moving:Bool = false;
    public var movDir:FlxPoint;

    public var aiming:Bool = false;
    public var throwDir:FlxPoint;

    public var buttonThrow:Bool = false;
    public var buttonMakeSnowball:Bool = false;
    public var buttonTakePresent:Bool = false;

    public var start:Bool = false;
    public var back:Bool = false;

    public var pad:FlxGamepad;

    private function new() 
    {
        super();
    }

    public function getThrowDir(point:FlxPoint):FlxPoint 
    {
        return null;
    }
}
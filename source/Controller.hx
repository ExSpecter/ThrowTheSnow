package;

import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;

class Controller extends FlxGroup
{
    public var pad:FlxGamepad;

    public function new(?PAD:FlxGamepad) 
    {
        pad = PAD;
        pad.deadZone = 0.3;

        movDir = new FlxPoint(0, 0);
        throwDir = new FlxPoint(0, 0);
        super();
    }

    public var moving:Bool = false;
    public var movDir:FlxPoint;

    public var aiming:Bool = false;
    public var throwDir:FlxPoint;

    public var rightTrigger:Bool = false;
    public var buttonA:Bool = false;
    public var buttonX:Bool = false;

    override public function update(elapsed:Float):Void
    {
        moving = aiming = false;
        rightTrigger = buttonA = buttonX = false;

        movDir.set(0, 0);
        throwDir.set(0, 0);


        movDir.x = pad.analog.value.LEFT_STICK_X;
        movDir.y = pad.analog.value.LEFT_STICK_Y;
        if(movDir.x != 0 || movDir.y != 0) {
            moving = true;
        }

        throwDir.x = pad.analog.value.RIGHT_STICK_X;
        throwDir.y = pad.analog.value.RIGHT_STICK_Y;
        if(throwDir.x != 0 || throwDir.y != 0) {
            aiming = true;
        }

        if(pad.justPressed.RIGHT_SHOULDER) rightTrigger = true;
        if(pad.justPressed.A) buttonA = true;
        if(pad.justPressed.X) buttonX = true;
    }

    public static function setAllControllerExisting():Void
    {

    }
}
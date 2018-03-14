package tts.input;

import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;

class Controller extends Input
{
    public function new(?PAD:FlxGamepad) 
    {
        pad = PAD;
        pad.deadZone = 0.3;

        movDir = new FlxPoint(0, 0);
        throwDir = new FlxPoint(0, 0);
        super();
    }

    override public function update(elapsed:Float):Void
    {
        moving = aiming = false;
        buttonThrow = buttonMakeSnowball = buttonTakePresent = start = back = false;

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

        if(pad.justPressed.RIGHT_SHOULDER || pad.justPressed.LEFT_SHOULDER) buttonThrow = true;
        if(pad.justPressed.A) buttonMakeSnowball = true;
        if(pad.justPressed.X) buttonTakePresent = true;
        if(pad.justPressed.START) start = true;
        if(pad.justPressed.BACK) back = true;
    }

    override public function getThrowDir(point:FlxPoint):FlxPoint 
    {
        return throwDir;
    }

    public static function setAllControllerExisting():Void
    {

    }
}
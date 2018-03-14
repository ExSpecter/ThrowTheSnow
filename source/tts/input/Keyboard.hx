package tts.input;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;

class Keyboard extends Input
{

    public function new() 
    {
        movDir = new FlxPoint(0, 0);
        throwDir = new FlxPoint(0, 0);
        super();
    }

    override public function update(elapsed:Float):Void
    {
        moving = aiming = false;
        rightTrigger = leftTrigger = buttonA = buttonX = start = back = false;

        movDir.set(0, 0);
        throwDir.set(0, 0);


        if (FlxG.keys.pressed.W) movDir.y--;
        if (FlxG.keys.pressed.S) movDir.y++;
        if (FlxG.keys.pressed.A) movDir.x--;
        if (FlxG.keys.pressed.D) movDir.x++;
        if(movDir.x != 0 || movDir.y != 0) {
            moving = true;
        }

        throwDir = FlxG.mouse.getScreenPosition();
        if(FlxG.mouse.pressed) aiming = true;

        if(FlxG.mouse.justReleased) {
            leftTrigger = rightTrigger = true;
            aiming = true;
        }
        if(FlxG.keys.justPressed.R) buttonA = true;
        if(FlxG.keys.justPressed.E) buttonX = true;

        if(FlxG.keys.justPressed.ENTER) start = true;
        if(FlxG.keys.justPressed.N) back = true;
    }

    override public function getThrowDir(point:FlxPoint):FlxPoint 
    {
        return new FlxPoint(throwDir.x - point.x, throwDir.y - point.y); //throwDir.subtract(point.x, point.y);
    }

    public static function setAllControllerExisting():Void
    {

    }
}
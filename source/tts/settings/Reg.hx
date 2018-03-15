package tts.settings;

import tts.input.*;

class Reg
{
    public static var playerCount:Int = 0;
    public static var c = new Array<Input>();
    public static var pointsT1:Int = 0;
    public static var pointsT2:Int = 0;
    public static var keyboardUsed:Bool = false;

    public static var gameOver:Bool = false;

    public static function init():Void
    {
        Reg.pointsT1 = 0;
        Reg.pointsT1 = 0;
        Reg.playerCount = 0;
        Reg.keyboardUsed = false;
    }

    public static function clearController():Void
    {
        Reg.c = new Array<Input>();
    }
}
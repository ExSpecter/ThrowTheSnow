package tts;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class EndZone extends FlxSprite
{
    public var team:Int;

    public function new(team:Int, ?X:Float=0, ?Y:Float=0)
    {
        super(X, Y);
        this.team = team;

        makeGraphic(32, 32, FlxColor.TRANSPARENT, true);
    }
}
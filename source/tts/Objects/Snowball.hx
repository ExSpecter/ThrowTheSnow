package tts.objects;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;

import tts.settings.*;

class Snowball extends FlxSprite
{
    private var dir:FlxPoint;
    private var speed:Float;
    public var team:Int;

    public function new(team:Int, DIR:FlxPoint, ?X:Float=0, ?Y:Float=0, ?SPEED:Float=PlayerReg.minThrowSpeed)
    {
        super(0, 0);
        this.speed = SPEED;
        this.team = team;
        setSize(12,12);
        offset.set(4,4);
        loadGraphic(AssetPaths.snowball__png, true, 16, 16);
        scale.set(PlayerReg.maxThrowSpeed / speed, PlayerReg.maxThrowSpeed / speed);

        this.setPosition(X - this.width / 2, Y - this.height / 2);
        drag.x = drag.y = 1800;

        this.dir = new FlxPoint(DIR.x, DIR.y);
        dir.scale(speed / getVectorLength(dir));
    }

    private function getVectorLength(vector:FlxPoint):Float
    {
        var length:Float = Math.sqrt(vector.x * vector.x + vector.y * vector.y);
        return length;
    }

    override public function update(elapsed:Float):Void
    {
        velocity.set(dir.x, dir.y);
        super.update(elapsed);
    }
}
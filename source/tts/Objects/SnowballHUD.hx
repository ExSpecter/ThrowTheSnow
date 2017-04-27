package tts.objects;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;

import tts.entities.*;

class SnowballHUD extends FlxSprite
{
    private var player:Entity;

    public function new(player:Entity)
    {
        super(player.x + 5, player.y - 24);
        this.player = player;

        loadGraphic(AssetPaths.snowballHUD__png, true, 24, 8);

        animation.add("1", [0], 1, false);
        animation.add("2", [1], 1, false);
        animation.add("3", [2], 1, false);
    }

    override public function update(elapsed:Float):Void
    {
        setPosition(player.x + 5, player.y - 24);
        if(player.snowBallCount == 0) {
            this.visible = false;
        } else {
            animation.play("" + player.snowBallCount);
            this.visible = true;
        }
        super.update(elapsed);
    }
}
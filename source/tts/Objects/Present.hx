package tts.objects;

import flixel.FlxSprite;

import tts.entities.Entity;

class Present extends FlxSprite
{
    public var player:Entity;

    public function new(?X:Float=0, ?Y:Float=0)
    {
        super(X, Y);

        loadGraphic(AssetPaths.present__png, true, 32, 32);
    }

    override public function update(elapsed:Float):Void
    {
        if(player != null) {
            this.visible = false;
            setPosition(player.x + 1, player.y + 8);
        } else {
            this.visible = true;
        }
        super.update(elapsed);
    }
}
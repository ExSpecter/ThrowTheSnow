package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;

using flixel.util.FlxSpriteUtil;

class ThrowArrow extends FlxSprite
{
    private var controller:Controller;
    private var player:Player;
    private var playerDistance:Float = 14;
    public var throwSpeed:Int = PlayerReg.minThrowSpeed;

    private var angleVector:FlxPoint;

    public function new(controller:Controller, player:Player)
    {
        super(0, 0);
        this.controller = controller;
        this.player = player;
        angleVector = new FlxPoint(0, 0);

        //calcPosition();
        
        makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
        //loadGraphic(AssetPaths.ThrowArrow__png, true, 96, 96);
    }

    private function calcPosition():Void
    {
        this.setPosition(player.x - ((this.width - player.width) / 2), player.y - ((this.height - player.height) / 2));
    }

    override public function update(elapsed:Float):Void
    {
        if(controller.aiming && player.snowBallCount > 0 && !player.makingSnowball && player.freeze < PlayerReg.freezeLimit && !player.hasPresent) {
            this.angleVector.set(controller.throwDir.x, controller.throwDir.y);
            //angle = radToDeg(Math.atan2(angleVector.y, angleVector.x));//angleVector.angleBetween(new FlxPoint(1, 0)) * 2;

            drawThrowLine(angleVector);

            this.visible = true;
            throwSpeed += 5;
            if(throwSpeed >= PlayerReg.maxThrowSpeed) throwSpeed = PlayerReg.maxThrowSpeed;
        } else {
            throwSpeed = PlayerReg.minThrowSpeed;
            this.visible = false;
        }
        //this.calcPosition();
        super.update(elapsed);
    }

    private function drawThrowLine(dir:FlxPoint):Void 
    {
        dir.scale(playerDistance / getVectorLength(dir));
        var startX:Float = player.x + player.width / 2 + (dir.x);
        var startY:Float = player.y + player.height / 2 + (dir.y);
        dir.scale((throwSpeed / PlayerReg.maxThrowSpeed) * 40 / getVectorLength(dir));
        var endX:Float = startX + dir.x;
        var endY:Float = startY + dir.y;

        var lineStyle:LineStyle = { color: computeLineColor(), thickness: 6 };
        var drawStyle:DrawStyle = { smoothing: true };

        fill(FlxColor.TRANSPARENT);
        drawLine(startX, startY, endX, endY, lineStyle, drawStyle);
    }

    private function computeLineColor():FlxColor
    {

        var retval:FlxColor = new FlxColor(0);
        retval.setRGBFloat(1 - (throwSpeed / (PlayerReg.maxThrowSpeed + 100)), throwSpeed / (PlayerReg.maxThrowSpeed + 100), 0);
        return retval;
    }

    private function getVectorLength(vector:FlxPoint):Float
    {
        var length:Float = Math.sqrt(vector.x * vector.x + vector.y * vector.y);
        return length;
    }

    public inline static function radToDeg(rad:Float):Float
    {
        return 180 / Math.PI * rad;
    }
}
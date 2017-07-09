package tts.entities;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.group.FlxGroup;

import tts.objects.*;
import tts.settings.*;

class Entity extends FlxSprite
{
    public var id:Int;
    public var team:Int;

    // HUD
    private var throwArrow:ThrowArrow;
    public var hud:FlxGroup;

    // Moving
    public var speed:Float;
    public var onIce:Bool = false;
    private var lastDir:FlxPoint;

    // Animation
    private var dir:Int = 2;        // 0 = up , 1 = right , 2 = down , 3 = left
    private var isIdle:Bool = true;

    // Snowball 
    public var snowBallCount:Int = 0;
    public var makingSnowball:Bool = false;

    // Freezing
    public var freeze:Float = 0;
    private var freezeTimer:Float = 0;
    public var isFreezed:Bool = false;

    // Present
    public var hasPresent:Bool = false;
    private var touchingPresent:Present;
    private var carryingPresent:Present;

    public function new(id:Int, ?X:Float=0, ?Y:Float=0)
    {
        super(X, Y);
        
        drag.x = drag.y = 1800;

        lastDir = new FlxPoint(0, 0);

        hud = new FlxGroup();
        hud.add(new SnowballHUD(this));
    }

    private function setLookDir(vector:FlxPoint):Void 
    {
        isIdle = false;
        if(vector.y < 0 && (vector.x < 0.5 && vector.x > -0.5)) {
            dir = 0;
        } else if(vector.y > 0  && (vector.x < 0.5 && vector.x > -0.5)) {
            dir = 2;
        } else if(vector.x > 0) {
            dir = 1;
        } else if(vector.x < 0) {
            dir = 3;
        }
    }

    private function getVectorLength(vector:FlxPoint):Float
    {
        var length:Float = Math.sqrt(vector.x * vector.x + vector.y * vector.y);
        return length;
    }

    // Active Actions
    private function makeSnowBall():Void
    {
        //trace("OnIce: " + onIce);
        if(snowBallCount < PlayerReg.maxSnowball && !makingSnowball && !onIce && !hasPresent) {
            makingSnowball = true;
            isIdle = false;
            animation.play("makeSnowball");
        }
    }

    private function throwSnowBall(throwDir:FlxPoint, throwSpeed:Int):Void
    {
        if(snowBallCount > 0 && !hasPresent) {
            PlayState.snowBalls[team].add(new Snowball(this.team, throwDir, 
                this.x + (this.width / 2), this.y + (this.height / 2), throwSpeed));
            snowBallCount--;
            // TODO block animation while throw animation
            if(dir == 0) animation.play("tU", true);
            else if(dir == 1) animation.play("tR", true);
            else if(dir == 2) animation.play("tD", true);
            else if(dir == 3) animation.play("tL", true);
            isIdle = false;
        }
    }

    private function pickUpPresent():Void
    {
        if(!hasPresent && touchingPresent != null && touchingPresent.player == null) {
            hasPresent = true;
            touchingPresent.player = this;
            carryingPresent = touchingPresent;
            isIdle = false;

            animation.play("pIdleD");
        } else if(hasPresent) {
            hasPresent = false;
            carryingPresent.player = null;
            carryingPresent = null;
            isIdle = false;

            animation.play("idleD");
        }
    }

    // Passive Actions
    public function hit():Void
    {
        if(!hasPresent && !isFreezed) {
            freeze += PlayerReg.freezeSpeed;
            if(freeze >= PlayerReg.freezeLimit) freeze = PlayerReg.freezeLimit;
        } else if(!isFreezed) {
            freeze = PlayerReg.freezeLimit;
            hasPresent = false;
            carryingPresent.player = null;
            carryingPresent = null;
            isIdle = false;
        }
    }

    private function warmUp():Void
    {
        if(freeze >= PlayerReg.freezeLimit && freezeTimer <= PlayerReg.freezeTimer && !isFreezed) {
            isFreezed = true;
            makingSnowball = false;
            freeze = PlayerReg.freezeLimit;
        }

        if(isFreezed && freezeTimer <= PlayerReg.freezeTimer) {
            freezeTimer += 1;
            if(freezeTimer < 40) animation.play("inIce1");
            else if(freezeTimer < 80) animation.play("inIce2");
            else animation.play("inIce3");
            setColorTransform(1, 1);
        } else if(isFreezed && freezeTimer >= PlayerReg.freezeTimer) {
            isFreezed = false;
            freezeTimer = 0;
            freeze = PlayerReg.freezeAfter;
            isIdle = false;
        } else {
            freeze -= PlayerReg.warmUpSpeed;
            if(freeze < 0) freeze = 0;
            setColorTransform(1 - (freeze / PlayerReg.freezeLimit), 1 - ((freeze / PlayerReg.freezeLimit) / 4));
        }
    }

    public function playerTouchesPresent(present:Present):Void
    {
        if(touchingPresent == null && !hasPresent) {
            this.touchingPresent = present;
        }
    }

    private function animationCallBack(anim:String):Void {
        switch(anim) {
            case "makeSnowball": 
                makingSnowball = false;
                snowBallCount++;
        }
    }
}
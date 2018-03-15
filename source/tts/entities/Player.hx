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
import tts.input.*;

class Player extends Entity
{
    private var input:Input;    

    public function new(id:Int, input:Input, team:Int, ?X:Float=0, ?Y:Float=0)
    {
        super(id, X, Y);
        this.id = id;
        this.team = team;
        this.input = input;

        if(id % 4 == 0)
            loadGraphic(AssetPaths.charWT1__png, true, 48, 48);
        else if(id % 4 == 1)
            loadGraphic(AssetPaths.charMT2__png, true, 48, 48);
        else if(id % 4 == 2)
            loadGraphic(AssetPaths.charMT1__png, true, 48, 48);
        else if(id % 4 == 3)
            loadGraphic(AssetPaths.charWT2__png, true, 48, 48);

        setSize(34, 32);
        offset.set(7, 16);
        
        animation.finishCallback = animationCallBack;
        addAnimations();

        throwArrow = new ThrowArrow(input, this);
        hud.add(throwArrow);
    }
    private function addAnimations():Void
    {
        animation.add("idleD", [0], 1, false);
        animation.add("d", [1,3,2,3], 6, false);

        animation.add("idleU", [4], 1, false);
        animation.add("u", [5,7,6,7], 6, false);

        animation.add("idleR", [8], 1, false);
        animation.add("r", [9,11,10,11], 6, false);
        
        animation.add("idleL", [12], 1, false);
        animation.add("l", [13,15,14,15], 6, false);
        
        animation.add("makeSnowball", [16, 17, 16, 17], 4, false);
        animation.add("inIce1", [18], 1, false);
        animation.add("inIce2", [19], 1, false);
        animation.add("inIce3", [27], 1, false);

        animation.add("tD", [20, 20], 10, false);
        animation.add("tU", [21, 21], 10, false);
        animation.add("tL", [22, 22], 10, false);
        animation.add("tR", [23, 23], 10, false);

        animation.add("pIdleD", [24], 1, false);
        animation.add("pD", [25,24,26,24], 6, false);

        animation.add("pIdleU", [28], 1, false);
        animation.add("pU", [29, 28, 30, 28], 6, false);

        animation.add("pIdleR", [32], 1, false);
        animation.add("pR", [33, 32, 34, 32], 6, false);

        animation.add("pIdleL", [36], 1, false);
        animation.add("pL", [37, 36, 38, 36], 6, false);
    }

    override public function update(elapsed:Float):Void
    {
        if(freeze > 0) warmUp();
        if(pickupCooldown > 0) pickupCooldown--;
        
        if(!isFreezed) {
            if(input.buttonMakeSnowball) makeSnowBall();
            if(!makingSnowball) {
                if(input.buttonTakePresent) pickUpPresent();
                movement();
                if((input.buttonThrow) && input.aiming) throwSnowBall(input.getThrowDir(this.getPosition()));
            }
        }
        
        touchingPresent = null;
        onIce = false;
        
        super.update(elapsed);
    }

    private function movement():Void
    {
        if(input.moving) {
            var maxSpeed:Float = PlayerReg.maxSpeed;
            if(hasPresent) maxSpeed = PlayerReg.presentMaxSpeed;
            
            speed = maxSpeed;
            speed -= ((freeze / PlayerReg.freezeLimit) * speed);
            var currentDir:FlxPoint = new FlxPoint(input.movDir.x, input.movDir.y);

            setLookDir(currentDir);

            currentDir.scale(speed / getVectorLength(currentDir));
            if(onIce) {
                currentDir.scale(PlayerReg.iceInertia);
                lastDir.addPoint(currentDir);
                var vLength:Float = getVectorLength(lastDir);
                if(vLength > maxSpeed) {
                    lastDir.scale(speed / vLength);
                }
            } else {
                lastDir = currentDir;
            }
            velocity.set(lastDir.x, lastDir.y);
        } else {
            if(onIce && getVectorLength(lastDir) > 1) {
                    lastDir.scale(1 - PlayerReg.iceInertia);
                    velocity.set(lastDir.x, lastDir.y);
            } else {
                lastDir.set(0, 0);
            }
        }

        if(input.aiming && snowBallCount > 0) setLookDir(input.getThrowDir(this.getPosition()));
        playWalkAnimation();
    }

    // Animation 
    private function playWalkAnimation():Void
    {
        if(!hasPresent) {
            if(input.moving) {
                if(touching == FlxObject.NONE && !isFreezed)  {
                    if(dir == 0) animation.play("u");
                    else if(dir == 1) animation.play("r");
                    else if(dir == 2) animation.play("d");
                    else if(dir == 3) animation.play("l");
                }
            } else {
                if(!isIdle) {
                    isIdle = true;
                    if(dir == 0) animation.play("idleU");
                    else if(dir == 1) animation.play("idleR");
                    else if(dir == 2) animation.play("idleD");
                    else if(dir == 3) animation.play("idleL");
                }
            }
        } else {
            if(input.moving) {
                if(touching == FlxObject.NONE && !isFreezed) {
                    if(dir == 0) animation.play("pU");
                    else if(dir == 1) animation.play("pR");
                    else if(dir == 2) animation.play("pD");
                    else if(dir == 3) animation.play("pL");
                }
            } else {
                if(!isIdle) {
                    isIdle = true;
                    if(dir == 0) animation.play("pIdleU");
                    else if(dir == 1) animation.play("pIdleR");
                    else if(dir == 2) animation.play("pIdleD");
                    else if(dir == 3) animation.play("pIdleL");
                }
            }
        }
    }

    override function throwSnowBall(throwDir:FlxPoint):Void
    {
        super.throwSnowBall(throwDir, throwArrow.throwSpeed);
        throwArrow.throwSpeed = PlayerReg.minThrowSpeed;
    }
}
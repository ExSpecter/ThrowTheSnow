package tts.entities;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxVelocity;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPath;

import tts.objects.*;
import tts.settings.*;

class KI extends Entity
{
    private var player:Entity;
    private var walls:FlxTilemap;

    private var basePoint:FlxPoint;

    public var present:Present;

    private var snowAreas = new Array<FlxPoint>();

    public function new(id:Int, team:Int, player:Entity, walls:FlxTilemap, ?X:Float=0, ?Y:Float=0)
    {
        super(id, X, Y);
        this.id = id;
        this.team = team;
        this.player = player;
        this.walls = walls;
        
        this.path = new FlxPath();

        loadGraphic(AssetPaths.charMT2__png, true, 48, 48);

        setSize(34, 32);
        offset.set(7, 16);
        
        animation.finishCallback = animationCallBack;

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

        thisPos = new FlxPoint(0, 0);
        playerPos = new FlxPoint(0, 0);
        presentPos = new FlxPoint(0, 0);

        basePoint = new FlxPoint(816, 432);

        snowAreas[0] = new FlxPoint(204, 92);
        snowAreas[1] = new FlxPoint(456, 284);
        snowAreas[2] = new FlxPoint(90, 384);
        snowAreas[3] = new FlxPoint(815, 284);
    }

    override public function update(elapsed:Float):Void
    {
        // this.path.cancel();
        
        if(freeze > 0) warmUp();
        if(!isFreezed) {
            if(snowBallCount < 1 && !player.isFreezed) makeSnowBall();
            if(!makingSnowball) {
                if(touchingPresent != null) pickUpPresent();
                movement();
                if(getVectorLength(new FlxPoint(Math.abs(player.x - this.x), Math.abs(player.y - this.y))) < 300 && !player.isFreezed)
                     throwSnowBall(new FlxPoint(player.x - this.x, player.y - this.y), 600);
            }
        }

        touchingPresent = null;
        onIce = false;
        super.update(elapsed);
    }

    var pathPoints:Array<FlxPoint>;
    var thisPos:FlxPoint;
    var playerPos:FlxPoint;
    var presentPos:FlxPoint;
    private function movement():Void
    {
        thisPos.set(this.x  + this.width / 2, this.y + this.height / 2);
        if(!hasPresent) {
            if(player.isFreezed) pathPoints = walls.findPath(thisPos, presentPos.set(present.x + present.width / 2, 
                                                                present.y + present.height / 2));
            else {
                if(snowBallCount > 0) pathPoints = walls.findPath(thisPos, playerPos.set(player.x + player.width / 2, player.y + player.height / 2));
                else pathPoints = pathToSnowArea();
            }
        } else {
            pathPoints = walls.findPath(thisPos, basePoint);
            if(pathPoints[1] == null) pickUpPresent();
        }

        // this.path.start(pathPoints, PlayerReg.maxSpeed - 100, FlxPath.FORWARD, false, true);
        
        if(pathPoints != null && pathPoints[1] != null) {
            pathPoints[1].add(this.width / 2, this.height / 2);
            if(hasPresent) FlxVelocity.moveTowardsPoint(this, pathPoints[1], PlayerReg.presentMaxSpeed - 35);
            else FlxVelocity.moveTowardsPoint(this, pathPoints[1], PlayerReg.maxSpeed - 35);
        }

        setLookDir(this.velocity);

        playWalkAnimation();
    }

    private function pathToSnowArea():Array<FlxPoint>
    {
        var distance:Float = thisPos.distanceTo(snowAreas[0]);
        var point:FlxPoint = new FlxPoint(0, 0);

        for(snowPoint in snowAreas) {
            if(thisPos.distanceTo(snowPoint) < distance) point.set(snowPoint.x , snowPoint.y);
        }
        if(player.hasPresent) point.set(snowAreas[0].x, snowAreas[0].y);

        return walls.findPath(thisPos, point);
    }

    // Animation 
    private function playWalkAnimation():Void
    {
        if(!hasPresent) {
            if(velocity.y != 0 && velocity.x != 0) {
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
            if(velocity.y != 0 && velocity.x != 0) {
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
}
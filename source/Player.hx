package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.group.FlxGroup;

class Player extends FlxSprite
{
    public var id:Int;
    public var team:Int;
    private var controller:Controller;

    // HUD
    public var playerAdditions:FlxGroup;
    private var throwArrow:ThrowArrow;

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
    private var isFreezed:Bool = false;

    // Present
    public var hasPresent:Bool = false;
    private var touchingPresent:Present;
    private var carryingPresent:Present;

    public function new(id:Int, controller:Controller, team:Int, ?X:Float=0, ?Y:Float=0)
    {
        super(X, Y);
        this.id = id;
        this.team = team;
        this.controller = controller;

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

        animation.add("idleD", [0], 1, false);
        animation.add("d", [1,3,2,3], 6, false);

        animation.add("idleU", [4], 1, false);
        animation.add("u", [5,7,6,7], 6, false);

        animation.add("idleR", [8], 1, false);
        animation.add("r", [9,11,10,11], 6, false);
        
        animation.add("idleL", [12], 1, false);
        animation.add("l", [13,15,14,15], 6, false);
        
        animation.add("makeSnowball", [16, 17, 16, 17], 4, false); // TODO
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
        
        drag.x = drag.y = 1800;

        lastDir = new FlxPoint(0, 0);

        playerAdditions = new FlxGroup();
        throwArrow = new ThrowArrow(controller, this);
        playerAdditions.add(throwArrow);
        playerAdditions.add(new SnowballHUD(this));
    }

    override public function update(elapsed:Float):Void
    {
        if(freeze > 0) warmUp();
        if(!isFreezed) {
            makeSnowBall();
            if(!makingSnowball) {
                pickUpPresent();
                movement();
                if(snowBallCount > 0 && !hasPresent) throwSnowBall();
            }
        }
        super.update(elapsed);
    }

    private function movement():Void
    {
        if(controller.moving) {
            var maxSpeed:Float = PlayerReg.maxSpeed;
            if(hasPresent) maxSpeed = PlayerReg.presentMaxSpeed;
            
            speed = maxSpeed;
            speed -= ((freeze / PlayerReg.freezeLimit) * speed);
            var currentDir:FlxPoint = new FlxPoint(controller.movDir.x, controller.movDir.y);

            setDir(currentDir);

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

        if(controller.aiming && snowBallCount > 0) setDir(new FlxPoint(controller.throwDir.x, controller.throwDir.y));
        playAnimation();
        onIce = false;
    }

    private function playAnimation():Void
    {
        if(!hasPresent) {
            if(controller.moving) {
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
            if(controller.moving) {
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

    private function setDir(vector:FlxPoint):Void 
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

    private function makeSnowBall():Void
    {
        if(snowBallCount < PlayerReg.maxSnowball && !makingSnowball && !onIce && controller.buttonA && !hasPresent) {
            makingSnowball = true;
            isIdle = false;
            animation.play("makeSnowball");
        }
    }

    private function throwSnowBall():Void
    {
        if(controller.rightTrigger && controller.aiming) {
            PlayState.snowBalls[team].add(new Snowball(this.team, controller.throwDir, 
                this.x + (this.width / 2), this.y + (this.height / 2), throwArrow.throwSpeed));
            throwArrow.throwSpeed = PlayerReg.minThrowSpeed;
            snowBallCount--;
            // TODO block animation while throw animation
            if(dir == 0) animation.play("tU", true);
            else if(dir == 1) animation.play("tR", true);
            else if(dir == 2) animation.play("tD", true);
            else if(dir == 3) animation.play("tL", true);
            isIdle = false;
        }
    }

    private function animationCallBack(anim:String):Void {
        switch(anim) {
            case "makeSnowball": 
                makingSnowball = false;
                snowBallCount++;
        }
    }

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
        }
        
        if(isFreezed && freezeTimer <= PlayerReg.freezeTimer) {
            freezeTimer += 1;
            if(freezeTimer < 40) animation.play("inIce1");
            else if(freezeTimer < 80) animation.play("inIce2");
            else animation.play("inIce3");
        } else if(isFreezed && freezeTimer >= PlayerReg.freezeTimer) {
            isFreezed = false;
            freezeTimer = 0;
            freeze = PlayerReg.freezeAfter;
            isIdle = false;
        } else {
            freeze -= PlayerReg.warmUpSpeed;
            if(freeze < 0) freeze = 0;
        }
    }

    public function playerTouchesPresent(present:Present):Void
    {
        if(touchingPresent == null && !hasPresent) {
            this.touchingPresent = present;
        }
    }

    private function pickUpPresent():Void
    {
        if(!hasPresent && touchingPresent != null && touchingPresent.player == null && controller.buttonX) {
            hasPresent = true;
            touchingPresent.player = this;
            carryingPresent = touchingPresent;
            isIdle = false;
        } else if(hasPresent && controller.buttonX) {
            hasPresent = false;
            carryingPresent.player = null;
            carryingPresent = null;
            isIdle = false;
        }
        touchingPresent = null;
    }
}
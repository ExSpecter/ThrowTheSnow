package tts;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTile;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.addons.editors.ogmo.FlxOgmoLoader;

import tts.settings.*;
import tts.entities.*;
import tts.objects.*;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	private var mapFile:FlxOgmoLoader;
	private var mFloor:FlxTilemap;
	private var mFloor2:FlxTilemap;
	private var mWalls:FlxTilemap;

	private var player1:Entity;
	private var enemy:KI;

	private var playerTeams = new Array<FlxTypedGroup<Entity>>();
	private var playerAdditions:FlxGroup;
	public static var snowBalls = new Array<FlxTypedGroup<Snowball>>();
	private var presents:FlxGroup;
	private var endZones:FlxGroup;

	override public function create():Void
	{
		FlxG.debugger.drawDebug;
		Reg.gameOver = false;

		showCursorIfKeyboardIsInput();
		initGameVariables();

		initMap();

		add(mFloor);
		add(mWalls);
		add(presents);

		countDown();

		super.create();
	}

	private function showCursorIfKeyboardIsInput():Void
	{
		if(Reg.keyboardUsed) {
			var sprite = new FlxSprite();
			sprite.makeGraphic(12, 12, FlxColor.TRANSPARENT);
			sprite.drawCircle(-1, -1, -1, FlxColor.BLACK);

			// Load the sprite's graphic to the cursor
			FlxG.mouse.load(sprite.pixels);
		}
		FlxG.mouse.visible = Reg.keyboardUsed;
	}
	public function initGameVariables():Void
	{
		playerTeams[0] = new FlxTypedGroup<Entity>();
		playerTeams[1] = new FlxTypedGroup<Entity>();
		playerAdditions = new FlxGroup();

		PlayState.snowBalls[0] = new FlxTypedGroup<Snowball>();
		PlayState.snowBalls[1] = new FlxTypedGroup<Snowball>();
		presents = new FlxGroup();
		endZones = new FlxGroup();
	}
	public function addScoreDisplay():Void
	{
		var pointsT1:FlxText = new FlxText(5);
		pointsT1.setFormat(null, 18, 0x3F5CFF);
		pointsT1.text = "" + Reg.pointsT1;
		add(pointsT1);

		var pointsT2:FlxText = new FlxText();
		pointsT2.setFormat(null, 18, 0xFF1632);
		pointsT2.text = "" + Reg.pointsT2;
		pointsT2.setPosition(FlxG.width - pointsT2.width - 5);
		add(pointsT2);
		
	}

	private function countDown():Void
	{
		this.active = true;

		var overlay:FlxSprite = new FlxSprite();
		overlay.makeGraphic(FlxG.width, FlxG.height, 0x66000000);
		add(overlay);

		var countDown:Int = 3;
		var countDownTxt:FlxText = new FlxText(0, FlxG.height / 2 - 100, FlxG.width);
		countDownTxt.setFormat(null, 16, 0xFFFFFF, FlxTextAlign.CENTER);
		countDownTxt.text = countDown+"";
		add(countDownTxt);

		var index:Int = 0;
		FlxTween.tween(countDownTxt.scale, { x:3.5, y:3.5 }, 0.5, { type:FlxTween.PINGPONG }).onComplete = function(t:FlxTween):Void
		{
			if(++index % 2 == 0) {
				countDown -= 1;
				if(countDown == 0) {
					remove(overlay);

					add(playerTeams[0]);
					add(playerTeams[1]);
					add(playerAdditions);
					add(PlayState.snowBalls[0]);
					add(PlayState.snowBalls[1]);
					add(mFloor2);
					
					countDownTxt.text = "LOS";
					countDownTxt.scale.x = countDownTxt.scale.y = 4;
					FlxTween.tween(countDownTxt, {y: -100}, 2, {type:FlxTween.ONESHOT}).onComplete = function(t:FlxTween):Void
					{
						remove(countDownTxt);
					}
					t.cancel();
				} else {
					countDownTxt.text = countDown+"";
				}
			}
		}
	}

	private function createPlayer(i:Int, X:Float, Y:Float):Void
	{
		var team:Int = i % 2;
		Reg.c[i].exists = true;
		var player:Player = new Player(i, Reg.c[i], team, X, Y);
		if(i == 0) player1 = player;
		add(Reg.c[i]);
		playerTeams[team].add(player);
		playerAdditions.add(player.hud);
	}

	private function initMap():Void
	{
		mapFile = new FlxOgmoLoader(AssetPaths.Map__oel);
		mFloor = mapFile.loadTilemap(AssetPaths.Tileset__png, 32, 32, "floor");
		mFloor2 = mapFile.loadTilemap(AssetPaths.Tileset__png, 32, 32, "floor2");
		mWalls = mapFile.loadTilemap(AssetPaths.Tileset__png, 32, 32, "walls");
		mWalls.follow();
	
		for(i in 0...80) {
			mFloor.setTileProperties(i, FlxObject.NONE);
			mFloor2.setTileProperties(i, FlxObject.NONE);
			if(i == 13) 
				mFloor.setTileProperties(i, FlxObject.NONE, playerOnIce, Entity);
			if(i > 0)
				mWalls.setTileProperties(i, FlxObject.ANY, snowBallWallCollide, Snowball);
		}
 
		mapFile.loadEntities(placeEntities, "entities");
	}
	private function playerOnIce(TILE:FlxObject, ENTITY:FlxObject):Void
	{
		var player:Entity = cast ENTITY;
		player.onIce = true;
	}
	private function snowBallWallCollide(TILE:FlxObject, SNOWBALL:FlxObject):Void
	{
		var snowBall:Snowball = cast SNOWBALL;
		snowBall.kill();
	}

	private var addedPlayer:Int = 0;
	private function placeEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		// TODO Refactor
		if(entityName == "Player1" && Reg.playerCount > addedPlayer) createPlayer(addedPlayer++, x, y);
		else if(entityName == "Player2" && Reg.playerCount > addedPlayer) createPlayer(addedPlayer++, x, y);
		else if(entityName == "Player2" && Reg.playerCount == 1) {
			enemy = new KI(1, 1, player1, mWalls, x, y);
			playerTeams[1].add(enemy);
		} else if(entityName == "Player3" && Reg.playerCount > addedPlayer) createPlayer(addedPlayer++, x, y);
		else if(entityName == "Player4" && Reg.playerCount > addedPlayer) createPlayer(addedPlayer++, x, y); 
		else if(entityName == "Present") {
			var pres:Present = new Present(x, y);
			presents.add(pres);
			if(Reg.playerCount == 1) enemy.present = pres;
		} else if(entityName == "EndZoneT1") {
			endZones.add(new EndZone(0, x, y));
		} else if(entityName == "EndZoneT2") {
			endZones.add(new EndZone(1, x, y));
		}

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(FlxG.keys.justPressed.SPACE) FlxG.fullscreen = !FlxG.fullscreen;

		FlxG.collide(playerTeams[0], mWalls);
		FlxG.collide(playerTeams[1], mWalls);
		FlxG.collide(playerTeams[0], mFloor);
		FlxG.collide(playerTeams[1], mFloor);

		// TODO Player Collision
		FlxG.overlap(playerTeams[0], PlayState.snowBalls[1], snowBallHitsPlayer);
		FlxG.overlap(playerTeams[1], PlayState.snowBalls[0], snowBallHitsPlayer);
		FlxG.overlap(playerTeams[0], presents, playerTouchPresent);
		FlxG.overlap(playerTeams[1], presents, playerTouchPresent);
		
		FlxG.collide(PlayState.snowBalls[0], mWalls);
		FlxG.collide(PlayState.snowBalls[1], mWalls);

		FlxG.overlap(endZones, presents, presentInEndZone);
	}
	private function snowBallHitsPlayer(player:Entity, snowBall:Snowball):Void 
	{
		snowBall.kill();
		player.hit();
	}
	private function playerTouchPresent(player:Entity, present:Present):Void
	{
		player.playerTouchesPresent(present);
	}
	private function presentInEndZone(endZone:EndZone, present:Present):Void
	{
		if(present.player == null && !Reg.gameOver) {
			Reg.gameOver = true;
			openSubState(new GameOver(endZone.team));
		}
	}
}

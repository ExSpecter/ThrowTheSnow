package tts;

import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.tile.FlxTilemap;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.tile.FlxTile;
import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import tts.settings.*;
import tts.entities.*;
import tts.objects.*;

class PlayState extends FlxState
{
	private var mapFile:FlxOgmoLoader;
	private var mFloor:FlxTilemap;
	private var mFloor2:FlxTilemap;
	private var mWalls:FlxTilemap;

	private var playerTeams = new Array<FlxTypedGroup<Player>>();
	private var playerAdditions:FlxGroup;
	public static var snowBalls = new Array<FlxTypedGroup<Snowball>>();
	private var presents:FlxGroup;
	private var endZones:FlxGroup;

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		Reg.gameOver = false;

		playerTeams[0] = new FlxTypedGroup<Player>();
		playerTeams[1] = new FlxTypedGroup<Player>();
		playerAdditions = new FlxGroup();

		PlayState.snowBalls[0] = new FlxTypedGroup<Snowball>();
		PlayState.snowBalls[1] = new FlxTypedGroup<Snowball>();
		presents = new FlxGroup();
		endZones = new FlxGroup();

		initMap();

		add(mFloor);
		add(mWalls);
		add(presents);

		var pointsT1:FlxText = new FlxText(5);
		pointsT1.setFormat(null, 18, 0x3F5CFF);
		pointsT1.text = "" + Reg.pointsT1;
		add(pointsT1);

		var pointsT2:FlxText = new FlxText();
		pointsT2.setFormat(null, 18, 0xFF1632);
		pointsT2.text = "" + Reg.pointsT2;
		pointsT2.setPosition(FlxG.width - pointsT2.width - 5);
		add(pointsT2);

		countDown();

		super.create();
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
				mFloor.setTileProperties(i, FlxObject.NONE, playerOnIce, Player);
			if(i > 0)
				mWalls.setTileProperties(i, FlxObject.ANY, snowBallWallCollide, Snowball);
		}

		mapFile.loadEntities(placeEntities, "entities");
	}

	private var addedPlayer:Int = 0;
	private function placeEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if(entityName == "Player1" && Reg.playerCount > addedPlayer) {
			createPlayer(addedPlayer, x, y);
			addedPlayer++;
		} else if(entityName == "Player2" && Reg.playerCount > addedPlayer) {
			createPlayer(addedPlayer, x, y);
			addedPlayer++;
		} else if(entityName == "Player3" && Reg.playerCount > addedPlayer) {
			createPlayer(addedPlayer, x, y);
			addedPlayer++;
		} else if(entityName == "Player4" && Reg.playerCount > addedPlayer) {
			createPlayer(addedPlayer, x, y);
			addedPlayer++;
		} else if(entityName == "Present") {
			presents.add(new Present(x, y));
		} else if(entityName == "EndZoneT1") {
			endZones.add(new EndZone(0, x, y));
		} else if(entityName == "EndZoneT2") {
			endZones.add(new EndZone(1, x, y));
		}
	}

	private function playerOnIce(TILE:FlxObject, PLAYER:FlxObject):Void
	{
		var player:Player = cast PLAYER;
		player.onIce = true;
	}

	private function snowBallWallCollide(TILE:FlxObject, SNOWBALL:FlxObject):Void
	{
		var snowBall:Snowball = cast SNOWBALL;
		snowBall.kill();
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

	private function snowBallHitsPlayer(player:Player, snowBall:Snowball):Void 
	{
		snowBall.kill();
		player.hit();
	}

	private function playerTouchPresent(player:Player, present:Present):Void
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

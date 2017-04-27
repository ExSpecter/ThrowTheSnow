package tts;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import tts.settings.*;

class MenuState extends FlxState
{
	private var infoPlayer:FlxText;
	private var playInformation:FlxGroup;
	private var gameMechanics:FlxGroup;

	private var shownState:Int = 1; // 1 = Menu | 2 = Game Mechanics

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		Reg.pointsT1 = 0;
		Reg.pointsT2 = 0;
		Reg.playerCount = 0;

		var background:FlxSprite = new FlxSprite(FlxG.width, FlxG.height, AssetPaths.Map2__png);
		background.screenCenter();
		add(background);

		var overlay:FlxSprite = new FlxSprite();
		overlay.makeGraphic(FlxG.width, FlxG.height, 0x66000000);
		add(overlay);

		playInformation = new FlxGroup();
		gameMechanics = new FlxGroup();

		initPlayInformation();	
		initGameMechanics();	

		add(playInformation);
		super.create();
	}

	private function initPlayInformation():Void
	{
		var title:FlxText = new FlxText(0, (FlxG.height / 2) - 140, FlxG.width);
		title.setFormat(null, 16, 0xFFFFFF, FlxTextAlign.CENTER);
		title.text = "Throw the Snow";
		title.angle = 5;
		playInformation.add(title);

		FlxTween.tween(title, { angle: -5 }, 1.5, { type:FlxTween.PINGPONG } );
		FlxTween.tween(title.scale, { x:4, y:4 }, 0.5, { ease:FlxEase.backOut } ).onComplete = function(t:FlxTween):Void
		{
			FlxTween.tween(title.scale, { x:3.5, y:3.5 }, 2, { type:FlxTween.PINGPONG } );
		}

		infoPlayer = new FlxText(0, title.y + title.height + 120, FlxG.width);
		infoPlayer.setFormat(null, 36, 0xe24a4a, FlxTextAlign.CENTER);
		infoPlayer.text = "Player " + (Reg.playerCount + 1) + " Press A";
		playInformation.add(infoPlayer);

		var infoStart:FlxText = new FlxText(0, title.y + title.height + 200, FlxG.width);
		infoStart.setFormat(null, 18, 0xFFFFFF, FlxTextAlign.CENTER);
		infoStart.text = "Press Start to Start the Game";
		playInformation.add(infoStart);

		var infoGameMechanics:FlxText = new FlxText(30, FlxG.height - 30, FlxG.width / 2);
		infoGameMechanics.setFormat(null, 18, 0xFFFFFF);
		infoGameMechanics.text = "X: Game Mechanics";
		playInformation.add(infoGameMechanics);
	}

	private function initGameMechanics():Void
	{
		var heading:FlxText = new FlxText(0, 120, FlxG.width);
		heading.setFormat(null, 48, 0xe24a4a, FlxTextAlign.CENTER);
		heading.text = "Game Mechanics";
		FlxTween.tween(heading.scale, { x:1.3, y:1.3 }, 2, { type:FlxTween.PINGPONG } );
		gameMechanics.add(heading);

		var mechanicsText:FlxText = new FlxText(0, heading.height + heading.y + 20, FlxG.width);
		mechanicsText.setFormat(null, 16, 0xFFFFFF, FlxTextAlign.CENTER);
		mechanicsText.text = 
		"Left Stick: Movement\n
		Right Stick: Aim\n
		A: Make Snowball\n
		X: Take Present\n
		RB: Throw Snowball\n\n
		The goal of the game is, to carry the present in the gras field on your side";
		gameMechanics.add(mechanicsText);

		var backInfo:FlxText = new FlxText(30, FlxG.height - 30, FlxG.width);
		backInfo.setFormat(null, 18, 0xFFFFFF);
		backInfo.text = "B: Back to Menu";
		gameMechanics.add(backInfo);
	}

	private function centerOnScreenX(source:FlxText):FlxText
	{
		source.x = (FlxG.width / 2) - (source.width / 2);
		return source;
	}

	var startGame:Bool = false;
	override public function update(elapsed:Float):Void
	{
		if(FlxG.keys.justPressed.SPACE) FlxG.fullscreen = !FlxG.fullscreen;
		
		if(!startGame) {
			askP();
		} else {
			goAhead();
		}
		super.update(elapsed);
	}

	private function askP():Void
	{
		for(gp in FlxG.gamepads.getActiveGamepads()) {
			if(gp.justPressed.START) {
				if(Reg.playerCount >= 1)
					startGame = true;
			} else if(gp.justReleased.A) {
				var isAlreadyConnected = false;
				for(controller in Reg.c) {
					if(gp == controller.pad) {
						isAlreadyConnected = true;
						break;
					}
				}
				if(!isAlreadyConnected) {
					Reg.c[Reg.playerCount] = new Controller(gp);
					Reg.playerCount++;
					infoPlayer.text = "Player " + (Reg.playerCount + 1) + " Press A";
					FlxG.camera.flash(0xffffffff, 0.4);
					break;
				}
			} else if(gp.justReleased.X) {
				if(shownState == 1) {
					remove(playInformation);
					add(gameMechanics);
					shownState = 2;
				}
			} else if(gp.justReleased.B) {
				if(shownState == 2) {
					remove(gameMechanics);
					add(playInformation);
					shownState = 1;
				}
			}
		}
	}

	private function goAhead():Void
	{
		FlxG.switchState(new PlayState());
	}
}

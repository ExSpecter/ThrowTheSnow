package ;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOver extends FlxSubState
{
	var shade:FlxSprite;
	
	public function new (team:Int) 
	{
		super();
		var overlay:FlxSprite = new FlxSprite();
		overlay.makeGraphic(FlxG.width, FlxG.height, 0x44000000);
		add(overlay);

		var title:FlxText = new FlxText(32, (FlxG.height / 2) - 200, FlxG.width);
		title.setFormat(null, 56, 0xe24a4a, FlxTextAlign.CENTER);

        if(team == 0) {
			Reg.pointsT1++;
		    title.text = "Team 1 hat gewonnen";
        } else {
			Reg.pointsT2++;
            title.text = "Team 2 hat gewonnen";
        }
		FlxTween.tween(title.scale, { x:1.2, y:1.2 }, 2, { type:FlxTween.PINGPONG } );
		add(title);

		var infoP1:FlxText = new FlxText(16, title.y + title.height + 100, FlxG.width);
		infoP1.setFormat(null, 24, 0xFFFFFF, FlxTextAlign.CENTER);
		infoP1.text = "Press Start to Play Again";
		add(infoP1);

		var infoP2:FlxText = new FlxText(16, title.y + title.height + 200, FlxG.width);
		infoP2.setFormat(null, 24, 0xFFFFFF, FlxTextAlign.CENTER);
		infoP2.text = "Press Back to Play Again with other Teams";
		add(infoP2);
		
        for(controller in Reg.c) {
			controller.exists = true;
            add(controller);
        }
	}
	
	var replay:Bool = true;
	
	override public function update(elapsed:Float):Void 
	{
		if(FlxG.keys.justPressed.SPACE) FlxG.fullscreen = !FlxG.fullscreen;

		for(controller in Reg.c) {
            if (controller.pad.justPressed.START) {
                close();
            } else if(controller.pad.justPressed.BACK) {
				replay = false;
				close();
			}
        }
		super.update(elapsed);
	}
	
	override public function close():Void 
	{
		if(replay) {
			FlxG.switchState(new PlayState());
		} else {
			Reg.c = new Array<Controller>();
			FlxG.switchState(new MenuState());
		}
	}
	
}
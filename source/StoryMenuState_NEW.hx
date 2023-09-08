package;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import lime.graphics.cairo.CairoExtend;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class StoryMenuState_NEW extends MusicBeatState {
	

	public static var weeksArray:Array<Array<String>> = [
		// ["week_1","Fresh, Milf, Ugh","tanuki"],
		["week_1","Spotlight, Color-Palette, Vibes","tanuki"],
		["week_2","Unused, Unknown, null", "nuky"],
		["week_3","Chasing-Tunes, Colorful-Illusion, null", "tanuki"],
	];

	public static var curWeekSelec:Int = 0;

	var sprWeek:FlxSprite;	
	var arrowGroup:FlxSpriteGroup;
	var songTrack:FlxText;
	var sprTracks:FlxSprite;

	var animGroup:FlxSpriteGroup;
	override function create() {

		sprWeek = new FlxSprite();
		sprWeek.frames = Paths.getSparrowAtlas("storymode/weeklist");
		for (i in 0...weeksArray.length){
			sprWeek.animation.addByPrefix(weeksArray[i][0], weeksArray[i][0] + " 0000");
		}
		sprWeek.y = FlxG.height - sprWeek.height - 20;
		sprWeek.screenCenter(X);
		sprWeek.animation.play(weeksArray[curWeekSelec][0]);
		add(sprWeek);

		arrowGroup = new FlxSpriteGroup();
		add(arrowGroup);

		var barr:FlxSprite = new FlxSprite().loadGraphic(Paths.image("storymode/bg_gradient"));
		add(barr);

		animGroup = new FlxSpriteGroup();
		add(animGroup);

		for (i in 0...2){
			var offset = 130;
			var sprArrow:FlxSprite = new FlxSprite();
			sprArrow.frames = Paths.getSparrowAtlas("storymode/button");
			sprArrow.animation.addByPrefix("idle", "arrow instance 1");
			sprArrow.animation.addByPrefix("pressed", "arrow press instance 1");
			arrowGroup.add(sprArrow);
			arrowGroup.ID = i;
			sprArrow.y = (sprWeek.y + sprWeek.height) / 1.3;

			if(i >= 1)sprArrow.x = sprWeek.x + sprWeek.height + (offset *2);
			else { sprArrow.flipX = true;
				sprArrow.x = sprWeek.x - offset;
			}
		}

		var characterStory:Array<Array<String>> = [
			["nuky", "Nuky Menu instance 1"],
			["tanuki", "Tanuki Menu instance 1"],
			["bf", "Bf Menu instance 1"],
			["boombox", "boombox menu instance 1"]
		];
		for (i in 0...characterStory.length){
			var sprChr:FlxSprite = new FlxSprite();
			sprChr.frames = Paths.getSparrowAtlas("storymode/" + characterStory[i][0]);
			sprChr.animation.addByPrefix("idle", characterStory[i][1]);
			sprChr.animation.play("idle");
			animGroup.add(sprChr);
			sprChr.ID = i;
			// sprChr.visible = false;

			switch(characterStory[i][0]){
				case "bf":
					sprChr.screenCenter(X);
				case "boombox":
					sprChr.setPosition((barr.width - sprChr.width) - 60,100);
				default:
					sprChr.x = 50;
					sprChr.visible = false;
			}

			sprChr.y += 40;
		}

		sprTracks = new FlxSprite(20,barr.height + 20).loadGraphic(Paths.image("storymode/tracks"));
		add(sprTracks);

		songTrack = new FlxText(0, sprTracks.y + 80,sprTracks.width + 30,"----");
		songTrack.setFormat("VCR OSD Mono", 25, 0xFFff3366, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(songTrack);
		
		// for (i in 0...3){
		// 	var songTrack:FlxText = new FlxText((sprTracks.x + sprTracks.width)/2.3,sprTracks.y+15,0,weeksArray[curWeekSelec][1].split(", ")[i],20);
		// 	songTrack.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		// 	songTrack.y += 50*(i+1);
		// 	add(songTrack);
		// }

		weekSection(0);

		

		super.create();
	}

	var selectedWeek:Bool = false;
	override function update(elapsed:Float) {
		

		if(!selectedWeek){
			if (controls.BACK){
				MusicBeatState.switchState(new MainMenuState());

			}
			
			if (controls.NOTE_LEFT || controls.NOTE_RIGHT){
				if (controls.NOTE_LEFT) 
					arrowGroup.members[0].animation.play("pressed");
				else 
					arrowGroup.members[1].animation.play("pressed");
			} else {
				arrowGroup.members[0].animation.play("idle");
				arrowGroup.members[1].animation.play("idle");
			}

			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT){
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (FlxG.keys.justPressed.LEFT) weekSection(-1);
				else weekSection(1);
			}

			if (controls.ACCEPT) {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxFlicker.flicker(sprWeek, 1, 0.08, false, false, weekSelected);
			}
		}

		super.update(elapsed);
	}

	function weekSelected(flick:FlxFlicker) {
		// FlxG.sound.play(Paths.sound('confirmMenu'));
		var songArray:Array<String> = weeksArray[curWeekSelec][1].replace(", null", "").split(', ');
		trace(songArray);

		
		// Nevermind that's stupid lmao
		PlayState.storyPlaylist = songArray;
		PlayState.isStoryMode = true;
		selectedWeek = true;


		// // var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
		// // if(diffic == null) diffic = '';
		
		PlayState.storyDifficulty = 0;
		
		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;

		LoadingState.loadAndSwitchState(new PlayState(), true);
		FreeplayState.destroyFreeplayVocals();
		// new FlxTimer().start(1, function(tmr:FlxTimer)
		// {

		// });
	}

	function weekSection(huh:Int) {
		curWeekSelec += huh;

		if (curWeekSelec > weeksArray.length-1)
			curWeekSelec = 0;
		else if (curWeekSelec < 0){
			curWeekSelec = weeksArray.length-1;
		}

		songTrack.text = weeksArray[curWeekSelec][1].replace(", null", "").replace("-", " ").replace(", ", "\n");
		// songTrack.x = ((sprTracks.x + sprTracks.width)/2)-songTrack.width;
		songTrack.centerOrigin();


		animGroup.members[0].visible = animGroup.members[1].visible = false;

		switch(weeksArray[curWeekSelec][2]){
			case 'tanuki':
				animGroup.members[1].visible = true;
			case 'nuky':
				animGroup.members[0].visible = true;	 
		}

		// trace(weeksArray[curWeekSelec][1].split(", ")[0]);
		// trace(weeksArray[curWeekSelec][0]);
		sprWeek.animation.play(weeksArray[curWeekSelec][0], true);
	}

}
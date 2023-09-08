package;

import shaders.VCRDistortionEffect;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.FlxTrail;
import flixel.input.FlxAccelerometer;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import shaders.ChromaticAberration;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];

	var sprGallery:FlxSprite;

	var magenta:FlxSprite;
	// var camFollow:FlxObject;
	// var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.add(camAchievement);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var colorRandown:Array<FlxColor> = [
			0xFF9271fd,
			0xFFA1CDEC,
			0xFFC992E4,
			0xFFEEAC66,
			0xFFDEFF98,
			0xFFFB9ABC,
		];

		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menuDesat'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.color = colorRandown[FlxG.random.int(0,colorRandown.length-1)];
		add(bg);

		magenta = new FlxSprite(0).loadGraphic(Paths.image('menuDesat'));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);


		var bolas:FlxBackdrop = new FlxBackdrop(Paths.image('balls'));
		bolas.alpha = 16/100;
		bolas.velocity.set(30,30);
		add(bolas);


		var scl:Float = 0.6;
		var mouse:FlxSprite = new FlxSprite().loadGraphic(Paths.image('cursor_asset'));
		mouse.setGraphicSize(Std.int(mouse.width * scl),Std.int(mouse.width * scl));
		mouse.updateHitbox();
		FlxG.mouse.load(mouse.pixels);
		FlxG.mouse.visible = true;

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			// menuItem.screenCenter(X);
			menuItem.y -= 25;
			menuItem.x = FlxG.width - menuItem.width;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('blackbars'));
		bg.screenCenter();
		add(bg);


		sprGallery = new FlxSprite(25);
		sprGallery.frames = Paths.getSparrowAtlas("galleryButton");
		sprGallery.animation.addByPrefix('idle', 'Gallery Button instance 1', 24);
		sprGallery.animation.play('idle');
		add(sprGallery);

		sprGallery.y = FlxG.height - sprGallery.height - 50;

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		
		// var filterCrom:VCRDistortionEffect = new VCRDistortionEffect();
		// FlxG.camera.setFilters([new ShaderFilter(filterCrom.shader)]);

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (FlxG.mouse.overlaps(menuItems)){
				menuItems.forEach(function(spr:FlxSprite){
					if (FlxG.mouse.overlaps(spr)){
						curSelected = spr.ID;
						changeItem(0);

						if (FlxG.mouse.justPressed)	goToState(optionShit[curSelected]);
					}
				});
			}

			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.mouse.overlaps(sprGallery) && FlxG.mouse.justPressed){
				trace("ai papai tubarao");
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT) goToState(optionShit[curSelected]);
			
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function goToState(daChoice) {
		selectedSomethin = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxG.mouse.visible = false;

		if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.20, false);
			
		FlxTween.tween(sprGallery, {x: -sprGallery.width}, 0.8, {ease: FlxEase.backIn,onComplete: function(twn:FlxTween){sprGallery.kill();}});
		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, {x: FlxG.width}, 0.8 - (spr.ID/10), {
				ease: FlxEase.backIn,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
				FlxFlicker.flicker(spr, 1, 0.08, false, false, function(flick:FlxFlicker) {
					switch (daChoice)
					{
						case 'story_mode':
							MusicBeatState.switchState(new StoryMenuState_NEW());
							// MusicBeatState.switchState(new StoryMenuState());
						case 'freeplay':
							MusicBeatState.switchState(new FreeplayState());
						case 'credits':
							MusicBeatState.switchState(new CreditsState());
						case 'options':
							LoadingState.loadAndSwitchState(new options.OptionsState());
					}
				});
			
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;



		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;

				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
				spr.offset.x += 80;
			}
		});
	}
}

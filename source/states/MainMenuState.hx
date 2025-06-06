package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var mistVersion:String = "?\n(Old Build) | Restored Edition";
	public static var micdUpVersion:String = "2.0.3\nAmp'd Even Further"; // The Latest Version ):
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		//'story_mode',
		'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		//#if !switch 'donate', #end
		'options'
	];

	var red:FlxSprite;
	var camFollow:FlxObject;

	override function create()
{
    #if MODS_ALLOWED
    Mods.pushGlobalMods();
    #end
    Mods.loadTopMod();

    #if DISCORD_ALLOWED
    // Updating Discord Rich Presence
    DiscordClient.changePresence("In the Menus", null);
    #end
    
    persistentUpdate = persistentDraw = true;

    var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
    var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mistBG'));
    bg.antialiasing = ClientPrefs.data.antialiasing;
    bg.scrollFactor.set(0, yScroll);
    bg.setGraphicSize(Std.int(bg.width * 1.175));
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    var watermark:FlxSprite = new FlxSprite();
    watermark.loadGraphic(Paths.image('mainmenu/menuWatermark'));
    watermark.antialiasing = ClientPrefs.data.antialiasing;
    watermark.setGraphicSize(Std.int(watermark.width * 0.5));
    watermark.updateHitbox();
    watermark.x = FlxG.width - watermark.width;
    watermark.y = FlxG.height - watermark.height;
    add(watermark);

    camFollow = new FlxObject(0, 0, 1, 1);
    add(camFollow);

    red = new FlxSprite(-80).loadGraphic(Paths.image('mistDesat'));
    red.antialiasing = ClientPrefs.data.antialiasing;
    red.scrollFactor.set(0, yScroll);
    red.setGraphicSize(Std.int(red.width * 1.175));
    red.updateHitbox();
    red.screenCenter();
    red.visible = false;
    red.color = 0xffff2d2d;
    add(red);

    menuItems = new FlxTypedGroup<FlxSprite>();
    add(menuItems);

    for (i in 0...optionShit.length)
    {
        var menuItem:FlxSprite = new FlxSprite();
        menuItem.antialiasing = ClientPrefs.data.antialiasing;
        menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
        menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
        menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
        menuItem.animation.play('idle');
        menuItems.add(menuItem);
        var scr:Float = (optionShit.length - 4) * 0.135;
        if (optionShit.length < 6)
            scr = 0;
        menuItem.scrollFactor.set(0, scr);
        menuItem.updateHitbox();
        // Custom positions for Freeplay, Credits, and Options
        switch(optionShit[i]) {
            case 'freeplay':
                menuItem.x = 10;
                menuItem.y = 180;
            case 'credits':
                menuItem.x = 10;
                menuItem.y = 340;
            case 'options':
                menuItem.x = 10;
                menuItem.y = 500;
            default:
                menuItem.screenCenter(X);
                menuItem.y = 60;
        }
    }
    
    var mistVer:FlxText = new FlxText(12, FlxG.height - 84, 0, "Mistful Crimson Morning v" + mistVersion, 12);
    mistVer.scrollFactor.set();
    mistVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(mistVer);
    var micdUpVer:FlxText = new FlxText(12, FlxG.height - 44,  FlxG.width - 24, "Mic'd Up v" + micdUpVersion, 12);
    micdUpVer.scrollFactor.set();
    micdUpVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(micdUpVer);
    var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
    psychVer.scrollFactor.set();
    psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(psychVer);
    var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
    fnfVer.scrollFactor.set();
    fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(fnfVer);
    changeItem();

    #if ACHIEVEMENTS_ALLOWED
    // Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
    var leDate = Date.now();
    if (leDate.getDay() == 5 && leDate.getHours() >= 18)
        Achievements.unlock('friday_night_play');

    #if MODS_ALLOWED
    Achievements.reloadList();
    #end
    #end

    super.create();

    if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        FlxG.sound.music.fadeIn(4, 0, 0.7);
    }

    if (Transition.fromState != "main") {
        FlxG.camera.zoom = 0.8;
        Transition.zoomIn("main");
    	}
	else {
        Transition.resetZoom();
    }

    // FlxG.camera.follow(camFollow, null, 9);
}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				
				// Fade out current music and play intro-freakyMenu
				FlxG.sound.music.fadeOut(0.5, 0, function(twn:flixel.tweens.FlxTween) {
				FlxG.sound.music.stop();
                Transition.zoomOut("MainMenuState", function() {
                    Transition.fromState = "MainMenuState";
                    MusicBeatState.switchState(new TitleState());
                });
				FlxG.sound.playMusic(Paths.music('intro-freakyMenu'), 0);
				FlxG.sound.music.fadeIn(0.5, 0, 0.7);
				});
			}

			if (controls.ACCEPT)
			{
    			FlxG.sound.play(Paths.sound('confirmMenu'));
    			selectedSomethin = true;

    			Transition.zoomOut("main", function()
    			{
        			switch (optionShit[curSelected])
        			{
            			case 'freeplay':
                			MusicBeatState.switchState(new FreeplayState());
            
            			case 'credits':
                			MusicBeatState.switchState(new CreditsState());
            
            			case 'options':
                			MusicBeatState.switchState(new OptionsState());
							FlxG.sound.music.stop();
                			FlxG.sound.playMusic(Paths.music('offsetSong'), 0);
                			FlxG.sound.music.fadeIn(1, 0, 0.7);
                			OptionsState.onPlayState = false;
        			}
    			});
			}

			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		menuItems.members[curSelected].screenCenter(X);

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
		menuItems.members[curSelected].screenCenter(X);

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
	}
}

package options;

import objects.GridUtil;

import states.MainMenuState;
import backend.StageData;
import states.LoadingState;

import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class OptionsState extends MusicBeatState
{
	var grid:FlxBackdrop;
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;
	
	var bpmTimer:Float = 0;
	var bpmInterval:Float = 60 / 128; // 128 BPM to match offsetSong.ogg
	var bpmCounter:Int = 0;
	var beatTriggered:Bool = false; // Prevent multiple beats per frame

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('optBG_Main'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(bg);
		LoadingState.animateUIEntry(bg, "fade", 0, 0.2);

		grid = GridUtil.createGrid();
        add(grid);
        GridUtil.fadeInGrid(grid);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);

			LoadingState.animateUIEntry(optionText, "bottom", 30, 0.6 + (i * 0.1));
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		selectorLeft.alpha = 0;
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		selectorRight.alpha = 0;
		add(selectorRight);

		FlxTween.tween(selectorLeft, {alpha: 1}, 0.4, {startDelay: 0.8, ease: FlxEase.quartOut});
		FlxTween.tween(selectorRight, {alpha: 1}, 0.4, {startDelay: 0.8, ease: FlxEase.quartOut});

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();

		LoadingState.setupMenuStateEntry(bg, cast grpOptions.members);
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		bpmTimer += elapsed;
		if (bpmTimer >= bpmInterval && !beatTriggered) {
			// Preserve excess time for better accuracy
			bpmTimer -= bpmInterval;
			bpmCounter++;
			beatTriggered = true; // Mark beat as triggered this frame
			if (bpmCounter == 2)
			{
				LoadingState.animateCameraZoom(1.05, 0.25);
			}
			if (bpmCounter >= 4)
			{
				bpmCounter = 0;
			}
		} else if (bpmTimer < bpmInterval) {
			beatTriggered = false; // Reset flag when timer is below interval
		}
		
		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else 
			{
				if (!onPlayState) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.7);
				}
				LoadingState.exitState(0.5, 0.35, function() {
					MusicBeatState.switchState(new MainMenuState());
				});
			}
			return;
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}
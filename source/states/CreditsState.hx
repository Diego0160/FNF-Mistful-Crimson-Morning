package states;

import objects.AttachedSprite;
import objects.GridUtil;
import objects.Alphabet;
import backend.StageData;
import states.PlayState;
import states.LoadingState;

import openfl.utils.Assets as OpenFlAssets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;
	var grid:FlxBackdrop;
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;
	var leaveCallback:Void->Void;
	var onPlayState:Bool = false;

	override function create()
	{
		leaveCallback = function() {
			if (colorTween != null) colorTween.cancel();
			MusicBeatState.switchState(new MainMenuState());
		}

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		Paths.music('mist-tea-time');

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('gradientDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();
		// Usar animación centralizada para el fondo
		LoadingState.animateBackgroundEntry(bg, 0.2);

		// Initialize Conductor
		Conductor.bpm = 128.0;
		FlxG.sound.playMusic(Paths.music('mist-tea-time'), 1, true);

		grid = GridUtil.createGrid();
        add(grid);
        GridUtil.fadeInGrid(grid);
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end

		var defaultList:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			['Mistful Crimson Morning\nRestored Build Extras'],
			['B_fezz',				'MCM-Extras/B_fezz',			'Director and artist of the Extras Assets of Served V2\nBF Perlita Sprite, its icons, etc...',	'https://youtube.com/channel/UCA_psctOiIibCKUgrD6UvWg',		'272d90'],
			['Nickobelit', 			'MCM-Extras/Nickobelit', 		'Coder of Restored and the BF Perlita Sprite', 													'https://youtube.com/c/Nickobelit', 						'8b0000'],
			['Sandi and END SELLA', 	'MCM-Extras/SandiYEndSella', 'Composer of Served V2', 																		'https://youtu.be/pJrJU1rr-z0', 							'8b0000'],
			[''],
			['Mistful Crimson Morning\nTeam [Old Build]'],
			['Devilous',		'no',		'Owner\nCharter',						'',		'8b0000'],
			['jredwick',		'no',		'Owner\nMain Coder\nPart Time Artist',	'',		'8b0000'],
			['Hyper',			'no',		'Director\nCharter',					'',		'8b0000'],
			['Betasheep28',		'no',		'Director\nMain Artist',		'https://twitter.com/Betasheep28',		'8b0000'],
			['Frylock',			'no',		'Coder',								'',		'8b0000'],
			['PJ9D',			'no',		'Coder',								'',		'8b0000'],
			['Anonymous',		'no',		'Coder + Additional Help',				'',		'8b0000'],
			['pattydecaffy',	'no',		'Composer',								'',		'8b0000'],
			['Olimac31',		'no',		'Composer',								'',		'8b0000'],
			['blueglue',		'no',		'Composer',								'',		'8b0000'],
			['vruzzen',			'no',		'Composer',								'',		'8b0000'],
			['CalciumLmao',		'no',		'Composer',								'',		'8b0000'],
			['Sandi',			'no',		'Composer',								'',		'8b0000'],
			['banana B)',		'no',		'Composer',								'',		'8b0000'],
			['END_SELLA',		'no',		'Composer',								'',		'8b0000'],
			['Blue',			'no',		'Composer (Snail House Creator)',		'',		'8b0000'],
			['CoolmanAJF',		'no',		'Composer\nCharter\nAssist Coder',		'',		'8b0000'],
			['FireDemonWalker',	'no',		'Artist',								'',		'8b0000'],
			['Official Unfunny Person',	'no','Artist',							'',		'8b0000'],
			['Numberless',		'no',		'Artist',								'',		'8b0000'],
			['cosmicalarcade',	'no',		'Artist',								'',		'8b0000'],
			['LuXoiD_01',		'no',		'Artist',								'',		'8b0000'],
			['XXXMickeyTesticles5480',	'no','Artist',							'',		'8b0000'],
			['Colonio',			'no',		'Artist',								'',		'8b0000'],
			['TopTophatter',	'no',		'Artist\nAnimator',						'',		'8b0000'],
			['weedeet',			'no',		'Artist',								'',		'8b0000'],
			['Gnet',			'no',		'Artist\nAnimator',						'',		'8b0000'],
			['AshyTown',		'no',		'Concept Artist',						'',		'8b0000'],
			['Nazery',			'no',		'Artist',								'',		'8b0000'],
			['Stonesteve',		'no',		'Artist',								'',		'8b0000'],
			['Manny204553',		'no',		'Artist (3D Modeler)',					'',		'8b0000'],
			['Nugget',			'no',		'Artist',								'',		'8b0000'],
			['Adam Navares',	'no',		'Artist (Joe Notes)',					'',		'8b0000'],
			['HoneyFox',		'no',		'Artist + Emotional Support',			'',		'8b0000'],
			['OstrichIsNotFunny','no',	'Charter',								'',		'8b0000'],
			['Icexglitch',		'no',		'Charter',								'',		'8b0000'],
			['skwoop',			'no',		'Charter',								'',		'8b0000'],
			['Demonic',			'no',		'Charter',								'',		'8b0000'],
			['Larry',			'no',		'Voice Actor (Squidward)',				'',		'8b0000'],
			['Banbuds',			'no',		'Voice Actor (Plakton)',				'',		'8b0000'],
			['BluBellaVA',		'no',		'Voice Actor',							'',		'8b0000'],
			['Seifo',			'no',		'Voice Actor (MC Spongebob)\nChromatic Maker',	'',	'8b0000'],
			['Crumby',			'no',		'Chromatic Maker',						'',		'8b0000'],
			['RubysArt_',		'no',		'Chromatic Maker',						'',		'8b0000'],
			[''],
			['Mistful Crimson Morning\nTeam [REBOOT]'],
			['Stonesteve',		'no',		'Owner\nDirector\nArtist\n \n"I have to do it."',					'',		'd5d5d5'],
			['VanillaaVani',	'no',		'Co-Owner\nDirector\nMusician\nArtist\n \n"live free to die lit"',	'',		'd5d5d5'],
			['CreativeLimeYT',	'no',		'Lead Musician\n \n"PLAY HIGH EFFORT TITLED BENDY MOD"',			'',		'd5d5d5'],
			['wrathstetic',		'no',		'Musician\n \n"it took 4 years, heres your sponge boy..."',			'',		'd5d5d5'],
			['Ironic0422',		'no',		'Musician\n \n"barbecue chips yumy :)"',							'',		'd5d5d5'],
			['Churgney Gurgney','no',		'Musician\n \n"Quote? oh, Okay. Hold on. $3 Baby Weed; Criminal Prosecution Deferred"',	'',		'd5d5d5'],
			['theWAHbox',		'no',		'Musician\n \n"I\'m Wahbox"',											'',		'd5d5d5'],
			['pattydecaffy',	'no',		'Musician',															'',		'd5d5d5'],
			['Grin',			'no',		'Lead Artist\n \n"I\'m on a communisty gayms video and i know what he liked on his Twitter account"',	'',		'd5d5d5'],
			['ArthurADJ',		'no',		'Lead Artist\n \n"She likes the cowboy because the playboy has no money"',	'',		'd5d5d5'],
			['ThatN003',		'no',		'Lead BG Artist\n \n"You can\'t make a That without breaking a couple N003s first."',		'',		'd5d5d5'],
			['CheezSomething',	'no',		'Lead Animator\n \n"tickles your toes as you scroll through the credits"',				'',		'd5d5d5'],
			['Crust',			'no',		'Artist\nAnimator\n \n"mny name krust, jrs etf"',					'',		'd5d5d5'],
			['BatteryBozo',		'no',		'Artist\n \n"Petscop fun facts"',									'',		'd5d5d5'],
			['FDW',				'no',		'Artist\n \n"my bestie bootytickler beef wellington is coming to get you"',	'',		'd5d5d5'],
			['BeefStarchJello',	'no',		'Artist\nAnimator\n \n"She Starch on my Beef till I Jello. Play Bald Gru... pelase..."','',		'd5d5d5'],
			['Lucky',			'no',		'Artist\nAnimator\n \n"Hiii hellooo hiii :3 Hai hai hiii ^_^ Hiiii helooo"',			'',		'd5d5d5'],
			['Mainxender',		'no',		'Artist\nAnimator\nVFX\n \n"Mulch Gang for Life"',										'',		'd5d5d5'],
			['Snootilous',		'no',		'Artist\nAnimator\n \n"his name is BIG SOGGY"',						'',		'd5d5d5'],
			['TOK',				'no',		'Artist\n \n"i just CANNOT believe THIS is my life right now <3333 WOWWWW someone PLEQSE pull the trigger <333333"',					'',		'd5d5d5'],
			['Weedeet',			'no',		'Artist\nAnimator\n \n"i kill myself spongebob its what i do"',		'',		'd5d5d5'],
			['LuigiGoons',		'no',		'Artist\nAnimator\n \n"we all scream for ice scream!!!"',			'',		'd5d5d5'],
			['Wity',			'no',		'Artist\nAnimator\n \n"Hey guys look thats me"',					'',		'd5d5d5'],
			['DuglaRaven',		'no',		'Guest Artist\n \n"We put the Chad in Chadtronic."',				'',		'd5d5d5'],
			['Rhysamath',		'no',		'Guest Animator',													'',		'd5d5d5'],
			['JoeDoughBoi',		'no',		'Guest Artist',														'',		'd5d5d5'],
			['Marketplier',		'no',		'Guest Artist',														'',		'd5d5d5'],
			['Oxanian',			'no',		'3D ModelLer\n \n"mac and cheese"',									'',		'd5d5d5'],
			['YZIO',			'no',		'3D Modeller\n \n"I am the freaky sonic guy, fear me"',				'',		'd5d5d5'],
			['AthenGem',		'no',		'Lead Coder\nVFX\nComposer\n \n"I\'m addicted to eating poop!"',	'',		'd5d5d5'],
			['LeanDapper',		'no',		'Coder\nSFX\n \n"waves HII HII HIII!"',								'',		'd5d5d5'],
			['Bromaster819',	'no',		'Coder\n \n"i bet if you press 69 a bunch in the freeplay it\'ll do something... drippy!"',	'',		'd5d5d5'],
			['StaleTide',		'no',		'Coder\n \n"that tide detergent is stale? heh, i think i like that name..."',			'',		'd5d5d5'],
			['HeroEyad',		'no',		'Coder\n \n"Be a hero."',											'',		'd5d5d5'],
			['Useraqua',		'no',		'Guest Coder',														'',		'd5d5d5'],
			['SariSorta',		'no',		'Guest Coder\n \n"hey guys it\'s sarisortago follow my gf on twitter\nboat goes binted"',	'',		'd5d5d5'],
			['Nova64',			'no',		'Lead Charter\n \n"follow the_dead_hobo64 on twitter"',				'',		'd5d5d5'],
			['TopTophatter',	'no',		'Charter\nWritter\n \n"I am the doomsday guy, I do doomsday things on this day where dooms are days, you know?"',					'',		'd5d5d5'],
			['Red3127',			'no',		'Guest Charter\n \n"sahrk"',										'',		'd5d5d5'],
			['ArtyDoesStuff',	'no',		'Writer\n \n"read dead hope"',										'',		'd5d5d5'],
			['Stash Club',		'no',		'Voice Actor\n \n"I... Am Yummer."',								'',		'd5d5d5'],
			['JakeTheDrake',	'no',		'Guest Composor\n \n"I\'m the brown guy"',							'',		'd5d5d5'],
			['Loogi',			'no',		'Guest Artist\n \n"Beware of Jungle Mitch"',						'',		'd5d5d5'],
			['GooseWeirdLol',	'no',		'Guest Artist\n \n"i\'m renaming this mod to Wistful Chimps are Boring sorry"',				'',		'd5d5d5'],
			['EOTW666',			'no',		'Guest\n \n"How can that be me when I\'m standing right here?!"',	'',		'd5d5d5'],
			[''],
			['Special Thanks'],
			['Stephen Hillenburg',		'no',		'Creator of Spongebob',				'https://en.wikipedia.org/wiki/Stephen_Hillenburg',		'F5F5DC'],
			['Jellystone',        'no',        '',                    '',        'd5d5d5'],
			['Scrilopolis',       'no',        '',                    '',        'd5d5d5'],
			['OreoMewza',         'no',        '',                    '',        'd5d5d5'],
			['Bansty',            'no',        '',                    '',        'd5d5d5'],
			['N3ps3n',            'no',        '',                    '',        'd5d5d5'],
			['Vibingleaf',        'no',        '',                    '',        'd5d5d5'],
			['Peepeemann69',      'no',        '',                    '',        'd5d5d5'],
			['KennyUndrX',        'no',        '',                    '',        'd5d5d5'],
			['Rareblin',          'no',        '',                    '',        'd5d5d5'],
			['sssprite',          'no',        '',                    '',        'd5d5d5'],
			['Marco Antonio',     'no',        '',                    '',        'd5d5d5'],
			['Lunetic Mickey',    'no',        '',                    '',        'd5d5d5'],
			['June',              'no',        '',                    '',        'd5d5d5'],
			['ducly',             'no',        '',                    '',        'd5d5d5'],
			['RedTV53',           'no',        '',                    '',        'd5d5d5'],
			['Triki-Troy',        'no',        '',                    '',        'd5d5d5'],
			['Olimac31',          'no',        '',                    '',        'd5d5d5'],
			['Albert Mation',     'no',        '',                    '',        'd5d5d5'],
			['Korean Nooby',      'no',        '',                    '',        'd5d5d5'],
			['Estrogen_Storm',    'no',        '',                    '',        'd5d5d5'],
			['Spoogynova',        'no',        '',                    '',        'd5d5d5'],
			['DuskieWhy',         'no',        '',                    '',        'd5d5d5'],
			['Ramware Broadcast', 'no',        '',                    '',        'd5d5d5'],
			['Nickelodeon',       'no',        '',                    '',        'FF6600'],
			['CNE Team',          'no',        '',                    '',        'd5d5d5'],
			[''],
			['Psych Engine Team'],
			['Shadow Mario',		'shadowmario',		'Main Programmer and Head of Psych Engine',					'https://ko-fi.com/shadowmario',		'444444'],
			['Riveren',				'riveren',			'Main Artist/Animator of Psych Engine',					 	'https://twitter.com/riverennn',		'14967B'],
			[''],
			['Former Engine Members'],
			['bb-panzu',			'bb',				'Ex-Programmer of Psych Engine',						 	'https://twitter.com/bbsub3',			'3E813A'],
			['shubs',				'',					'Ex-Programmer of Psych Engine\nI don\'t support them.',	'',									'A1A1A1'],
			[''],
			['Engine Contributors'],
			['CrowPlexus',			'crowplexus',		'Input System v3, Major Help and Other PRs',				'https://twitter.com/crowplexus',		'A1A1A1'],
			['Keoiki',				'keoiki',			'Note Splash Animations and Latin Alphabet',				'https://twitter.com/Keoiki_',			'D2D2D2'],
			['SqirraRNG',			'sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform','https://twitter.com/gedehari',			'E1843A'],
			['EliteMasterEric',		'mastereric',		'Runtime Shaders support',								 	'https://twitter.com/EliteMasterEric',	'FFBD40'],
			['PolybiusProxy',		'proxy',			'.MP4 Video Loader Library (hxCodec)',					 	'https://twitter.com/polybiusproxy',	'DCD294'],
			['Tahir',				'tahir',			'Implementing & Maintaining SScript and Other PRs',			'https://twitter.com/tahirk618',		'A04397'],
			['iFlicky',				'flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',	'https://twitter.com/flicky_i',			'9E29CF'],
			['Rozebud', 			'roze', 			'Composer of Blammed, Stress, Thorns, and many more', 		'https://twitter.com/rozebudcaps', 		'ADADAD'],
			['KadeDev',				'kade',				'Creator of Kade Engine\nFixed some issues on Chart Editor and Other PRs',	'https://twitter.com/kade0912',	'64A250'],
			['Cval',				'cval',				'Assistant Programmer',										'https://twitter.com/cval_brown',		'ADADAD'],
			['superpowers04',		'superpowers04',	'LUA JIT Fork',										 		'https://twitter.com/superpowers04',	'B957ED'],
			['CheemsAndFriends',	'face',				'Creator of FlxAnimate\n(Icon will be added later, merry christmas!)',	 'https://twitter.com/CheemsnFriendos',	'A1A1A1'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				 'https://twitter.com/ninja_muffin99',	'CF2D2D'],
			['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					 'https://twitter.com/PhantomArcade3K',	'FADC45'],
			['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					 'https://twitter.com/evilsk8r',		'5ABD4B'],
			['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					 'https://twitter.com/kawaisprite',		'378FC7']
		];
		
		for(i in defaultList) {
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 180, creditsStuff[i][0], !isSelectable); // Cambiado de 300 a 180 para menos espaciado
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);
			
			// Usar animación centralizada para las opciones de créditos
			LoadingState.animateUIEntry(optionText, "bottom", 30, 0.4 + (i * 0.05));

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Mods.currentModDirectory = creditsStuff[i][5];
				}

				var str:String = 'credits/missing_icon';
				if(creditsStuff[i][1] != null && creditsStuff[i][1].length > 0)
				{
					var fileName = 'credits/' + creditsStuff[i][1];
					if (Paths.fileExists('images/$fileName.png', IMAGE)) str = fileName;
					else if (Paths.fileExists('images/$fileName-pixel.png', IMAGE)) str = fileName + '-pixel';
				}

				var icon:AttachedSprite = new AttachedSprite(str);
				if(str.endsWith('-pixel')) icon.antialiasing = false;
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				
				// Usar animación centralizada para los iconos
				LoadingState.animateUIEntry(icon, "right", 40, 0.5 + (i * 0.05));
				Mods.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);
		
		// Usar animaciones centralizadas para el texto de descripción
		LoadingState.animateUIEntry(descBox, "bottom", 50, 1.0);
		LoadingState.animateTextEntry(descText, 0, -30, 1.1);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;
		changeSelection();
		super.create();

		LoadingState.enterState(0.5, 1.0, 0.6);
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var oldStep:Int = curStep;
		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
                FlxG.sound.play(Paths.sound('cancelMenu'));
				if(onPlayState)
				{
					StageData.loadDirectory(PlayState.SONG);
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
				}
				else 
				if (!onPlayState) {
        			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        			FlxG.sound.music.fadeIn(1, 0, 0.7);
    			}
                
                LoadingState.zoomOut("credits", function() {
                    LoadingState.fromState = "credits";
                    MusicBeatState.switchState(new MainMenuState());
                });
				quitting = true;
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = Math.exp(-elapsed * 12);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(item.x - 70, lastX, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(200 + -40 * Math.abs(item.targetY), item.x, lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;
	override public function beatHit()
	{
		super.beatHit();

		if(lastBeatHit == curBeat)
		{
			return;
		}

		if(curBeat % 4 == 2)
		{
			FlxG.camera.zoom = 1.15;

			if(zoomTween != null) zoomTween.cancel();
			zoomTween = FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
				{
					zoomTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		//trace('The BG color is: $newColor');
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				item.color = FlxColor.GRAY;
				if (item.targetY == 0) {
					item.alpha = 1;
					item.color = FlxColor.WHITE;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (OpenFlAssets.exists(creditsFile))
		{
			var firstarray:Array<String> = Paths.getTextFromFile(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
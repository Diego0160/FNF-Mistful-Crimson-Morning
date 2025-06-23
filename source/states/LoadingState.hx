package states;

import lime.app.Promise;
import lime.app.Future;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import backend.StageData;

import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;
	public static var currentZoom:Float = 1.0;
	public static var fromState:String = "";
	private static var fadeOverlay:FlxSprite;
	
	var target:FlxState;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	var targetShit:Float = 0;

	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	var funkay:FlxSprite;
	var loadBar:FlxSprite;
	override function create()
	{
		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		funkay = new FlxSprite(0, 0).loadGraphic(Paths.getPath('images/funkay.png', IMAGE));
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		add(funkay);
		funkay.antialiasing = ClientPrefs.data.antialiasing;
		funkay.scrollFactor.set();
		funkay.screenCenter();

		loadBar = new FlxSprite(0, FlxG.height - 20).makeGraphic(FlxG.width, 10, 0xffff16d2);
		loadBar.screenCenter(X);
		add(loadBar);
		
		initSongsManifest().onComplete
		(
			function (lib)
			{
				callbacks = new MultiCallback(onLoad);
				var introComplete = callbacks.add("introComplete");
				if (PlayState.SONG != null) {
					checkLoadSong(getSongPath());
					if (PlayState.SONG.needsVoices)
						checkLoadSong(getVocalPath());
				}
				if(directory != null && directory.length > 0 && directory != 'shared') {
					checkLibrary('week_assets');
				}

				var fadeTime = 0.5;
				FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
				new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
			}
		);
	}
	
	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function (_) { callback(); });
		}
	}
	
	function checkLibrary(library:String) {
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw new haxe.Exception("Missing library: " + library);

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function (_) { callback(); });
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		funkay.setGraphicSize(Std.int(0.88 * FlxG.width + 0.9 * (funkay.width - 0.88 * FlxG.width)));
		funkay.updateHitbox();
		if(controls.ACCEPT)
		{
			funkay.setGraphicSize(Std.int(funkay.width + 60));
			funkay.updateHitbox();
		}

		if(callbacks != null) {
			targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);
			loadBar.scale.x += 0.5 * (targetShit - loadBar.scale.x);
		}
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		MusicBeatState.switchState(target);
	}
	
	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}
	
	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;

		if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

		Paths.setCurrentLevel(directory);
		trace('Setting asset folder to ' + directory);

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}
	
	override function destroy()
	{
		super.destroy();
		callbacks = null;
	}
	
	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}

	public static function zoomOut(from:String, onComplete:Void->Void)
	{
		createFadeOverlay();
		fadeOverlay.alpha = 0;
		FlxG.state.add(fadeOverlay);
		FlxTween.tween(FlxG.camera, {
			zoom: 0.5,
			alpha: 0
		}, 0.5, {
			ease: FlxEase.quadIn,
			onComplete: function(_) {
				currentZoom = 0.5;
				fromState = from;
				destroyFadeOverlay();
				onComplete();
			}
		});
	}

	public static function zoomIn(?onComplete:Void->Void)
	{
		FlxG.camera.zoom = currentZoom;
		FlxG.camera.alpha = 0;
		FlxTween.tween(FlxG.camera, {
			zoom: 1.0,
			alpha: 1
		}, 0.35, {
			ease: FlxEase.quadOut,
			onComplete: function(_) {
				if (onComplete != null) onComplete();
			}
		});
	}

	public static function enterState(initialZoom:Float = 0.5, targetZoom:Float = 1.0, duration:Float = 0.6)
	{
		createFadeOverlay();
		fadeOverlay.alpha = 0;
		FlxG.state.add(fadeOverlay);
		FlxG.camera.zoom = initialZoom;
		FlxG.camera.alpha = 1;
		destroyFadeOverlay();
		FlxTween.tween(FlxG.camera, {
			zoom: targetZoom
		}, duration, {
			ease: FlxEase.quadOut
		});
	}
	
	public static function exitState(targetZoom:Float = 0.5, duration:Float = 0.35, onComplete:Void->Void = null)
	{
		createFadeOverlay();
		fadeOverlay.alpha = 0;
		FlxG.state.add(fadeOverlay);
		
		FlxTween.tween(fadeOverlay, {alpha: 1}, duration * 0.5, {ease: FlxEase.quadIn});
		FlxTween.tween(FlxG.camera, {
			zoom: targetZoom
		}, duration, {
			ease: FlxEase.quadIn,
			onComplete: function(_) {
				destroyFadeOverlay();
				if (onComplete != null) onComplete();
			}
		});
	}
	
	public static function resetZoom()
	{
		FlxG.camera.zoom = 1.0;
		FlxG.camera.alpha = 1.0;
		currentZoom = 1.0;
	}
	
	// ===== SISTEMA CENTRALIZADO DE ANIMACIONES Y TRANSICIONES =====
	
	/**
	 * Animaciones de entrada para fondos
	 */
	public static function animateBackgroundEntry(bg:FlxSprite, ?delay:Float = 0.2, ?duration:Float = 0.8)
	{
		bg.alpha = 0;
		bg.scale.set(1.1, 1.1);
		FlxTween.tween(bg, {alpha: 1}, duration, {ease: FlxEase.quadOut, startDelay: delay});
		FlxTween.tween(bg.scale, {x: 1, y: 1}, duration + 0.2, {ease: FlxEase.quadOut, startDelay: delay});
	}
	
	/**
	 * Animaciones de entrada para texto con efecto de rebote
	 */
	public static function animateTextEntry(text:FlxSprite, ?offsetX:Float = 0, ?offsetY:Float = 0, ?delay:Float = 0.6)
	{
		text.alpha = 0;
		var originalX = text.x;
		var originalY = text.y;
		text.x += offsetX;
		text.y += offsetY;
		FlxTween.tween(text, {alpha: 1, x: originalX, y: originalY}, 0.6, {ease: FlxEase.backOut, startDelay: delay});
	}
	
	/**
	 * Animaciones escalonadas para elementos de menú
	 */
	public static function animateMenuItems(items:Array<FlxSprite>, ?baseDelay:Float = 0.5, ?itemDelay:Float = 0.1)
	{
		for (i in 0...items.length) {
			var item = items[i];
			item.alpha = 0;
			var originalX = item.x;
			item.x -= 100;
			FlxTween.tween(item, {alpha: 1, x: originalX}, 0.6, {
				ease: FlxEase.backOut, 
				startDelay: baseDelay + (i * itemDelay)
			});
		}
	}
	
	/**
	 * Efecto de pulsación para elementos interactivos
	 */
	public static function animatePulse(sprite:FlxSprite, ?scale:Float = 1.05, ?duration:Float = 1.5)
	{
		FlxTween.tween(sprite.scale, {x: scale, y: scale}, duration, {
			ease: FlxEase.sineInOut, 
			type: PINGPONG
		});
	}
	
	/**
	 * Efecto de flotación para elementos decorativos
	 */
	public static function animateFloat(sprite:FlxSprite, ?offsetY:Float = 10, ?duration:Float = 2.5)
	{
		var originalY = sprite.y;
		FlxTween.tween(sprite, {y: originalY + offsetY}, duration, {
			ease: FlxEase.sineInOut, 
			type: PINGPONG
		});
	}
	
	/**
	 * Animación de entrada elástica para logos
	 */
	public static function animateLogoEntry(logo:FlxSprite, ?delay:Float = 0.3, ?offsetY:Float = 50)
	{
		logo.alpha = 0;
		var originalY = logo.y;
		logo.y -= offsetY;
		FlxTween.tween(logo, {alpha: 1, y: originalY}, 1.2, {
			ease: FlxEase.elasticOut, 
			startDelay: delay
		});
	}
	
	/**
	 * Efecto de escala para botones al hacer hover/click
	 */
	public static function animateButtonPress(button:FlxSprite, ?onComplete:Void->Void)
	{
		FlxTween.tween(button.scale, {x: 1.2, y: 1.2}, 0.1, {
			ease: FlxEase.quadOut, 
			onComplete: function(twn:FlxTween) {
				FlxTween.tween(button.scale, {x: 1, y: 1}, 0.2, {
					ease: FlxEase.backOut,
					onComplete: function(_) if (onComplete != null) onComplete()
				});
			}
		});
	}
	
	/**
	 * Zoom de cámara suave para navegación
	 */
	public static function animateCameraZoom(?targetZoom:Float = 1.05, ?duration:Float = 0.3)
	{
		FlxTween.cancelTweensOf(FlxG.camera);
		FlxTween.tween(FlxG.camera, {zoom: targetZoom}, duration, {ease: FlxEase.quadOut});
		FlxTween.tween(FlxG.camera, {zoom: 1}, duration, {ease: FlxEase.quadOut, startDelay: duration});
	}
	
	/**
	 * Transición de color suave para fondos
	 */
	public static function animateColorTransition(sprite:FlxSprite, targetColor:Int, ?duration:Float = 1.0, ?onComplete:Void->Void):FlxTween
	{
		return FlxTween.color(sprite, duration, sprite.color, targetColor, {
			onComplete: function(twn:FlxTween) {
				if (onComplete != null) onComplete();
			}
		});
	}
	
	/**
	 * Animación de entrada para elementos de UI con fade y movimiento
	 */
	public static function animateUIEntry(element:FlxSprite, ?direction:String = "bottom", ?distance:Float = 26, ?delay:Float = 0.0)
	{
		element.alpha = 0;
		var originalX = element.x;
		var originalY = element.y;
		
		switch (direction) {
			case "top":
				element.y -= distance;
			case "bottom":
				element.y += distance;
			case "left":
				element.x -= distance;
			case "right":
				element.x += distance;
		}
		
		FlxTween.tween(element, {alpha: 1, x: originalX, y: originalY}, 0.5, {
			ease: FlxEase.backOut, 
			startDelay: delay
		});
	}
	
	/**
	 * Efecto de entrada coordinada para múltiples elementos
	 */
	public static function animateCoordinatedEntry(elements:Array<{sprite:FlxSprite, delay:Float, ?direction:String, ?distance:Float}>)
	{
		for (element in elements) {
			animateUIEntry(
				element.sprite, 
				element.direction != null ? element.direction : "bottom",
				element.distance != null ? element.distance : 26,
				element.delay
			);
		}
	}
	
	/**
	 * Animación de salida suave para elementos
	 */
	public static function animateExit(sprite:FlxSprite, ?direction:String = "fade", ?duration:Float = 0.3, ?onComplete:Void->Void)
	{
		switch (direction) {
			case "fade":
				FlxTween.tween(sprite, {alpha: 0}, duration, {
					ease: FlxEase.quadOut,
					onComplete: function(_) if (onComplete != null) onComplete()
				});
			case "scale":
				FlxTween.tween(sprite.scale, {x: 0, y: 0}, duration, {
					ease: FlxEase.backIn,
					onComplete: function(_) if (onComplete != null) onComplete()
				});
			case "slide":
				FlxTween.tween(sprite, {x: sprite.x - 100, alpha: 0}, duration, {
					ease: FlxEase.quadIn,
					onComplete: function(_) if (onComplete != null) onComplete()
				});
		}
	}
	
	/**
	 * Efecto de transición de imagen de fondo
	 */
	public static function animateBackgroundTransition(bgSprite:FlxSprite, newImagePath:String, ?onComplete:Void->Void)
	{
		FlxTween.tween(bgSprite, {alpha: 0}, 0.2, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween) {
				bgSprite.loadGraphic(Paths.image(newImagePath));
				FlxTween.tween(bgSprite, {alpha: 1}, 0.3, {
					ease: FlxEase.quadOut,
					onComplete: function(_) if (onComplete != null) onComplete()
				});
			}
		});
	}
	
	/**
	 * Configuración de entrada estándar para estados de menú
	 */
	public static function setupMenuStateEntry(bg:FlxSprite, ?elements:Array<FlxSprite>)
	{
		// Animar fondo
		animateBackgroundEntry(bg);
		
		// Animar elementos si se proporcionan
		if (elements != null) {
			animateMenuItems(elements);
		}
		
		// Zoom inicial de cámara
		enterState();
	}
	
	// ===== FUNCIONES AUXILIARES =====
	
	private static function createFadeOverlay()
	{
		fadeOverlay = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		fadeOverlay.scrollFactor.set();
		fadeOverlay.screenCenter();
	}
	
	private static function destroyFadeOverlay()
	{
		if (fadeOverlay != null) {
			fadeOverlay.destroy();
			fadeOverlay = null;
		}
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();
	
	public function new (callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function ()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;
				
				if (logId != null)
					log('fired $id, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}
	
	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired() return fired.copy();
	public function getUnfired() return [for (id in unfired.keys()) id];
}
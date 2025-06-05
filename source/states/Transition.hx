package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class Transition
{
    public static var currentZoom:Float = 1.0;
    public static var fromState:String = "main";
    private static var fadeOverlay:FlxSprite;
    
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
    
    public static function zoomIn(to:String, onComplete:Void->Void = null)
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
        destroyFadeOverlay(); // Eliminamos el overlay antes del tween
        FlxTween.tween(FlxG.camera, {
            zoom: targetZoom
        }, duration, {
            ease: FlxEase.quadIn,
            onComplete: function(_) {
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
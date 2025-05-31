package objects;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class GridUtil {
    public static function createGrid():FlxBackdrop {
        var grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
        grid.velocity.set(40, 40);
        grid.alpha = 0;
        return grid;
    }

    public static function fadeInGrid(grid:FlxBackdrop):Void {
        FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
    }
}
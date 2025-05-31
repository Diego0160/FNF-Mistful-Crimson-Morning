// CustomMenuButton.hx
package objects;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;

class CustomMenuButton extends FlxSpriteGroup
{
    public var background:FlxSprite;
    public var text:FlxText;
    public var callback:Void->Void;
    public var targetPosition:FlxPoint = FlxPoint.get();
    
    public function new(X:Float = 0, Y:Float = 0, Label:String, Callback:Void->Void)
    {
        super(X, Y);
        callback = Callback;
        
        // Crear fondo del botón
        background = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
        background.scale.set(140, 40); // Tamaño reducido a la mitad
        background.updateHitbox();
        background.color = 0xFF333333;
        background.alpha = 0.8;
        add(background);
        
        // Crear texto del botón
        text = new FlxText(0, 0, 0, Label, 16);
        text.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
        text.borderStyle = OUTLINE;
        text.borderColor = FlxColor.BLACK;
        text.borderSize = 1.5;
        text.screenCenter();
        add(text);
        
        // Configurar posición objetivo
        targetPosition.set(x, y);
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // Suavizar movimiento hacia la posición objetivo
        x = FlxMath.lerp(x, targetPosition.x, 0.2);
        y = FlxMath.lerp(y, targetPosition.y, 0.2);
    }
    
    public function setTargetPosition(X:Float, Y:Float):Void
    {
        targetPosition.set(X, Y);
    }
    
    override public function destroy():Void
    {
        super.destroy();
        targetPosition.put();
    }
}
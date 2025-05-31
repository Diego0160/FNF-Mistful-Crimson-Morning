// ChessboardBackground.hx
package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;

class ChessboardBackground extends FlxSprite
{
    // Cambiar a públicos los campos de velocidad
    public var scrollSpeedX:Float;
    public var scrollSpeedY:Float;
    
    private var tileSize:Int;
    private var color1:FlxColor;
    private var color2:FlxColor;
    
    public function new(tileSize:Int = 50, color1:FlxColor = 0xFF222222, color2:FlxColor = 0xFF444444)
    {
        super(0, 0);
        this.tileSize = tileSize;
        this.color1 = color1;
        this.color2 = color2;
        
        // Valores por defecto (públicos)
        this.scrollSpeedX = 10;
        this.scrollSpeedY = 5;
        
        // Crear una textura de patrón de ajedrez
        createChessPattern();
    }
    
    private function createChessPattern()
    {
        // Tamaño del patrón base (2x2 tiles)
        var patternWidth = tileSize * 2;
        var patternHeight = tileSize * 2;
        
        // Crear sprite para el patrón base
        var pattern = new FlxSprite();
        pattern.makeGraphic(patternWidth, patternHeight, FlxColor.TRANSPARENT);
        
        // Dibujar cuadrados
        FlxSpriteUtil.drawRect(pattern, 0, 0, tileSize, tileSize, color1);
        FlxSpriteUtil.drawRect(pattern, tileSize, 0, tileSize, tileSize, color2);
        FlxSpriteUtil.drawRect(pattern, 0, tileSize, tileSize, tileSize, color2);
        FlxSpriteUtil.drawRect(pattern, tileSize, tileSize, tileSize, tileSize, color1);
        
        // Crear gráfico repetible (más grande que la pantalla)
        var width = FlxG.width * 2;
        var height = FlxG.height * 2;
        
        // Crear el fondo completo
        makeGraphic(width, height, FlxColor.TRANSPARENT);
        
        // Rellenar con el patrón
        for (x in 0...Math.ceil(width / patternWidth) + 1)
        {
            for (y in 0...Math.ceil(height / patternHeight) + 1)
            {
                stamp(pattern, x * patternWidth, y * patternHeight);
            }
        }
        
        // Limpiar memoria
        pattern.destroy();
        
        // Configuración inicial
        scrollFactor.set(0.1, 0.05);
        updateHitbox();
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        // Movimiento sutil
        x = (x - scrollSpeedX * elapsed) % (tileSize * 2);
        y = (y - scrollSpeedY * elapsed * 0.5) % (tileSize * 2);
    }
}
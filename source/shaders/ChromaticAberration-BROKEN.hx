package shaders;

import openfl.Lib;
import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

class ChromaticAberration 
{
    public var shader:ChromaticAberrationShader = new ChromaticAberrationShader();
    public function new(?fuckSample2D:Dynamic) 
    {
        shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
        shader.iTime.value = [0];
        shader.iMouse.value = [0];
        shader.iChannel0 = fuckSample2D;
    }

    public function update(elapsed:Float){
        shader.iTime.value[0] += elapsed;
        shader.iResolution.value = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
    }
}


class ChromaticAberrationShader extends FlxShader 
{
    @:glFragmentSource('
        #pragma header

        uniform vec3 iResolution;
        uniform float iTime;                 
        uniform vec4 iMouse;    
        uniform sampler2D iChannel0;       

        void mainImage( out vec4 O,  vec2 U )
        {
            vec2 R = iResolution.xy, m = iMouse.xy/R; 
            U/= R;
            float d = (length(m)<.02) ? .015 : m.x/10.;
            //float d = (length(m)<.02) ? .05-.05*cos(iDate.w) : m.x/10.;
        
            O = vec4(
                    texture2D(iChannel0,U-d).x,
                    texture2D(iChannel0,U  ).x,
                    texture2D(iChannel0,U+d).x,1);

            // O = flixel_texture2D(bitmap,look);
        }
    ')
    public function new() 
    {
        super();
    }
}
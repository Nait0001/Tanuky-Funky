function onCreate()
end

jumpHudBool = false
zoomFuck = 0.05
breakBeat = 1
function onBeatHit()
    if (jumpHudBool) then
        if (curBeat % breakBeat == 0) then
            jumpedHud()

            breakBeatPenis = breakBeat*2
            if (curBeat % breakBeatPenis == 0) then
                triggerEvent('Add Camera Zoom',0,zoomFuck)
            end        
        end
    end
end

function onEvent(n,v1,v2)
    if n == 'Events' then
        if (v1 == 'hud' or v1 == 'hud') then
            jumpHudBool = not jumpHudBool
        end
    end
end

jumpHud = false

intensity = 1
function jumpedHud()
    jumpHud = not jumpHud

    -- angle --
    angleHud = intensity*2
    timeTween = 0.3
    easeTween = 'backOut'
    -- tween y --
    yHud = intensity*15
    timeTweenY = 0.5
    -- cam gam --

    ----------------

    if (jumpHud) then 
        angleHud = -angleHud 
        yHud = -yHud
    end

    triggerEvent('Add Camera Zoom')

    -- debugPrint(angleHud)

    setProperty('camHUD.angle', angleHud)
    setProperty('camGame.angle', -angleHud/2)
    setProperty('camHUD.y', yHud)


    cancelTween('camHUD_ANGLE')
    cancelTween('camGAME_ANGLE')
    cancelTween('camHUD_Y')

    doTweenAngle('camHUD_ANGLE', 'camHUD', 0, timeTween,easeTween)
    doTweenAngle('camGAME_ANGLE', 'camGame', 0, timeTween,easeTween)
    doTweenY('camHUD_Y', 'camHUD', 0, timeTweenY,easeTween)
end
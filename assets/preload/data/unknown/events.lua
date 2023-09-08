

function onEvent(n,v1)
    if n == 'Events' then
        if v1 == 'light' then
            makeLuaSprite('shine', 'bg/nuky/shiny', -970, -800);
            setScrollFactor('shine', 0.8, 0.8);
            scaleObject('shine', 1.3, 1.3);
            addLuaSprite('shine', true);
            setScrollFactor('shine', 1.5,1.5)

            doTweenX('shyni move', 'shine', getProperty('shine.x')-100, 120+14)
        end
    end
end
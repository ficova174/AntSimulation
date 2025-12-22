#pragma once

#include <SDL3/SDL.h>
#include "map.h"

class Viewport {
public:
    float getZoomSpeed() const {return m_zoomSpeed;}
    SDL_FRect getViewport() const {return m_viewport;}
    float getZoomFactor(float viewportChangeX) {return m_viewport.w / (m_viewport.w + viewportChangeX);}

    void setCoordinates(Map map, float x, float y);
    void setSize(Map map, float w, float h);

    void zoom(Map map, float changex, float changey, float aspectRatio);
    void move(Map map, const bool *keys, float deltaTime);

private:
    SDL_FRect m_viewport;
    static constexpr float m_viewportSpeed{500.0f};
    static constexpr float m_zoomSpeed{3.0e3};
};

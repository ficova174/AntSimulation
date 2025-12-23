#pragma once

#include <SDL3/SDL.h>
#include "map.h"

class Viewport {
public:
    float getZoomSpeed() const {return m_zoomSpeed;}
    SDL_FRect getViewport() const {return m_viewport;}
    float getZoomFactor(float viewportChangeX) const;

    void setCoordinates(const Map &map, float x, float y);
    void setSize(const Map &map, float w, float h);

    void zoom(const Map &map, float changex, float changey);
    void move(const Map &map, const bool *keys, float deltaTime);

private:
    SDL_FRect m_viewport{0.0f, 0.0f, 0.0f, 0.0f};
    static constexpr float m_viewportSpeed{500.0f};
    static constexpr float m_zoomSpeed{30.0f};
};

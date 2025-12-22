#pragma once

#include <SDL3/SDL.h>

class Viewport {
public:
    float getZoomSpeed() const {return m_zoomSpeed;}
    SDL_FRect getViewport() const {return m_viewport;}

    void setCoordinates(float x, float y);
    void setSize(float w, float h);

    void zoom(float changex, float changey);
    void move(const bool *keys, float deltaTime);

private:
    SDL_FRect m_viewport;
    constexpr float m_viewportSpeed{500.0f};
    constexpr float m_zoomSpeed{3.0e3};
};

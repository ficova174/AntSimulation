#pragma once

#include <SDL3/SDL.h>

class Ant {
public:
    Ant();
    ~Ant();

    SDL_Texture* getTexture() const {return m_texture;}
    float getDirection() const {return m_direction;}
    SDL_FRect getAntViewport() const {return m_viewport;}

    void setCoordinates(float x, float y);
    
    void zoom(float factor);
    void move(const bool *keys, float deltaTime);
    void render(SDL_FRect gameViewport);

private:
    SDL_Texture *m_texture{nullptr};
    SDL_FRect m_ant;
    SDL_FRect m_viewport;
    constexpr float m_speed{150.0f};
    constexpr float m_dashFactor{1.5f};
    float m_direction{0.0f};
    constexpr float m_rotationSpeed{300.0f};
};

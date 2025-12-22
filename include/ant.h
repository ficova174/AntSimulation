#pragma once

#include <SDL3/SDL.h>
#include "map.h"

class Ant {
public:
    ~Ant();

    SDL_Texture* getTexture() const {return m_texture;}
    float getDirection() const {return m_direction;}
    SDL_FRect getAntViewport() const {return m_viewport;}

    void setCoordinates(Map map, float x, float y);
    
    void init(SDL_Renderer *renderer);
    void zoom(Map map, float factor);
    void move(Map map, const bool *keys, float deltaTime);
    void render(SDL_Renderer *renderer, SDL_FRect gameViewport);

private:
    SDL_Texture *m_texture{nullptr};
    SDL_FRect m_ant;
    SDL_FRect m_viewport;
    static constexpr float m_speed{150.0f};
    static constexpr float m_dashFactor{1.5f};
    float m_direction{0.0f};
    static constexpr float m_rotationSpeed{300.0f};
};

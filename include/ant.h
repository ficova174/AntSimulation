#pragma once

#include <SDL3/SDL.h>
#include "map.h"

class Ant {
public:
    ~Ant();

    SDL_Texture* getTexture() const {return m_texture;}
    SDL_FRect getAntViewport() const {return m_viewport;}

    void setCoordinates(const Map &map, float x, float y);
    
    void init(SDL_Renderer *renderer);
    void move(const Map &map, const bool *keys, float deltaTime);
    void render(SDL_Renderer *renderer, SDL_FRect gameViewport, float screenWidth);

private:
    SDL_Texture *m_texture{nullptr};
    SDL_FRect m_ant{0.0f, 0.0f, 0.0f, 0.0f};
    SDL_FRect m_viewport{0.0f, 0.0f, 0.0f, 0.0f};
    static constexpr float m_speed{150.0f};
    static constexpr float m_dashFactor{1.5f};
    double m_direction{0.0};
    static constexpr float m_rotationSpeed{300.0f};
};

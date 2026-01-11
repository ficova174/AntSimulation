#pragma once

#include <SDL3/SDL.h>
#include "map.h"
#include "nest.h"

class Ant {
public:
    ~Ant();

    void setCoordinates(const Map &map, float x, float y);
    
    bool init(const Nest &nest, SDL_Renderer *renderer);
    void move(const Map &map, const float deltaTime);
    void render(SDL_Renderer *renderer, SDL_FRect gameViewport, const float screenWidth);

private:
    SDL_Texture *m_texture{nullptr};
    SDL_FRect m_ant{0.0f, 0.0f, 0.0f, 0.0f};
    SDL_FRect m_viewport{0.0f, 0.0f, 0.0f, 0.0f};
    static constexpr float m_speed{150.0f};
    float m_direction{0.0f};
    static constexpr float m_rotationSpeed{300.0f};
};

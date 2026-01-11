#pragma once

#include <SDL3/SDL.h>
#include "map.h"

class Nest {
public:
    ~Nest();

    SDL_FRect getCoordinates() const {return m_nest;}

    void setCoordinates(const Map& map, float x, float y);
    
    bool init(const Map& map, SDL_Renderer *renderer);
    void render(SDL_Renderer *renderer, SDL_FRect gameViewport, float screenWidth);

private:
    SDL_Texture *m_texture{nullptr};
    SDL_FRect m_nest{0.0f, 0.0f, 0.0f, 0.0f};
    SDL_FRect m_viewport{0.0f, 0.0f, 0.0f, 0.0f};
};

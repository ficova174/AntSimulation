#pragma once

#include <SDL3/SDL.h>

class Map {
public:
    ~Map();

    float getWidth() const {return w;}
    float getHeight() const {return h;}

    void init(SDL_Renderer *renderer);
    void render(SDL_Renderer *renderer, SDL_FRect gameViewport);

private:
    SDL_Texture *m_texture{nullptr};
    float w{0.0f};
    float h{0.0f};
};

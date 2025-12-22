#pragma once

#include <SDL3/SDL.h>

class Map {
public:
    Map();
    ~Map();

    float getWidth() const {return w;}
    float getHeight() const {return h;}
    SDL_Texture* getTexture() const {return m_texture;}

    void render(SDL_FRect gameViewport);

private:
    SDL_Texture *m_texture{nullptr};
    float w{0.0f};
    float h{0.0f};
};

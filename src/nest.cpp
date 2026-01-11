#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include <algorithm>
#include "nest.h"

Nest::~Nest() {
    SDL_DestroyTexture(m_texture);
}

void Nest::setCoordinates(const Map &map, float x, float y) {
    m_nest.x = x;
    m_nest.y = y;

    m_nest.x = std::clamp(m_nest.x, 0.0f, map.getWidth() - m_nest.w);
    m_nest.y = std::clamp(m_nest.y, 0.0f, map.getHeight() - m_nest.h);
}

bool Nest::init(const Map& map, SDL_Renderer *renderer) {
    m_texture = IMG_LoadTexture(renderer, "../assets/nest.png");

    if (!m_texture) {
        SDL_Log("Failed to load nest texture: %s", SDL_GetError());
        return false;
    }

    if (!SDL_GetTextureSize(m_texture, &m_nest.w, &m_nest.h)) {
        SDL_Log("Failed to get nest size: %s", SDL_GetError());
        return false;
    }

    m_nest.x = map.getWidth() / 2.0f;
    m_nest.y = map.getHeight() / 2.0f;

    return true;
}

void Nest::render(SDL_Renderer *renderer, SDL_FRect gameViewport, float screenWidth) {
    float scale = screenWidth / gameViewport.w;

    m_viewport.x = (m_nest.x - gameViewport.x) * scale;
    m_viewport.y = (m_nest.y - gameViewport.y) * scale;

    m_viewport.w = m_nest.w * scale;
    m_viewport.h = m_nest.h * scale;

    bool conditionX{m_nest.x + m_nest.w < gameViewport.x || m_nest.x > gameViewport.x + gameViewport.w};
    bool conditionY{m_nest.y + m_nest.h < gameViewport.y || m_nest.y > gameViewport.y + gameViewport.h};

    if (!conditionX && !conditionY) {
        if (!SDL_RenderTexture(renderer, m_texture, nullptr, &m_viewport)) {
            SDL_Log("Failed to render the nest: %s", SDL_GetError());
        }
    }
}

#include "nest.h"

Nest::~Nest() {
    SDL_DestroyTexture(m_texture);
}

void Nest::init(SDL_Renderer *renderer) {
    m_texture = IMG_LoadTexture(renderer, "../assets/nest.png");

    if (!m_texture) {
        SDL_Log("Failed to load nest texture: %s", SDL_GetError());
        return;
    }

    if (!SDL_GetTextureSize(m_texture, &m_nest.w, &m_nest.h)) {
        SDL_Log("Failed to get nest size: %s", SDL_GetError());
        return;
    }

    m_nest.x = 0.0f;
    m_nest.y = 0.0f;

    m_viewport.w = m_nest.w;
    m_viewport.h = m_nest.h;
}

void Ant::setCoordinates(const Map &map, float x, float y) {
    m_ant.x = x;
    m_ant.y = y;

    m_ant.x = std::clamp(m_ant.x, 0.0f, map.getWidth() - m_ant.w);
    m_ant.y = std::clamp(m_ant.y, 0.0f, map.getHeight() - m_ant.h);
}

void Ant::render(SDL_Renderer *renderer, SDL_FRect gameViewport, float screenWidth) {
    float scale = screenWidth / gameViewport.w;

    m_viewport.x = (m_ant.x - gameViewport.x) * scale;
    m_viewport.y = (m_ant.y - gameViewport.y) * scale;
    m_viewport.w = m_ant.w * scale;
    m_viewport.h = m_ant.h * scale;

    bool conditionX{m_ant.x + m_ant.w < gameViewport.x || m_ant.x > gameViewport.x + gameViewport.w};
    bool conditionY{m_ant.y + m_ant.h < gameViewport.y || m_ant.y > gameViewport.y + gameViewport.h};

    if (!conditionX && !conditionY) {
        if (!SDL_RenderTextureRotated(renderer, m_texture, nullptr, &m_viewport, m_direction, nullptr, SDL_FLIP_NONE)) {
            SDL_Log("Failed to render the ant: %s", SDL_GetError());
        }
    }
}

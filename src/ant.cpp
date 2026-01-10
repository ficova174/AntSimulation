#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include <cmath>
#include <algorithm>
#include "ant.h"

Ant::~Ant() {
    SDL_DestroyTexture(m_texture);
}

void Ant::setCoordinates(const Map &map, float x, float y) {
    m_ant.x = x;
    m_ant.y = y;

    m_ant.x = std::clamp(m_ant.x, 0.0f, map.getWidth() - m_ant.w);
    m_ant.y = std::clamp(m_ant.y, 0.0f, map.getHeight() - m_ant.h);
}

void Ant::init(SDL_Renderer *renderer) {
    m_texture = IMG_LoadTexture(renderer, "../assets/ant.png");

    if (!m_texture) {
        SDL_Log("Failed to load ant texture: %s", SDL_GetError());
        return;
    }

    if (!SDL_GetTextureSize(m_texture, &m_ant.w, &m_ant.h)) {
        SDL_Log("Failed to get ant size: %s", SDL_GetError());
        return;
    }
}

void Ant::move(const Map &map, const bool *keys, float deltaTime) {
    float angleChange{m_rotationSpeed * deltaTime};

    if (keys[SDL_SCANCODE_Q]) {
        m_direction -= (m_direction > -360.0) ? angleChange : -360.0 + angleChange;
    }
    if (keys[SDL_SCANCODE_E]) {
        m_direction += (m_direction < 360.0) ? angleChange : -360.0 + angleChange;
    }

    m_ant.x += m_speed * std::cos(m_direction * M_PI / 180.0) * deltaTime;
    m_ant.y += m_speed * std::sin(m_direction * M_PI / 180.0) * deltaTime;

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

#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include <cmath>
#include <algorithm>
#include <cstdlib>
#include "nest.h"
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

bool Ant::init(const Nest& nest, SDL_Renderer *renderer) {
    m_texture = IMG_LoadTexture(renderer, "../assets/ant.png");

    if (!m_texture) {
        SDL_Log("Failed to load ant texture: %s", SDL_GetError());
        return false;
    }

    if (!SDL_GetTextureSize(m_texture, &m_ant.w, &m_ant.h)) {
        SDL_Log("Failed to get ant size: %s", SDL_GetError());
        return false;
    }
    
    m_ant.x = (nest.getCoordinates()).x;
    m_ant.y = (nest.getCoordinates()).y;

    return true;
}

void Ant::move(const Map &map, const float deltaTime) {
    float maxValue{2.0f};
    // Random number between -1.0f and 1.0f
    float randomChange = (static_cast<float>(rand()) / (static_cast<float>(RAND_MAX/maxValue)) - 1.0f);
    float angleChange{m_rotationSpeed * randomChange * deltaTime};

    m_direction += angleChange;

    // We want to avoid floating-point overflow
    // No chance to do more than one turn over one frame thanks to m_rotationSpeed
    if (m_direction <= -360.0f) {
        m_direction += 360.0f;
    }
    else if (m_direction >= 360.f) {
        m_direction -= 360.f;
    }

    m_ant.x += m_speed * std::cos(m_direction * M_PI / 180.0f) * deltaTime;
    m_ant.y += m_speed * std::sin(m_direction * M_PI / 180.0f) * deltaTime;

    m_ant.x = std::clamp(m_ant.x, 0.0f, map.getWidth() - m_ant.w);
    m_ant.y = std::clamp(m_ant.y, 0.0f, map.getHeight() - m_ant.h);
}

void Ant::render(SDL_Renderer *renderer, SDL_FRect gameViewport, const float screenWidth) {
    float scale = screenWidth / gameViewport.w;

    m_viewport.x = (m_ant.x - gameViewport.x) * scale;
    m_viewport.y = (m_ant.y - gameViewport.y) * scale;
    m_viewport.w = m_ant.w * scale;
    m_viewport.h = m_ant.h * scale;

    bool conditionX{m_ant.x + m_ant.w < gameViewport.x || m_ant.x > gameViewport.x + gameViewport.w};
    bool conditionY{m_ant.y + m_ant.h < gameViewport.y || m_ant.y > gameViewport.y + gameViewport.h};

    if ((!conditionX) && (!conditionY)) {
        if (!SDL_RenderTextureRotated(renderer, m_texture, nullptr, &m_viewport, static_cast<double>(m_direction), nullptr, SDL_FLIP_NONE)) {
            SDL_Log("Failed to render the ant: %s", SDL_GetError());
        }
    }
}

#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include <cmath>
#include <algorithm>
#include "ant.h"

Ant::Ant() {
    m_texture = IMG_LoadTexture(Game::renderer, "../assets/ant.png");
    SDL_GetTextureSize(m_texture, &w, &h);
    m_ants.x = 0.0f;
    m_ants.y = 0.0f;
}

Ant::~Ant() {
    SDL_DestroyTexture(m_texture);
}

void setCoordinates(float x, float y) {
    m_ant.x = x;
    m_ant.y = y;

    m_ant.x = std::clamp(m_ant.x, 0, Game::map.getWidth() - m_ant.w);
    m_ant.y = std::clamp(m_ant.y, 0, Game::map.getHeight() - m_ant.h);
}

void zoom(float aspectRatio) {
    m_ant.x -= (m_ant.w * aspectRatio - m_ant.w) / 2.0f;
    m_ant.y -= (m_ant.h * aspectRatio - m_ant.h) / 2.0f;

    m_ant.w /= aspectRatio;
    m_ant.h /= aspectRatio;

    m_ant.x = std::clamp(m_ant.x, 0, Game::map.getWidth() - m_ant.w);
    m_ant.y = std::clamp(m_ant.y, 0, Game::map.getHeight() - m_ant.h);
}

void move(const bool *keys, float deltaTime) {
    float currentSpeed{m_speed};
    float angleChange{m_rotationSpeed * deltaTime}

    if (keys[SDL_SCANCODE_Q]) {
        m_direction -= (m_direction > -360.0f) ? angleChange : -360.0f + angleChange;
    }
    if (keys[SDL_SCANCODE_E]) {
        m_direction += (m_direction < 360.0f) ? angleChange : -360.0f + angleChange;
    }
    if (keys[SDL_SCANCODE_SPACE]) {
        currentSpeed *= m_dashFactor;
    }

    m_ant.x += currentSpeed * deltaTime * std::cos(m_direction * M_PI / 180.0f);
    m_ant.y += currentSpeed * deltaTime * std::sin(m_direction * M_PI / 180.0f);

    m_ant.x = std::clamp(m_ant.x, 0, Game::map.getWidth() - m_ant.w);
    m_ant.y = std::clamp(m_ant.y, 0, Game::map.getHeight() - m_ant.h);
}

void render(SDL_FRect gameViewport) {
    bool conditionX{m_ant.x + m_ant.w < gameViewport.x || m_ant.x > gameViewport.x + gameViewport.w};
    bool conditionY{m_ant.y + m_ant.h < gameViewport.y || m_ant.y > gameViewport.y + gameViewport.h};

    if (!(conditionX || conditionY)) {
        m_viewport.x = m_ant.x - gameViewport.x;
        m_viewport.y = m_ant.y - gameViewport.y;
        m_viewport.w = m_ant.w;
        m_viewport.h = m_ant.h;
    }

    SDL_RenderTextureRotated(Game::renderer, m_texture, nullptr, m_viewport, m_direction, nullptr, SDL_FLIP_NONE);
}

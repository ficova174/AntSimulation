#include <SDL3/SDL.h>
#include <algorithm>
#include "viewport.h"

void setCoordinates(float x, float y) {
    m_viewport.x = x;
    m_viewport.y = y;

    m_viewport.x = std::clamp(m_viewport.x, 0, Game::map.getWidth() - m_viewport.w);
    m_viewport.y = std::clamp(m_viewport.y, 0, Game::map.getHeight() - m_viewport.h);
}

void setSize(float w, float h) {
    // Warning : no clamping done !
    m_viewport.w = w;
    m_viewport.h = h;

    if ((m_viewport.w > Game::map.getWidth()) || (m_viewport.h > Game::map.getHeight())) {
        std::cerr << "Error: viewport size is bigger than map size\n";
    }
}

void zoom(float changex, float changey, float aspectRatio) {
    float mapWidth = Game::map.getWidth();
    float mapHeight = Game::map.getHeight();

    m_viewport.w += changex;
    m_viewport.h += changey;
    m_viewport.x -= changex / 2;
    m_viewport.y -= changey / 2;

    // 500 is arbitrary and represents min height
    if (m_viewport.h < 500) {
        m_viewport.x -= (500 / Game::aspectRatio - m_viewport.w) / 2;
        m_viewport.y -= (500 - m_viewport.h) / 2;
        m_viewport.h = 500;
        m_viewport.w = 500 / Game::aspectRatio;
    }
    else if (m_viewport.h > mapHeight) {
        m_viewport.x -= (mapHeight / Game::aspectRatio - m_viewport.w) / 2;
        m_viewport.y -= (mapHeight - m_viewport.h) / 2;
        m_viewport.h = mapHeight;
        m_viewport.w = mapHeight / Game::aspectRatio;
    }
    else if (m_viewport.w > mapWidth) {
        m_viewport.x -= (mapWidth * Game::aspectRatio - m_viewport.w) / 2;
        m_viewport.y -= (mapWidth - m_viewport.h) / 2;
        m_viewport.w = mapWidth;
        m_viewport.h = mapWidth * Game::aspectRatio;
    }

    m_viewport.x = std::clamp(m_viewport.x, 0, mapWidth - m_viewport.w);
    m_viewport.y = std::clamp(m_viewport.y, 0, mapHeight - m_viewport.h);
}

void move(const bool *keys, float deltaTime) {
    float dx{0.0f};
    float dy{0.0f};

    if (keys[SDL_SCANCODE_W]) dy -= 1.0f;
    if (keys[SDL_SCANCODE_S]) dy += 1.0f;
    if (keys[SDL_SCANCODE_A]) dx -= 1.0f;
    if (keys[SDL_SCANCODE_D]) dx += 1.0f;

    float length{0.0f};
    length = std::sqrt(dx * dx + dy * dy);

    if (length > 0.0f) {
        if (dx != 0.0f) {
            m_viewport.x += (viewportSpeed * deltaTime * dx) / length;
        }
        if (dy != 0.0f) {
            m_viewport.y += (viewportSpeed * deltaTime * dy) / length;
        }
    }

    m_viewport.x = std::clamp(m_viewport.x, 0, Game::map.getWidth() - m_viewport.w);
    m_viewport.y = std::clamp(m_viewport.y, 0, Game::map.getHeight() - m_viewport.h);
}

#include <SDL3/SDL.h>
#include <iostream>
#include <algorithm>
#include <cmath>
#include "viewport.h"
#include "map.h"

void Viewport::setCoordinates(Map map, float x, float y) {
    m_viewport.x = x;
    m_viewport.y = y;

    m_viewport.x = std::clamp(m_viewport.x, 0.0f, map.getWidth() - m_viewport.w);
    m_viewport.y = std::clamp(m_viewport.y, 0.0f, map.getHeight() - m_viewport.h);
}

void Viewport::setSize(Map map, float w, float h) {
    // Warning : no clamping done !
    m_viewport.w = w;
    m_viewport.h = h;

    if ((m_viewport.w > map.getWidth()) || (m_viewport.h > map.getHeight())) {
        std::cerr << "Error: viewport size is bigger than map size\n";
    }
}

void Viewport::zoom(Map map, float changex, float changey, float screenRatio) {
    float mapWidth = map.getWidth();
    float mapHeight = map.getHeight();

    m_viewport.w += changex;
    m_viewport.h += changey;
    m_viewport.x -= changex / 2;
    m_viewport.y -= changey / 2;

    // 500 is arbitrary and represents min height
    if (m_viewport.h < 500) {
        m_viewport.x -= (500 / screenRatio - m_viewport.w) / 2;
        m_viewport.y -= (500 - m_viewport.h) / 2;
        m_viewport.h = 500;
        m_viewport.w = 500 / screenRatio;
    }
    else if (m_viewport.h > mapHeight) {
        m_viewport.x -= (mapHeight / screenRatio - m_viewport.w) / 2;
        m_viewport.y -= (mapHeight - m_viewport.h) / 2;
        m_viewport.h = mapHeight;
        m_viewport.w = mapHeight / screenRatio;
    }
    else if (m_viewport.w > mapWidth) {
        m_viewport.x -= (mapWidth * screenRatio - m_viewport.w) / 2;
        m_viewport.y -= (mapWidth - m_viewport.h) / 2;
        m_viewport.w = mapWidth;
        m_viewport.h = mapWidth * screenRatio;
    }

    m_viewport.x = std::clamp(m_viewport.x, 0.0f, mapWidth - m_viewport.w);
    m_viewport.y = std::clamp(m_viewport.y, 0.0f, mapHeight - m_viewport.h);
}

void Viewport::move(Map map, const bool *keys, float deltaTime) {
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
            m_viewport.x += (m_viewportSpeed * deltaTime * dx) / length;
        }
        if (dy != 0.0f) {
            m_viewport.y += (m_viewportSpeed * deltaTime * dy) / length;
        }
    }

    m_viewport.x = std::clamp(m_viewport.x, 0.0f, map.getWidth() - m_viewport.w);
    m_viewport.y = std::clamp(m_viewport.y, 0.0f, map.getHeight() - m_viewport.h);
}

#include <SDL3/SDL.h>
#include <iostream>
#include <algorithm>
#include <cmath>
#include "viewport.h"
#include "map.h"

float Viewport::getZoomFactor(float viewportChangeX) const {
    return m_viewport.w / (m_viewport.w + viewportChangeX);
}

void Viewport::setCoordinates(const Map &map, float x, float y) {
    m_viewport.x = x;
    m_viewport.y = y;

    m_viewport.x = std::clamp(m_viewport.x, 0.0f, map.getWidth() - m_viewport.w);
    m_viewport.y = std::clamp(m_viewport.y, 0.0f, map.getHeight() - m_viewport.h);
}

void Viewport::setSize(const Map &map, float w, float h) {
    // Warning : no clamping done !
    m_viewport.w = w;
    m_viewport.h = h;

    if ((m_viewport.w > map.getWidth()) || (m_viewport.h > map.getHeight())) {
        std::cerr << "Error: viewport size is bigger than map size\n";
    }
}

void Viewport::zoom(const Map &map, float changex, float changey) {
    float mapWidth = map.getWidth();
    float mapHeight = map.getHeight();

    // 500 is arbitrary and represents min height
    bool lessMinHeight{(m_viewport.h + changey < 500.0f)};
    bool moreMaxHeight{(m_viewport.h + changey > mapHeight)};
    bool moreMaxWidth{(m_viewport.w + changex > mapWidth)};

    if (lessMinHeight || moreMaxHeight || moreMaxWidth) {
        return;
    }

    m_viewport.w += changex;
    m_viewport.h += changey;

    m_viewport.x -= changex / 2.0f;
    m_viewport.y -= changey / 2.0f;

    m_viewport.x = std::clamp(m_viewport.x, 0.0f, mapWidth - m_viewport.w);
    m_viewport.y = std::clamp(m_viewport.y, 0.0f, mapHeight - m_viewport.h);
}

void Viewport::move(const Map &map, const bool *keys, float deltaTime) {
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

#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include "map.h"

Map::~Map() {
    SDL_DestroyTexture(m_texture);
}

void Map::init(SDL_Renderer *renderer) {
    m_texture = IMG_LoadTexture(renderer, "../assets/map.png");

    if (!m_texture) {
        SDL_Log("Failed to load map texture: %s", SDL_GetError());
        return;
    }

    if (!SDL_GetTextureSize(m_texture, &w, &h)) {
        SDL_Log("Failed to get map size: %s", SDL_GetError());
    }
}

void Map::render(SDL_Renderer *renderer, SDL_FRect gameViewport) {
    if (!SDL_RenderTexture(renderer, m_texture, &gameViewport, nullptr)) {
        SDL_Log("Failed to render the map: %s", SDL_GetError());
    }
}

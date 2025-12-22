#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include "map.h"

Map::Map() {
    m_texture = IMG_LoadTexture(Game::renderer, "../assets/map.png");
    SDL_GetTextureSize(m_texture, &w, &h);
}

Map::~Map() {
    SDL_DestroyTexture(m_texture);
}

void render(SDL_FRect gameViewport) {
    SDL_RenderTexture(Game::renderer, m_texture, gameViewport.getViewport(), nullptr);
}

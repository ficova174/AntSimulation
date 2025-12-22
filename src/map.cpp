#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>
#include "map.h"

Map::~Map() {
    SDL_DestroyTexture(m_texture);
}

void Map::init(SDL_Renderer *renderer) {
    m_texture = IMG_LoadTexture(renderer, "../assets/map.png");
    SDL_GetTextureSize(m_texture, &w, &h);
}

void Map::render(SDL_Renderer *renderer, SDL_FRect gameViewport) {
    SDL_RenderTexture(renderer, m_texture, &gameViewport, nullptr);
}

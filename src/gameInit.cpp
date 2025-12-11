#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>

bool gameInit(const char* appName, const char* creatorName, , ) {
    // Metadata Initialization
    if (!SDL_SetAppMetadata(appName, nullptr, nullptr)) {
        SDL_Log("SDL_SetAppMetadata failed: %s", SDL_GetError());
        SDL_Quit();
        return false;
    }

    if (!SDL_SetAppMetadataProperty(SDL_PROP_APP_METADATA_NAME_STRING, appName)) {
        SDL_Log("SDL_SetAppMetadataProperty app name failed: %s", SDL_GetError());
        SDL_Quit();
        return false;
    }

    if (!SDL_SetAppMetadataProperty(SDL_PROP_APP_METADATA_CREATOR_STRING, creatorName)) {
        SDL_Log("SDL_SetAppMetadataProperty creator name failed: %s", SDL_GetError());
        SDL_Quit();
        return false;
    }

    if (!SDL_SetAppMetadataProperty(SDL_PROP_APP_METADATA_TYPE_STRING, "game")) {
        SDL_Log("SDL_SetAppMetadataProperty app type failed: %s", SDL_GetError());
        SDL_Quit();
        return false;
    }

    // SDL, window, renderer and map texture initialization
    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("SDL_Init failed: %s", SDL_GetError());
        SDL_Quit();
        return false;
    }

    if (!SDL_CreateWindowAndRenderer(appName, screenWidth, screenHeight, 0, &window, &renderer)) {
        SDL_Log("SDL_CreateWindowAndRenderer failed: %s", SDL_GetError());
        SDL_Quit();
        return false;
    }

    mapTexture = IMG_LoadTexture(renderer, "../assets/map.png");

    if (!mapTexture) {
        SDL_Log("Failed to load map texture: %s", SDL_GetError());
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return false;
    }

    return true;
}

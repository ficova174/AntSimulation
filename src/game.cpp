#include <SDL3/SDL.h>
#include "game.h"
#include "map.h"
#include "viewport.h"
#include "ant.h"

Game::Game() {
    viewport.setCoordinates(mapWidth/2, mapHeight/2);
    viewport.setSize(screenWidth, screenHeight);
    ant.setCoordinates(mapWidth/2, mapHeight/2);
}

Game::~Game() {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

bool Game::init(const char* appName, const char* creatorName) {
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

    return true;
}

void Game::loop() {
    Uint64 perfFreq = SDL_GetPerformanceFrequency();
    Uint64 lastCounter = SDL_GetPerformanceCounter();

    SDL_Event event;
    bool running = true;

    while (running) {
        // FPS counter
        Uint64 currentCounter = SDL_GetPerformanceCounter();
        // Convert to seconds
        float deltaTime = static_cast<float>((currentCounter - lastCounter) / perfFreq);
        lastCounter = currentCounter;

        // Events handling
        handleEvents(event, running);

        if (!running) {
            break;
        }

        // Movement handling
        const bool *keys = SDL_GetKeyboardState(nullptr);
        handleMovements(keys, deltaTime);
        
        // Rendering
        render();

        float targetFrameTime = 1.0f / TARGET_FPS;
        float frameTime = static_cast<float>(SDL_GetPerformanceCounter() - currentCounter) / perfFreq;
        if (frameTime < targetFrameTime) {
            SDL_Delay(static_cast<Uint32>((targetFrameTime - frameTime) * 1.0e3f))
        }
    }
}

void Game::handleEvents(SDL_Event &event, bool &running) {
    while (SDL_PollEvent(event)) {
        switch (event.type) {
            case SDL_EVENT_QUIT:
                running = false;
                break;
            case SDL_EVENT_MOUSE_WHEEL:
                handleZoom(event, map, viewport, ant);
                break;
        }
        if (!running) {
            break;
        }
    }
}

void handleZoom(SDL_Event &event, Map &map, Viewport &viewport, Ant &ant) {
    // Adjust viewport size based on mouse wheel scroll
    float viewportChangeX = event.wheel.y * viewport.getZoomSpeed();
    float viewportChangeY = viewportChangeX * Game::aspectRatio;
    float newOldRatio = viewport.w / (viewport.w + viewportChangeX);

    viewport.zoom(viewportChangeX, viewportChangeY);
    ant.zoom(newOldRatio);
}


void Game::handleMovements(const bool *keys, float deltaTime) {
    SDL_PumpEvents();
    viewport.move(keys, deltaTime);

    float currentZoomFactor = Game::screenWidth / viewport.w;

    SDL_PumpEvents();
    ant.move(keys, deltaTime);
}

void Game::render() {
    SDL_RenderClear(renderer);
    map.render(viewport.getViewport());
    ant.render(viewport.getViewport());
    SDL_RenderPresent(renderer);
}

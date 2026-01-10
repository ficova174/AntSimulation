#include <SDL3/SDL.h>
#include "game.h"
#include "map.h"
#include "viewport.h"
#include "nest.h"
#include "ant.h"

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

    map.init(renderer);

    viewport.setSize(map, screenWidth, screenHeight);
    viewport.setCoordinates(map, map.getWidth() / 2.0f, map.getHeight() / 2.0f);

    nest.init(renderer);
    ant.init(renderer);

    nest.setCoordinates(map, map.getWidth() / 2.0f, map.getHeight() / 2.0f);
    ant.setCoordinates(map, map.getWidth() / 2.0f, map.getHeight() / 2.0f);

    return true;
}

void Game::loop() {
    Uint64 perfFreq{SDL_GetPerformanceFrequency()};
    Uint64 lastCounter{SDL_GetPerformanceCounter()};

    SDL_Event event;
    bool running{true};

    while (running) {
        // FPS counter
        Uint64 currentCounter{SDL_GetPerformanceCounter()};
        // Convert to seconds
        float deltaTime{static_cast<float>(currentCounter - lastCounter) / static_cast<float>(perfFreq)};
        lastCounter = currentCounter;

        // Events handling
        handleEvents(event, running);

        if (!running) {
            break;
        }

        // Movement handling
        const bool *keys{SDL_GetKeyboardState(nullptr)};
        handleMovements(keys, deltaTime);
        
        // Rendering
        render();

        float targetFrameTime {1.0f / targetFPS};
        float frameTime {static_cast<float>(SDL_GetPerformanceCounter() - currentCounter) / perfFreq};

        if (frameTime < targetFrameTime) {
            SDL_Delay(static_cast<Uint32>((targetFrameTime - frameTime) * 1.0e3f));
        }
    }
}

void Game::handleEvents(SDL_Event &event, bool &running) {
    while (SDL_PollEvent(&event)) {
        switch (event.type) {
            case SDL_EVENT_QUIT:
                running = false;
                break;
            case SDL_EVENT_MOUSE_WHEEL:
                handleZoom(event);
                break;
        }
        if (!running) {
            break;
        }
    }
}

void Game::handleZoom(SDL_Event &event) {
    float viewportChangeX{event.wheel.y * viewport.getZoomSpeed()};
    float viewportChangeY{viewportChangeX / aspectRatio};

    viewport.zoom(map, viewportChangeX, viewportChangeY);
}

void Game::handleMovements(const bool *keys, float deltaTime) {
    SDL_PumpEvents();
    viewport.move(map, keys, deltaTime);

    ant.move(map, keys, deltaTime);
}

void Game::render() {
    SDL_RenderClear(renderer);

    map.render(renderer, viewport.getViewport());

    nest.render(renderer, viewport.getViewport(), screenWidth);
    ant.render(renderer, viewport.getViewport(), screenWidth);

    SDL_RenderPresent(renderer);
}

#pragma once

#include <SDL3/SDL.h>
#include "map.h"
#include "viewport.h"
#include "nest.h"
#include "ant.h"

class Game {
public:
    ~Game();

    bool init(const char* appName, const char* creatorName);
    void loop();
    void handleEvents(SDL_Event &event, bool &running);
    void handleZoom(SDL_Event &event);
    void handleMovements(const bool *keys, float deltaTime);
    void render();

private:
    SDL_Window* window{nullptr};
    SDL_Renderer* renderer{nullptr};
    static constexpr float targetFPS{120.0f};

    // Objects declarations
    Map map;
    Viewport viewport;
    Nest nest;
    Ant ant;

    // Screen dimensions
    static constexpr float screenHeight{800.0f};
    static constexpr float screenWidth{1200.0f};
    static constexpr float aspectRatio{screenWidth/screenHeight};
};

#pragma once

#include <SDL3/SDL.h>
#include "map.h"
#include "viewport.h"
#include "ant.h"

class Game {
public:
    Game();
    ~Game();

    bool init(const char* appName, const char* creatorName);
    void loop();
    void handleEvents(SDL_Events &event, bool &running);
    void handleZoom(SDL_Event &event, Map &map, Viewport &viewport, Ant &ant);
    void handleMovements(const bool *keys, float deltaTime);
    void render();

private:
    SDL_Window* window{nullptr};
    SDL_Renderer* renderer{nullptr};
    constexpr float targetFPS{120.0f};

    // Objects declarations
    Map map;
    Viewport viewport;
    Ant ant;

    // Screen dimensions
    constexpr float screenHeight{800.0f};
    constexpr float screenWidth{1200.0f};
    constexpr float aspectRatio{screenHeight/screenWidth};

    float currentZoomFactor{1.0f};
};

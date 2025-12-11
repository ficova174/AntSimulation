#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include "gameInit.h"
#include "gameLoop.h"
#include "gameCleanup.h"

int main() {
    // Game Initialisation
    SDL_Window* window{nullptr};
    SDL_Renderer* renderer{nullptr};
    SDL_Texture* mapTexture{nullptr};

    if (!gameInit("Snake++", "Axel LT", )) {
        gameCleanup();
        return 1;
    }

    // Game Loop
    gameLoop();

    // Clean up and exit
    gameCleanup();

    return 0;
}

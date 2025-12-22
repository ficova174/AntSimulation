#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <iostream>
#include "game.h"

int main() {
    Game game;
    
    if (!game.init("AntSimulation", "Axel LT")) {
        std::cerr << "Initialisation failed\n";
        return 1;
    }

    game.loop();

    return 0;
}

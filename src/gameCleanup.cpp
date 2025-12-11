#include <SDL3/SDL.h>

void gameCleanup() {
    SDL_DestroyTexture(mapTexture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

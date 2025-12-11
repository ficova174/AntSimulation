#pragma once

constexpr float TARGET_FPS{120.0f};

// Screen dimensions
constexpr float screenHeight{800.0f};
constexpr float screenWidth{1200.0f};

// viewport settings
constexpr float viewportSpeed{500.0f};
constexpr float zoomSpeed{3.0e3};
constexpr float aspectRatio = screenHeight/screenWidth;

// Snake settings
constexpr float snakeSpeed{150.0f};
constexpr float snakeDashMultiplier{2.0f};
constexpr float snakeRotationSpeed{300.0f};

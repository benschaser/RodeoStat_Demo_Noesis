#pragma once
#include "SFML/Graphics.hpp"
#include "contestant.h"

class Graphics {
public:
    Graphics();
    const sf::Texture& get_frame();
    void update_frame(const Contestant& contestant);

    int width, height;
    int display_width{480};
private:
    sf::Texture frame;
    sf::Texture display_frame;
};
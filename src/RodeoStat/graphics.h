#pragma once
#include "SFML/Graphics.hpp"
#include "contestant.h"

class Graphics {
public:
    const sf::Texture& get_frame();
    void update_frame(const Contestant& contestant);

private:
    sf::Texture frame;
};
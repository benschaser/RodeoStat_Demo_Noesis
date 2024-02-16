#pragma once
#include "SFML/SFML.hpp"

class Graphics {
public:
    Graphics();
    sf::Texture& get_frame() const;
    void update_frame();

private:
    sf::Texture frame;
};
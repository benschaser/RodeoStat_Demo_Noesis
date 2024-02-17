#pragma once
#include "SFML/SFML.hpp"
#include "contestant.h"

class Graphics {
public:
    Graphics();
    sf::Texture& get_frame() const;
    void update_frame(const Contestant& contestant);

private:
    sf::Texture frame;
};
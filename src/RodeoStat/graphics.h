#pragma once
#include <SFML/Graphics.hpp>
#include "../Resources/Bin/NotoSans-Regular.ttf.bin.h"
#include "contestant.h"

class Graphics {
public:
    Graphics(int width, int height);
    const sf::Texture& get_frame();
    void update_frame(const Contestant& contestant);
    void make_frame(std::string name, std::string event, double score, double time);

    int frame_width, frame_height;
    int display_width;

    sf::Texture frame_texture;
    sf::Image frame_img;
private:
    
    // sf::Texture display_frame;
};
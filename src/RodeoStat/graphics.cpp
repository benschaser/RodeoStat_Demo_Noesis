#include "graphics.h"
#include <SFML/Graphics.hpp>
#include <iostream>
#include <string>

Graphics::Graphics(int width, int height) {
    frame_texture.create(width, height);
    frame_width = width;
    frame_height = height;
    frame_img = frame_texture.copyToImage();
    // double ratio = width/height;
    // display_frame.create(display_width, static_cast<int>(display_width/ratio));
}
const sf::Texture& Graphics::get_frame() {
    return frame_texture;
}
void Graphics::make_frame(std::string name, std::string event, double score, double time) {
    sf::RenderTexture rt;
    rt.create(frame_width, frame_height);
    sf::Font font;
    font.loadFromMemory(NOTOSANS_REGULAR_TTF, NOTOSANS_REGULAR_TTF_SIZE);

    sf::Text name_text(name, font, 24);
    name_text.setFillColor(sf::Color::White);
    name_text.setStyle(sf::Text::Bold);
    name_text.setPosition(100, 300);

    sf::Text event_text(event, font, 12);
    event_text.setFillColor(sf::Color::White);
    event_text.setStyle(sf::Text::Regular);
    event_text.setPosition(100, 340);

    std::string score_str = std::to_string(score);
    score_str = score_str.substr(0, score_str.size() - 3);
    sf::Text score_text(score_str, font, 24);
    score_text.setFillColor(sf::Color::White);
    score_text.setStyle(sf::Text::Bold);
    score_text.setPosition(100, 260);

    std::string time_str = std::to_string(time);
    time_str = time_str.substr(0, time_str.size() - 3);
    sf::Text time_text(time_str, font, 24);
    time_text.setFillColor(sf::Color::White);
    time_text.setStyle(sf::Text::Bold);
    time_text.setPosition(200, 260);

    rt.clear();
    rt.draw(name_text);
    rt.draw(event_text);
    rt.draw(score_text);
    rt.draw(time_text);
    rt.display();

    frame_texture = rt.getTexture();
    frame_img = frame_texture.copyToImage();
    frame_img.saveToFile("preview.png");
}

void Graphics::update_frame(const Contestant& contestant) {

}
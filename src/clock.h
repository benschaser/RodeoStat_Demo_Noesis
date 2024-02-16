#pragma once
#include <chrono>

class Clock {
public:
    void start();
    void pause();
    void update();
    void reset();
    double get_current_time();
private:
    std::chrono::time_point<std::chrono::system_clock> start_time, end_time;
    std::chrono::duration<double> elapsed{0.0};
    std::chrono::duration<double> paused{0.0};
    bool running = false;
};
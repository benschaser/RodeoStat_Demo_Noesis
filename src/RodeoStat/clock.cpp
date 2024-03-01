#include <chrono>
#include "clock.h"

void Clock::start() {
    auto now = std::chrono::system_clock::now();
    if (running) {
        paused += (now - end_time);
    }
    else {
        start_time = now;
        running = true;
    }   
}
void Clock::pause() {
    end_time = std::chrono::system_clock::now();
    running = false;
    elapsed += end_time - start_time;
}
void Clock::update() {
    auto now = std::chrono::system_clock::now();
    if (running) {
        elapsed = now - start_time;
    }
}
void Clock::reset() {
    elapsed = std::chrono::duration<double>{0.0};
    paused = std::chrono::duration<double>{0.0};
}
double Clock::get_current_time() {
    return elapsed.count() - paused.count();
}

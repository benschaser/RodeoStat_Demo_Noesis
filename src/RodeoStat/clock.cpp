#include <chrono>
#include "clock.h"

void Clock::start() {
    if (running) {
        paused += (std::chrono::system_clock::now() - end_time);
    }
    else {
        start_time = std::chrono::system_clock::now();
        running = true;
    }   
}
void Clock::pause() {
    running = false;
    end_time = std::chrono::system_clock::now();
}
void Clock::update() {
    if (running) {
        elapsed = std::chrono::system_clock::now() - start_time;
    }
}
void Clock::reset() {
    elapsed = std::chrono::duration<double>{0.0};
    paused = std::chrono::duration<double>{0.0};
}
double Clock::get_current_time() {
    return elapsed.count() - paused.count();
}

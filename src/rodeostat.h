#pragma once
#include <vector>
#include "control.h"
#include "graphics.h"
#include "settings.h"
#include "contestant.h"

class RodeoStat {
public:
    Control control;
    Graphics graphics;
    std::vector<Contestant> contestants;
    int current_contestant{0};

    void update_frame();
private:
    Settings settings;

};
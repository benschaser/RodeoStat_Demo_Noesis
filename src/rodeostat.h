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

    std::string print_hello();
private:
    Settings settings;
    std::vector<Contestant> contestants;

};
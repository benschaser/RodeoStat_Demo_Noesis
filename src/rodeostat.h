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

    
private:
    Settings settings;

};
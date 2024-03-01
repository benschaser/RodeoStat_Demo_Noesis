#include "control.h"

void Control::reset() {
    clock.pause();
    clock.reset();

    score.set_score(0.000);
}
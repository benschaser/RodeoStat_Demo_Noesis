#pragma once

class Score {
public:
    double get_score();
    void set_score(double new_score);
private: 
    double score{0.0};
};
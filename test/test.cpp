#include <catch2/catch_test_macros.hpp>
#include <chrono>
#include <thread>
#include "rodeostat.h"

RodeoStat rs;
constexpr double epsilon = 0.005;

TEST_CASE( "RodeoStat clock working properly", "[rodeostat]") {
    REQUIRE(rs.control.clock.get_current_time() == 0.000);

    rs.control.clock.start();
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
    rs.control.clock.pause();
    REQUIRE((rs.control.clock.get_current_time() >= 0.100 - epsilon || rs.control.clock.get_current_time() <= 0.100 + epsilon));

    rs.control.clock.start();
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
    rs.control.clock.pause();
    REQUIRE((rs.control.clock.get_current_time() >= 0.600 - epsilon || rs.control.clock.get_current_time() <= 0.600 + epsilon));

    rs.control.clock.reset();
    REQUIRE(rs.control.clock.get_current_time() == 0.000);

    rs.control.clock.start();
    std::this_thread::sleep_for(std::chrono::milliseconds(200));
    rs.control.clock.pause();
    REQUIRE((rs.control.clock.get_current_time() >= 0.200 - epsilon || rs.control.clock.get_current_time() <= 0.200 + epsilon));
}

TEST_CASE( "RodeoStat scoreboard working properly", "[rodeostat]") {
    REQUIRE(rs.control.score.get_score() == 0.000);

    rs.control.score.set_score(1.345);
    REQUIRE(rs.control.score.get_score() == 1.345);
}

TEST_CASE( "RodeoStat contestant list working properly", "[rodeostat]") {
    REQUIRE(rs.contestants.size() == 0);

    rs.add_contestant("John", "Smith", "Rodeo", 0.0, 0.0);
    rs.add_contestant("Jane", "Doe", "Bullriding", 0.0, 0.0);
    REQUIRE(rs.contestants.size() == 2);

    rs.current_contestant = 0;
    REQUIRE(rs.contestants.at(rs.current_contestant).fname == "John");

    rs.current_contestant = 1;
    REQUIRE(rs.contestants.at(rs.current_contestant).lname == "Doe");
    REQUIRE(rs.contestants.at(rs.current_contestant).event == "Bullriding");

    rs.remove_contestant(0);
    REQUIRE(rs.current_contestant == 0);
    REQUIRE(rs.contestants.at(rs.current_contestant).lname == "Doe");
}

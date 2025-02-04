# This file contains tests for the hole route where the user's logged in state is not relevant.

use hole;
use t;

plan 7;

subtest 'Run button works.' => {
    plan 2;
    my $wd = HoleWebDriver.create;
    LEAVE $wd.delete-session;
    $wd.loadFizzBuzz;
    $wd.getLangLink('Raku').click;
    $wd.typeCode: $raku57_55;
    $wd.isBytesAndChars: 57, 55;
    $wd.run;
    $wd.isPassing;
}

subtest 'Run button cancels running solutions.' => {
    # This is a useful feature for when a user makes a mistake and submits a solution that will time out, realizes that
    # it will time out, fixes the mistake, and then submits another solution before the original run finishes.
    plan 4;
    my $wd = HoleWebDriver.create;
    LEAVE $wd.delete-session;
    $wd.loadFizzBuzz;
    $wd.getLangLink('Raku').click;
    # Submit a solution that will fail after a couple seconds.
    $wd.typeCode: "sleep 2";
    $wd.isBytesAndChars: 7, 7;
    $wd.run;
    # Submit a correct solution that finishes much faster than the failing one.
    $wd.typeCode: BACKSPACE x 7 ~ $raku57_55;
    $wd.isBytesAndChars: 57, 55;
    $wd.run;
    $wd.isPassing;
    # Wait until the original solution has finished.
    sleep 4;
    $wd.isPassing: 'The state should still be passing after waiting for the failing solution to finish.';
}

subtest 'Language is preserved on reload.' => {
    plan 3;
    my $wd = HoleWebDriver.create;
    LEAVE $wd.delete-session;
    $wd.loadFizzBuzz;
    is $wd.getLanguageActive('Raku'), False, "Raku shouldn't be the active language, because it's not the default language.";
    $wd.getLangLink('Raku').click;
    is $wd.getLanguageActive('Raku'), True, "After clicking the link, Raku should be the active language.";
    $wd.loadFizzBuzz;
    is $wd.getLanguageActive('Raku'), True, "After reloading the page, Raku should still be the active language.";
}

subtest 'Language is preserved when loading a different hole.' => {
    plan 3;
    my $wd = HoleWebDriver.create;
    LEAVE $wd.delete-session;
    $wd.loadFizzBuzz;
    is $wd.getLanguageActive('Raku'), False, "Raku shouldn't be the active language, because it's not the default language.";
    $wd.getLangLink('Raku').click;
    is $wd.getLanguageActive('Raku'), True, "After clicking the link, Raku should be the active language.";
    $wd.loadFibonacci;
    is $wd.getLanguageActive('Raku'), True, "After loading a different hole, Raku should still be the active language.";
}

subtest 'User can change the scoring.' => {
    plan 3;
    my $wd = HoleWebDriver.create;
    LEAVE $wd.delete-session;
    $wd.loadFizzBuzz;
    is $wd.getScoringPickerState, 'bytes', "The scoring should be the default, bytes.";
    $wd.setScoring: 'chars';
    is $wd.getScoringPickerState, 'chars', "The scoring was changed to chars.";
    $wd.setScoring: 'bytes';
    is $wd.getScoringPickerState, 'bytes', "The scoring was changed to bytes.";
}

subtest 'Scoring is preserved on reload.' => {
    plan 3;
    my $wd = HoleWebDriver.create;
    LEAVE $wd.delete-session;
    $wd.loadFizzBuzz;
    is $wd.getScoringPickerState, 'bytes', "The scoring should be the default, bytes.";
    $wd.setScoring: 'chars';
    is $wd.getScoringPickerState, 'chars', "The scoring was changed to chars.";
    $wd.loadFizzBuzz;
    is $wd.getScoringPickerState, 'chars', "The scoring was changed to chars.";
}

subtest 'Scoring is preserved when loading a different hole.' => {
    plan 3;
    my $wd = HoleWebDriver.create;
    LEAVE $wd.delete-session;
    $wd.loadFizzBuzz;
    is $wd.getScoringPickerState, 'bytes', "The scoring should be the default, bytes.";
    $wd.setScoring: 'chars';
    is $wd.getScoringPickerState, 'chars', "The scoring was changed to chars.";
    $wd.loadFibonacci;
    is $wd.getScoringPickerState, 'chars', "The scoring is still chars for a different hole.";
}

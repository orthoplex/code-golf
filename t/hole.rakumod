use Test;
use WebDriver;

# https://www.w3.org/TR/webdriver/#keyboard-actions
constant CONTROL = "\xe009";
constant RETURN = "\xe006";
constant END = "\xe010";
constant HOME = "\xe011";
constant DELETE = "\xe011";
constant BACKSPACE = "\xe003";

my $cookieKey = "__Host-session";

our $raku57_55 is export = 'say "Fizz" x $_ %% 3 ~ "Buzz" x $_ %% 5 || $_ for 1…100';

# For the final three lines, Code Mirror is expected to add a single leading space for auto-indentation.
# For NG, the second line is also auto-indented and the leading space below should be removed.
our $python121_121 is export = "for x in range(1,101):" ~
    "{RETURN} if x%15==0:print('FizzBuzz')" ~
    "{RETURN}elif x%3==0:print('Fizz')" ~
    "{RETURN}elif x%5==0:print('Buzz')" ~
    "{RETURN}else:print(x)";

our $python210_88 is export = "exec('景爠砠楮⁲慮来⠱ⰱ〱⤺ਠ楦⁸┱㔽㴰㩰物湴⠧䙩空䉵空✩ਠ敬楦⁸┳㴽〺灲楮琨❆楺稧⤊⁥汩映砥㔽㴰㩰物湴⠧䉵空✩ਠ敬獥㩰物湴⡸⤠'.encode('utf-16be'))";

our $python62_62 is export = 'for i in range(1,101):print("Fizz"*(i%3<1)+"Buzz"*(i%5<1)or i)';

class HoleWebDriver is WebDriver is export {
    method create(::?CLASS:U $wd:) {
        $wd.new: :4444port, :host<firefox>, :capabilities(:alwaysMatch(
            {:acceptInsecureCerts, 'moz:firefoxOptions' => :args('-headless',)}));
    }

    method clearLocalStorage {
        $.js: 'localStorage.clear();';
    }

    method findAndWait(Str:D $text, WebDriver::Selector:D :$using = WebDriver::Selector::CSS) {
        for ^5 {
            try {
                return $.find($text, :$using);
            }
            sleep 1;
        }

        $.find($text, :$using);
    }

    method getLangLink(Str:D $lang) {
        $.findAndWait: "#$lang";
    }

    method getLanguageActive(Str:D $lang) {
        $.getLangLink($lang).prop('href') eq '';
    }

    method getSolutionLink(Str:D $solution) {
        # Use CSS to find links, because the link text also includes the number of bytes/chars.
        # Don't try again, if not found. Sometimes these links aren't present.
        $.find("#{$solution.tc}Solution");
    }

    method getScoringLink(Str:D $scoring) {
        $.findAndWait($scoring.tc, :using(WebDriver::Selector::LinkText));
    }

    method getSolutionPickerState of Str {
        try {
            return "bytes" if $.getSolutionLink('bytes').prop('href') eq '';
            return "chars" if $.getSolutionLink('chars').prop('href') eq '';
        }
        '';
    }

    method getScoringPickerState of Str {
        try {
            return "bytes" if $.getScoringLink('bytes').prop('href') eq '';
            return "chars" if $.getScoringLink('chars').prop('href') eq '';
        }
        '';
    }

    # Methods whose names begin with "is" do exactly one assertion.
    method isBytesAndChars($bytes, $chars, $desc = 'Confirm byte and char counts') {
        is $.find('#chars').text, "$bytes bytes, $chars chars", $desc;
    }

    # Methods whose names begin with "is" do exactly one assertion.
    method isFailing(Str:D $desc = '') {
        $.isResult: 'Fail ☹️', $desc;
    }

    # Methods whose names begin with "is" do exactly one assertion.
    method isPassing(Str:D $desc = '') {
        $.isResult: 'Pass 😀', $desc;
    }

    # Methods whose names begin with "is" do exactly one assertion.
    method isResult(Str:D $expectedText, Str:D $desc = '') {
        for ^5 {
            if (my $text = $.find('h2').text) && $text ne '…' {
                is $text, $expectedText, ($desc || 'Confirm the result of running the program');
                return;
            }

            sleep 1;
        }

        flunk "Failed to find run results. $desc";
    }

    method loadFibonacci {
        $.get: 'https://app:1443/fibonacci';
    }

    method loadFizzBuzz {
        $.get: 'https://app:1443/fizz-buzz';
    }

    method run {
        $.find('Run', :using(WebDriver::Selector::LinkText)).click;
    }

    method setScoring(Str:D $scoring) {
        $.getScoringLink($scoring).click;
    }

    method setSolution(Str:D $solution) {
        $.getSolutionLink($solution).click;
    }

    method setSessionCookie(Str:D $session) {
        $.cookie: $cookieKey, $session, :httpOnly, :sameSite<Lax>, :secure;
    }

    method typeCode(Str:D $code) {
        $.find('textarea').send-keys: $code;
    }
}

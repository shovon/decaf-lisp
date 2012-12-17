var predefined = {};
predefined['console-log'] = function (arg) {
      return console.log(arg);
    };
predefined['if'] = function (condition, val1, val2) {
      if (condition) {
        return val1;
      } else {
        return val2;
      }
    };
predefined['<'] = function (left, right) {
      return left < right;
    };
predefined['num'] = function (str) {
      return parseInt(str, 10);
    };
predefined['arg'] = function (index) {
      return process.argv[index];
    };
var func = {};

func['display-something'] = function (val1, val2) {
  return predefined['console-log'](predefined['if'](predefined['<'](val1, val2), "First is smaller", "Second is smaller"));
};

func['display-something'](predefined['num'](predefined['arg'](3)), predefined['num'](predefined['arg'](4)));

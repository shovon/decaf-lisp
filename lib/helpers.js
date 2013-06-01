module.exports.tokenize = function (src) {
  return src.match(/[\(\)]|[^\s\(\)]+/g);
};

module.exports.buildTree = function (tokens) {
  var
    // For-loop variables.
      i
    , len

    // The value to return.
    , retval

    // Instead of using recursion for the tree building process, we are just
    // going to have pointer reference to the current node. The _current and
    // _tempArr variables are used for that.
    , _current
    , _tempArr;

  retval      = [];
  _current = retval;

  for (i = 0, len = tokens.length; i < len; i++) {
    if (tokens[i] === '(') {
      // If the token is an opening bracket, then push an empty child node to
      // the parent node.
      _tempArr    = _current;
      _current = []
      _current.parent = _tempArr
      _tempArr.push(_current);
    } else if (tokens[i] === ')') {
      // If the token is a closing bracket, then walk to the parent node.

      // This often means that there is an unexpected closing parenthesis that
      // goes beyond the root node of the tree.
      if (!_current.parent && i !== len - 1) {
        throw new Error("Unexpected ')'");
      }
      _current = _current.parent;
      // `_current.parent != null` checks to see if _current.parent is
      // neither null or undefined. Please ignore the fact that this is
      // considered bad practice.
      if (_current && _current.parent != null) {
        // We want to ensure that each array node of the tree is merely a
        // JavaScript array, and that it isn't literred with non-array
        // artifacts.
        _current.parent = void 0;
        delete _current.parent;
      }
    } else {
      _current.push(tokens[i]);
    }
  }

  if (_current) {
    throw new Error("Unexpected end of code");
  }

  return retval;
};

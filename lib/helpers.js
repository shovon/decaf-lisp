/**
 * This is where all the functions are stored. And it's from this that all the
 * the named functions are called.
 */
var FUNCTION_DEPOT_NAME = module.exports.FUNCTION_DEPOT_NAME = "___f";

/**
 * Splits a string into tokens.
 * e.g. (hello-world) into ['(', 'hello-world', ')']
 *
 * @param src a string that represents the source code.
 * @returns an array with the tokens in it.
 */
module.exports.tokenize = function (src) {
  return src.match(/[\(\)]|[^\s\(\)]+/g);
};

/**
 * In JavaScript, `typeof []` returns `object` (i.e. `typeof [] == typeof {}`).
 * This function checks to see whether or not the passed-in object is an array.
 *
 * @param an object
 * @returns true if the object is an array. False otherwise.
 */
var isArray = module.exports.isArray = function (obj) {
  return Object.prototype.toString.call(obj) === "[object Array]";
}

/**
 * Checks to see whether or not an element is in an array.
 *
 * @param element an object to check whether or not it is in the array.
 * @returns true if the object is in the array. False otherwise.
 */
var isIn = module.exports.isIn = function (element, arr) {
  var i, len;
  for (i = 0, len = arr.length; i < len; i++) {
    if (element === arr[i]) {
      return true;
    }
  }
  return false;
};

/**
 * Given an array of tokens, match parenthesis to build a tree.
 *
 * e.g. `"(+ (+ 4 5) (- 5 6))"` should output:
 * 
 *     +
 *       + 4 5
 *       - 5 6
 *
 * @param tokens is an array of tokens
 * @returns an array, with nested arrays to represent a tree.
 * @seealso `tokenize`
 * @throws an exception whenever the tokens contain unmatching parenthesises. 
 */
module.exports.buildTree = function (tokens) {
  var i
    , len

    , retval

    // Instead of using recursion for the tree building process, we are just
    // going to have pointer reference to the current node. The current and
    // tempArr variables are used for that.
    , current
    , tempArr
    , level = 0;

  // This is the root node. In theory, this will have all the statements.
  retval  = [];

  // Like the name implies, `current` represents the current node. Here, it is
  // initialized as the root node.
  current = retval;

  for (i = 0, len = tokens.length; i < len; i++) {
    if (tokens[i] === '(') {
      // If the token is an opening bracket, then push an empty child node to
      // the parent node.
      tempArr = current;
      current = []
      current._parent = tempArr
      tempArr.push(current);

      level++;
    } else if (tokens[i] === ')') {
      // If the token is a closing bracket, then walk to the parent node.

      current = current._parent;

      level--;
      if (level < 0) {
        throw new Error("Unexpected ')'.");
      }
    } else {
      current.push(tokens[i]);
    }
  }

  if (level) {
    throw new Error("Unexpected end of code.");
  }

  return retval;
};

// TODO: this is only used by the `Statement` class. It's best if we move it
//   there, instead.
var keywords = [ 'lambda', 'defun' ];

/**
 * Represents a statement.
 */
var Statement = module.exports.Statement = (function () {

  /**
   * Constructor for `Statement`.
   *
   * @param tree is an array with possibly nested arrays.
   * @seealso `buildTree`
   * // `keywords` might not even be necessary.
   * @seealso `keywords`
   * @throws an exception whenever a provided tree 
   *   - starts with `defun`
   *   - any of the parameters are strings that represent a keyword.
   *     * Note: it's fine if the tree itself contains the keyword `lambda` so
   *       long as it is not a parameter, but part of a nested array that
   *       represnts a lambda expression.
   */
  function Statement(tree) {
    var i, len, callee, params = [];

    callee = (function (callee) {
      if (isArray(callee)) {
        if (callee[0] === 'lambda') {
          return new Lambda(callee);
        } else if (callee[0] === 'defun') {
          throw new Error("Unexpected 'defun'.");
        } else {
          return new Statement(callee);
        }
      } else { // It is assumed to be a string.
        return callee;
      }
    })(tree[0]);

    for (i = 1, len = tree.length; i < len; i++) {
      // TODO: don't use the `keywords` object found outside of this
      //   constructor. Create one in the constructor itself.
      if (isIn(tree[i], keywords)) {
        throw new Error("Unexpected " + tree[i] + ".");
      } else if (typeof tree[i] == 'string') {
        params.push(tree[i]);
      } else if (tree[i][0] === 'lambda') {
        params.push(new Lambda(tree[i]));
      } else { // It is assumed to be an array.
        params.push(new Statement(tree[i]));
      }
    }

    this.type = "call";
    this.callee = callee;
    this.params = params;
  }

  return Statement;
})();

/**
 * Represents a lambda expression.
 */
var Lambda = module.exports.Lambda = (function () {

  /**
   * Constructor for Lambda.
   *
   * @param tree is an array with possibly nested arrays.
   * @seealso `Statement`
   * @seealso `Lambda`
   */
  function Lambda(tree) {
    var params, code;

    if (!isArray(tree[1])) {
      throw new Error("Unexpected " + tree[1] + ".");
    }

    params = tree[1];

    if (!isArray(tree[2])) {
      throw new Error("Unexpected " + tree[1] + ".");
    }

    code = (function () {
      if (tree[2][0] === 'lambda') {
        return new Lambda(tree[2]);
      } else if (tree[2][0] === 'defun') {
        throw new Error("Unexpected defun.");
      } else {
        return new Statement(tree[2]);
      }
    })();

    this.type = "lambda";
    this.params = params;
    this.code = code;
  }

  return Lambda;
})();

var LispFunction = module.exports.LispFunction = (function () {
  function LispFunction(tree) {
    // Our Lisp function will not have any more than one statement. When a tree
    // has a cardinality that does not equal 4 at the second level, then it
    // means our function fails to have the following structure:
    //
    // - `defun` keyword (at index 0)
    // - name (at index 1)
    // - parameters (at index 2)
    // - the function call (at index 3)
    if (tree.length != 4) {
      throw new Error("Decaf Lisp functions can only contain one statement.");
    }

    var functionName
      , parameters
      , code;

    if (typeof tree[1] !== 'string') {
      throw new Error("Unexpected '('.");
    }

    functionName = tree[1];

    if (!isArray(tree[2])) {
      throw new Error("Unexpected " + tree[2] + ".");
    }

    // TODO: check to see if the parameters are correct.
    parameters = tree[2];

    code = (function () {
      if (typeof tree[3] == 'string') {
        throw new Error("Not yet implemented.");
      } else {
        if (tree[3][0] === 'lambda') {
          return new Lambda(tree[3]);
        } else if (isArray(tree[3][0]) || typeof tree[3][0] === 'string') {
          return new Statement(tree[3]);
        }
      }
    })();

    this.type = 'function';
    this.name = functionName;
    this.params = parameters;
    this.code = code;
  }

  return LispFunction;
})();

var buildAst = module.exports.buildAst = function (tree) {
  var i, len, arr = [];

  for (i = 0, len = tree.length; i < len; i++) {
    // In theory, everything in the array should be simply statements.
    if (tree[i][0] === 'defun') {
      arr.push(new LispFunction(tree[i]));
    } else if (tree[i][0] === 'lambda') {
      // Do nothing, since a lambda expression doesn't do anything.
    } else {
      arr.push(new Statement(tree[i]));
    }
  }

  return arr;
};

var outputStatement = module.exports.outputStatement = function (tree) {
  var i
    , len
    , str = (function () {
      if (typeof tree.callee == 'string') {
        return FUNCTION_DEPOT_NAME + '["' + tree.callee + '"]('
      } else if (tree.callee.type === 'lambda') {
        return outputLambda(tree.callee) + "(";
      } else {
        return outputStatement(tree.callee) + "(";
      }
    }())
    , p = [];

  for (i = 0, len = tree.params.length; i < len; i++) {
    if (typeof tree.params[i] == 'string') {
      p.push(tree.params[i]);
    } else if (tree.params[i].type === 'lambda') {
      p.push(outputLambda(tree.params[i]));
    } else {
      p.push(outputStatement(tree.params[i]));
    }
  }

  str += p.join(', ') + ')';
  return str;
};

var outputLambda = module.exports.outputLambda = function (tree) {
  var str = 'function (' + tree.params.join(', ') + ') {' +
      "return " + outputStatement(tree.code) + ";" +
    "}";
  return str;
}

module.exports.compile = function (ast) {
  throw new Error("Not yet implemented.");
};

var helpers = require('./lib/helpers')
  , assert  = require('assert')
  , fs      = require('fs');

var getSource = function (name) {
  return fs.readFileSync("./examples/" + name + ".lisp", "utf8");
};

var isRegExp = function (obj) {
  return Object.prototype.toString.call(obj) === '[object RegExp]'
};

var isArray = helpers.isArray;

var isSpecialObject = function (obj) {
  return isArray(obj) || isRegExp(obj) || (obj === null);
};

var isStrictlyObject = function (obj) {
  return Object.prototype.toString.call(obj) === '[object Object]';
};

var getProperties = function (obj) {
  var key, arr = [];

  for (key in obj) {
    if (obj.hasOwnProperty(key)) {
      arr.push(key);
    }
  }

  return arr;
};

assert.deepEqual = function (obj1, obj2) {
  var i, len, key;
  if (obj1 === obj2) {
    return;
  } else if (isArray(obj1) !== isArray(obj2)) {
    throw new Error("Both objects should be of same type.");
  } else if (isArray(obj1)) {
    if (obj1.length != obj2.length) {
      throw new Error("Both arrays should have the same length");
    }
    for (i = 0, len = obj1.length; i < len; i++) {
      assert.deepEqual(obj1[0], obj2[0]);
    }
    return;
  } else if (isStrictlyObject(obj1) !== isStrictlyObject(obj2)) {
    throw new Error("Both objects should be of same type.");
  } else if (isStrictlyObject(obj1)) {
    assert.deepEqual(getProperties(obj1), getProperties(obj2));
    for (key in obj1) {
      if (obj1.hasOwnProperty(key)) {
        assert.deepEqual(obj1[key], obj2[key]);
      }
    }
    return
  }
  throw new Error("Not yet implemented.");
};

describe("test helpers", function () {
  describe("isArray", function () {
    it("should return true if given an array, and false otherwise", function () {
      assert(isArray([]));
      assert(!isArray({}));
    });
  });

  describe("isRegExp", function () {
    it("should return true if given a RegExp object, and false otherwise", function () {
      assert(isRegExp(/something/g));
      assert(!isRegExp(""));
    });
  });

  describe("isSpecialObject", function () {
    it("should return true given an array, RegExp, or null. Returns false otherwise", function () {
      assert(isSpecialObject([]));
      assert(isSpecialObject(/something/g));
      assert(isSpecialObject(null));
      assert(!isSpecialObject({}));
      assert(!isSpecialObject(""));
      assert(!isSpecialObject(function () {}));
      assert(!isSpecialObject(void 0));
      assert(!isSpecialObject(1));
    });
  });

  describe("isSpecialObject", function () {
    it("should return true given an array, RegExp, or null. Returns false otherwise", function () {
      assert(isStrictlyObject({}));
      assert(!isStrictlyObject([]));
      assert(!isStrictlyObject(/something/g));
      assert(!isStrictlyObject(null));
      assert(!isStrictlyObject(""));
      assert(!isStrictlyObject(function () {}));
      assert(!isStrictlyObject(void 0));
      assert(!isStrictlyObject(1));
    });
  });

  describe("getProperties", function () {
    it("should be able to grab a list of all properties from a given object", function () {
      var obj         = { a: 1, b: 2, c: 3, d: 4, e: 5 }
        , expectedArr = 'abcde'.split('')
        , props;

      props = getProperties(obj);
      props.sort();
      assert.deepEqual(props, expectedArr);
    });
  });

  describe("deepEqual", function () {
    it("should not throw an error if both objects are the same pointer, or of same value.", function () {
      assert.deepEqual(1, 1);
      // Prevent creation of a new `obj` variable. Create it as a parameter to
      // a self-executing anonymous function. Checking obj === obj should
      // evaluate to true.
      (function (obj) { assert.deepEqual(obj, obj); }({}))
    });

    it("should throw an error if either of the objects aren't of the same value", function () {
      try {
        assert.deepEqual(2, 3);
        throw new Error("Should have thrown an error");
      } catch (e) {
        assert(true); // Meh. Felt empty without it.
      }
    })

    it("should not throw an error if both arrays (without nesting) are equivalent", function () {
      var arr1 = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        , arr2 = [1, 2, 3, 4, 5, 6, 7, 8, 9];

      assert.deepEqual(arr1, arr2);
    });

    it("should throw an error if either of the arrays (without nesting) don't match", function () {
      var arr1 = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        , arr2 = [1, 2, 3, 4, 5, 6, 7, 8, 10];

      try {
        assert.deepEqual(arr1, arr2);
        throw new Error("Should have thrown an error");
      } catch (e) {
        assert(true); // Just do it. Whatevs;
      }
    });

    it("should throw an error if either of the arrays (without nesting) don't have the same length", function () {
      var arr1 = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        , arr2 = [1, 2, 3, 4, 5, 6, 7, 8];

      try {
        assert.deepEqual(arr1, arr2);
        throw new Error("Should have thrown an error");
      } catch (e) {
        assert(true); // Just do it. Whatevs;
      }
    });

    it("should not throw an error if both the arrays are equivalent", function () {
      var arr1 = [1, 2, [3, [4, 5, 6], 7], 8, [10]]
        , arr2 = [1, 2, [3, [4, 5, 6], 7], 8, [10]];

      assert.deepEqual(arr1, arr2);
    });

    it("should throw an error if both the arrays are equivalent", function () {
      var arr1 = [1, 2, [3, [4, 5, 6], 7], 8, [10]]
        , arr2 = [1, 2, [3, [4, 5], 7], 8, [10]];

      try {
        assert.deepEqual(arr1, arr2);
        throw new Error("Should have thrown an error");
      } catch (e) {
        assert(true); // OK, I think it's about time to refactor this.
      }
    });

    it("should not throw an error if both objects are equivalent", function () {
      var obj1 = { a: 'b', b: 'c', c: 10, d: [ 1, 2, 3 ] }
        , obj2 = { a: 'b', b: 'c', c: 10, d: [ 1, 2, 3 ] };

      assert.deepEqual(obj1, obj2);
    });

    it("should throw an error if there are discrepancy between objects", function () {
      var obj1 = { a: 'b', b: 'c', c: 10, d: [ 1, 2, 3 ] }
        , obj2 = { a: 'b', b: 'c', c: 11, d: [ 1, 2, 3 ] };
      try {
        assert.deepEqual(obj1, obj2);
        throw new Error("Should have thrown an error.");
      } catch (e) {
        assert(true);
      }
    });
  });
});

describe("helpers", function () {
  describe("isIn", function () {
    it("should return true if 1 is an element of [1, 2, 3], and false if 4 isn't.", function () {
      var isIn = helpers.isIn;
      assert(isIn('1', '123'.split('')));
      assert(!isIn('4', '123'.split('')));
    });
  });
});

describe("tokenizer", function () {
  it("should tokenize (something)", function () {
    var expected = ['(', 'something', ')']
      , tokens   = helpers.tokenize('(something)');

    assert.equal(tokens.length, expected.length);

    tokens.forEach(function (token, i) {
      assert.equal(token, expected[i]);
    })
  });

  it("the spaces should be meaningless in (   something   )", function () {
    var expected = ['(', 'something', ')']
      , tokens   = helpers.tokenize('(   something   )');

    assert.equal(tokens.length, expected.length);

    tokens.forEach(function (token, i) {
      assert.equal(token, expected[i]);
    });
  });

  it("subsequent parens should be considered separate parens", function () {
    var expected = ['(', '(', 'something', ')', ')']
      , tokens   = helpers.tokenize('((something))');

    assert.equal(tokens.length, expected.length);

    tokens.forEach(function (token, i) {
      assert.equal(token, expected[i]);
    });
  });
});

describe("tree builder", function () {
  it("should be able to parse add.lisp into a tree", function () {
    var code         = getSource("add")
      , expectedTree = [
        [
            'add'
          , [ 'add', '6', '10' ]
          , [ 'add', '7', '10' ]
        ]
      ]
      , result
      , tokenize  = helpers.tokenize
      , buildTree = helpers.buildTree;


    result = buildTree(tokenize(code));

    assert.deepEqual(result, expectedTree);
  });

  it("should not be able to parse a function that doesn't have any parameters", function () {
    var code         = "(defun something () (+ 1 1))"
      , expectedTree = [
        [
            'defun'
          , 'something'
          , []
          , [ '+', '1', '1' ]
        ]
      ]
      , result
      , tokenize  = helpers.tokenize
      , buildTree = helpers.buildTree;

      result = buildTree(tokenize(code));

      assert.deepEqual(result, expectedTree);
  });
});

describe("statement builder", function () {
  it("should be able to construct a statement", function () {
    var Statement = helpers.Statement
      , tree     = '+11'.split('')
      , expected = {
          type  : "call"
        , callee: "+"
        , params: "11".split('')
      }
      , result;

      result = new Statement(tree);
      assert.deepEqual(result, expected);
  });

  it("should be able to construct a statement with multiple levels of nesting", function () {
    var Statement = helpers.Statement
      , tree = [
          '+'
        , '+11'.split('')
        , '-12'.split('')
      ]
      , expected = {
          type  : "call"
        , callee: "+"
        , params: [{
            type  : "call"
          , callee: "+"
          , params: "11".split('')
        }, {
            type  : "call"
          , callee: "-"
          , params: "12".split('')
        }]
      }
      , result;

      result = new Statement(tree);
      assert.deepEqual(result, expected);
  });
});

describe("function builder", function () {
  it("should be able to construct a function, that doesn't have any parameters", function () {
    var LispFunction = helpers.LispFunction
      , tree     = [ 'defun', "something", [], ['+', '1', '2'] ]
      , expected = {
          type  : "function"
        , name  : "something"
        , params: []
        , code: {
            type  : 'call'
          , callee: "+"
          , params: ['1', '2']
        }
      }
      , result;

    result = new LispFunction(tree);
    assert.deepEqual(result, expected);
  });
});

describe("lambda builder", function () {
  it("should be able to construct a function, that doesn't have any parameters", function () {
    var Lambda   = helpers.Lambda
      , tree     = [ 'lambda', [], '+12'.split('') ]
      , expected = {
          type  : "lambda"
        , params: []
        , code: {
            type  : 'call'
          , callee: '+'
          , params: '12'.split('')
        }
      }
      , result;

      result = new Lambda(tree);
      assert.deepEqual(result, expected);
  });
});

describe("AST builder", function () {
  it("should be able to parse complete.lisp into an abstract syntax tree", function () {
    var code         = getSource("complete")
      , expectedTree = [{
          type  : "function"
        , name  : "add"
        , params: ['a', 'b']
        , code  : {
            type  : "call"
          , callee: "+"
          , params: ['a', 'b']
        }
      }, {
          type  : "function"
        , name  : "add"
        , params: ['a']
        , code  : {
            type  : "lambda"
          , params: [ 'b' ]
          , code  : {
              type  : "call"
            , callee: "+"
            , params: [ 'a', 'b' ]
          }
        }
      }, {
          type  : "call"
        , callee: "add"
        , params: ['10', '5']
      }, {
          type  : "call"
        , callee: {
              type  : "call"
            , callee: "curryAdd"
            , params: [ '10' ]
          }
        , params: [ '5' ]
      }]
      , result
      , tokenize = helpers.tokenize
      , buildTree = helpers.buildTree
      , buildAst = helpers.buildAst;

    result = buildAst(buildTree(tokenize(code)));
    assert.deepEqual(result, expectedTree);
  });
});

describe("statment builder", function () {
  it("should build `(hello-world)` into `" + helpers.FUNCTION_DEPOT_NAME + "['hello-world']()`", function () {
    var Statement       = helpers.Statement
      , buildTree       = helpers.buildTree
      , tree            = buildTree(['(', 'hello-world', ')'])
      , statement       = new Statement(tree[0])
      , outputStatement = helpers.outputStatement
      , jsStatement     = outputStatement(statement)
      , fn              = new Function(
        "var " + helpers.FUNCTION_DEPOT_NAME + " = { 'hello-world': function () { return 'Hello, World!'; } };" +
        "return " + jsStatement + ";"
      );
      assert.equal(fn(), "Hello, World!");
  });

  it("should build `(add2 4)` into `" + helpers.FUNCTION_DEPOT_NAME +"['add2'](4)`", function () {
    var Statement       = helpers.Statement
      , buildTree       = helpers.buildTree
      , tree            = buildTree(['(', 'add2', '4', ')'])
      , statement       = new Statement(tree[0])
      , outputStatement = helpers.outputStatement
      , jsStatement     = outputStatement(statement)
      , fn              = new Function(
        "var " + helpers.FUNCTION_DEPOT_NAME + " = { 'add2': function (x) { return x + 2; } };" +
        "return " + jsStatement + ";"
      );
      assert.equal(fn(), 6);
  });

  it("should handle higher order functions just fine e.g. `((addCurry 4) 2)`", function () {
    var Statement       = helpers.Statement
      , buildTree       = helpers.buildTree
      , tree            = buildTree(['(', '(', 'addCurry', '4', ')', '2', ')'])
      , statement       = new Statement(tree[0])
      , outputStatement = helpers.outputStatement
      , jsStatement     = outputStatement(statement)
      , fn              = new Function(
        "var " + helpers.FUNCTION_DEPOT_NAME + " = {" +
          "addCurry: function (x) {" +
            "return function (y) {" +
              "return x + y;" +
            "};" +
          "}" +
        "};" +
        "return " + jsStatement + ";"
      );
    assert.equal(fn(), 6);
  });

  it("should be able to execute a lambda function on the fly", function () {
    var Statement       = helpers.Statement
      , buildTree       = helpers.buildTree
      , tree            = buildTree([
          '(', '(', 'lambda', '(', ')'
          , '(', 'some-lambda', ')', ')', ')'])
      , statement       = new Statement(tree[0])
      , outputStatement = helpers.outputStatement
      , jsStatement     = outputStatement(statement)
      , fn              = new Function(
        "var " + helpers.FUNCTION_DEPOT_NAME + " = {" +
          "'some-lambda': function () {" +
            "return function () {" +
              "return 'Hello, World!';" +
            "}" +
          "}" +
        "};" +
        "return " + jsStatement + ";"
      );

    assert.equal(fn()(), "Hello, World!");
  });

  it("should be able to pass in a lambda functions", function () {
    var Statement       = helpers.Statement
      , buildTree       = helpers.buildTree
      , tree            = buildTree([
          '(', 'accept'
          , '(', 'lambda', '(', ')'
            , '(', 'hello-world', ')', ')', ')'])
      , statement       = new Statement(tree[0])
    var outputStatement = helpers.outputStatement
      , jsStatement     = outputStatement(statement)
      , fn              = new Function(
        "var " + helpers.FUNCTION_DEPOT_NAME + " = {" +
          "'hello-world': function () {" +
            "return 'Hello, World!';" +
          "}," +
          "accept: function (f) {" +
            "return f();" +
          "}" +
        "};" +
        "return " + jsStatement + ";"
      );

    assert.equal(fn(), "Hello, World!");
  });
});

describe("lambda builder", function () {
  it("should be able to return an anonymous function", function () {
    var Lambda       = helpers.Lambda
      , buildTree    = helpers.buildTree
      , tree         = buildTree([
          '(', 'lambda', '(', ')'
          , '(', 'hello-world', ')', ')'
      ])
      , lambda       = new Lambda(tree[0])
      , outputLambda = helpers.outputLambda
      , jsLambda     = outputLambda(lambda)
      , fn           = new Function(
        "var " + helpers.FUNCTION_DEPOT_NAME +" = { 'hello-world': function () { return 'Hello, World!'; } };" +
        "return " + jsLambda + ";"
      );
    assert.equal(fn()(), 'Hello, World!');
  });
});

describe("function builder", function () {
  it("should be able to initialize a function", function () {
    var source = "(defun add (x y) (+ x y))"
      , tokens = helpers.tokenize(source)
      , tree   = helpers.buildTree(tokens)
      , ast    = helpers.buildAst(tree)
      , output = helpers.outputFunction(ast[0])
      , fn     = new Function(
        "var " + helpers.FUNCTION_DEPOT_NAME + " = { '+': function (x, y) { return x + y;} };" +
        output + ";" +
        "return " + helpers.FUNCTION_DEPOT_NAME
      );
    assert.equal(fn().add(2, 3) , 5);
  });

  it("should handle functions that return lambdas", function () {
    var source = "(defun curryAdd (a) (lambda (b) (+ a b)))"
      , tokens = helpers.tokenize(source)
      , tree   = helpers.buildTree(tokens)
      , ast    = helpers.buildAst(tree)
      , output = helpers.outputFunction(ast[0])
      , fn     = new Function(
        "var " + helpers.FUNCTION_DEPOT_NAME + " = { '+': function (x, y) { return x + y; } };" +
        output + ";" +
        "return " + helpers.FUNCTION_DEPOT_NAME
      );
  });
});

describe("compiler", function () {
  it("should be able to compile code, and then run it successfully.", function () {
    var source = getSource('complete')
      , tokens = helpers.tokenize(source)
      , tree   = helpers.buildTree(tokens)
      , ast    = helpers.buildAst(tree)
      , output = helpers.compile(ast);
    console.log(output);
  });
});

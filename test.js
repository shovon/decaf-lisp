var helpers = require('./lib/helpers')
  , assert  = require('assert')
  , fs      = require('fs');

var getSource = function (name) {
  return fs.readFileSync("./examples/" + name + ".lisp", "utf8");
};

var isArray = function (obj) {
  return Object.prototype.toString.call(obj) === "[object Array]";
};

assert.deepEqual = function (obj1, obj2) {
  var i, len;
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

  it("should not be able to parse")
});

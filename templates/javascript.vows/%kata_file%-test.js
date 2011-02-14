// Adapt the code to your code kata %kata_file%.
// Important: Test and production code has to be
//            completely in this file.

require.paths.push(__dirname + '/../lib/');
require.paths.push(__dirname + '/../deps/');	

var vows = require('vows'),	assert = require('assert');	

var foo = {	
  'bar' : function() {	
	  return "fixme"
  }	
};

vows.describe("%kata_file%").addBatch({
  '%kata_file%' : {	
    topic: function() {	
	    return foo.bar();	
    },
    'should do something' : function(data) {	
      assert.equal(data, "foo.bar");	
    }	
  }	
}).export(module, {error: false});	
